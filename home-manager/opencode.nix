{ lib, stdenvNoCC, fetchurl, autoPatchelfHook, makeWrapper, installShellFiles,
  ripgrep, versionCheckHook, writableTmpDirAsHomeHook }:

let
  assets = {
    x86_64-linux = {
      arch = "x64-baseline";
      hash = "sha256:09f44302c10fd036912f59c81fd1aef5df45dd06f649197f9dfc9bbe2a79614e";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256:5a528f42caf576c6cdece6a191eb273d3db54effa5518e0402684d8f8026aeb6";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode";
  version = "2.2.5";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${finalAttrs.version}/opencode-linux-${asset.arch}.tar.gz";
    inherit (asset) hash;
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook makeWrapper installShellFiles ];
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 opencode "$out/bin/opencode"
    wrapProgram "$out/bin/opencode" \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
    runHook postInstall
  '';

  postInstallCheck = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    # OpenCode creates $TMPDIR/opencode, which would collide with the unpacked binary.
    export TMPDIR=$(mktemp -d)
    installShellCompletion --cmd opencode \
      --bash <("$out/bin/opencode" --completions bash) \
      --zsh <("$out/bin/opencode" --completions zsh) \
      --fish <("$out/bin/opencode" --completions fish)
  '';

  nativeInstallCheckInputs = [ versionCheckHook writableTmpDirAsHomeHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = [ "HOME" "OPENCODE_DISABLE_MODELS_FETCH" ];
  env.OPENCODE_DISABLE_MODELS_FETCH = true;

  meta = {
    description = "AI coding agent built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = builtins.attrNames assets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
