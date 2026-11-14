"""Integration checks for local usage tracking; no personal state is touched."""

import importlib.machinery
import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader(
    "usage", str(ROOT / "nesono-usage")
)
spec = importlib.util.spec_from_loader(loader.name, loader)
usage = importlib.util.module_from_spec(spec)
loader.exec_module(usage)


class UsageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.state = Path(self.temp.name)
        self.env = dict(
            os.environ,
            XDG_STATE_HOME=str(self.state),
            NESONOBININSTALLATIONDIR=str(ROOT),
            NESONO_USAGE="1",
        )
        self.log = self.state / "nesono-bin/usage.tsv"

    def test_report_filters_and_ignores_partial_lines(self):
        self.log.parent.mkdir()
        self.log.write_text(
            "100\tshell\tcalc\n200\tshell\tcalc\n300\tnvim\tCommit\nbroken\n"
        )
        counts, latest = usage.report(self.log, since=150, category="shell")
        self.assertEqual(counts, {("shell", "calc"): 1})
        self.assertEqual(latest, {("shell", "calc"): 200})

    @unittest.skipUnless(shutil.which("zsh"), "Zsh not installed")
    def test_shell_scope_disable_and_hook_registration(self):
        script = r"""
source "$NESONOBININSTALLATIONDIR/shtils/helpers"
source "$NESONOBININSTALLATIONDIR/shtils/aliases"
source "$NESONOBININSTALLATIONDIR/zshtils/usage.zsh"
source "$NESONOBININSTALLATIONDIR/zshtils/usage.zsh"
[[ ${(M)#preexec_functions:#_nesono_usage_preexec} == 1 ]] || exit 1
_nesono_usage_preexec 'calc secret-input'
_nesono_usage_preexec './srcgrep secret-filename'
_nesono_usage_preexec 'll secret-directory'
_nesono_usage_preexec 'echo secret-text'
NESONO_USAGE=0 _nesono_usage_preexec 'calc disabled'
XDG_STATE_HOME=/dev/null _nesono_usage_preexec 'calc unwritable'
"""
        subprocess.run(
            ["zsh", "-f", "-c", script], cwd=ROOT, env=self.env, check=True
        )
        lines = self.log.read_text().splitlines()
        self.assertEqual(len(lines), 3)
        self.assertEqual(
            {line.split("\t")[2] for line in lines},
            {"function:calc", "script:srcgrep", "alias:ll"},
        )
        self.assertNotIn("secret", self.log.read_text())
        self.assertEqual(self.log.stat().st_mode & 0o777, 0o600)

    @unittest.skipUnless(shutil.which("nvim"), "Neovim not installed")
    def test_nvim_callbacks_strings_prompts_lazy_specs_and_disable(self):
        lua = self.state / "check.lua"
        lua.write_text(r"""
vim.opt.rtp:append(vim.env.NESONOBININSTALLATIONDIR .. "/nvim")
vim.g.mapleader = " "
local u = require("config.usage")
u.map("n", "Q", function() vim.g.ran_callback = true end, { desc = "callback" })
vim.api.nvim_feedkeys("Q", "xt", false)
assert(vim.g.ran_callback)
u.map("n", "Z", ":let g:ran_string = 1<CR>", { desc = "string" })
vim.api.nvim_feedkeys("Z", "xt", false)
assert(vim.g.ran_string == 1)
local spec = u.plugin({ keys = {{ "X", ":let g:ran_lazy = 1<CR>", desc = "lazy" }} })
local key = spec.keys[1]
vim.keymap.set("n", key[1], key[2], { expr = key.expr })
vim.api.nvim_feedkeys("X", "xt", false)
assert(vim.g.ran_lazy == 1)
dofile(vim.env.NESONOBININSTALLATIONDIR .. "/nvim/lua/plugins/fugitive.lua").init()
for _, ft in ipairs({"lua", "DiffviewFiles"}) do
  vim.cmd.enew()
  vim.bo.filetype = ft
  local prompt = vim.fn.maparg(" c ", "n", false, true)
  assert(prompt.buffer == 0 and prompt.callback() == ":Git commit ")
end
vim.api.nvim_create_user_command("Git", function(args) vim.g.git_args = args.args end, { nargs = "*", bar = true })
vim.api.nvim_feedkeys(" cc", "xt", false)
assert(vim.g.git_args == "commit")
vim.api.nvim_feedkeys(" ca", "xt", false)
assert(vim.g.git_args == "commit --amend")
vim.bo.filetype = "fugitive"
assert(vim.fn.maparg("cc", "n", false, true).buffer == 1)
vim.env.NESONO_USAGE = "0"
u.record("disabled")
vim.env.NESONO_USAGE = "1"
vim.env.XDG_STATE_HOME = "/dev/null"
u.record("unwritable")
""")
        subprocess.run(
            ["nvim", "--headless", "-u", "NONE", "-i", "NONE", "-l", str(lua)],
            cwd=ROOT,
            env=self.env,
            check=True,
        )
        content = self.log.read_text()
        self.assertIn("\tnvim\tcallback\n", content)
        self.assertIn("\tnvim\tlazy\n", content)
        self.assertIn("\tnvim\tCommit staged changes\n", content)
        self.assertNotIn("disabled", content)
        self.assertNotIn("unwritable", content)
        self.assertEqual(self.log.stat().st_mode & 0o777, 0o600)


if __name__ == "__main__":
    unittest.main()
