# Local usage tracking for commands submitted to interactive Zsh.
# Use a separate hook so existing preexec/title hooks keep working.
autoload -Uz add-zsh-hook
zmodload zsh/datetime
zmodload zsh/parameter

_nesono_usage_preexec() {
    emulate -L zsh
    [[ ${NESONO_USAGE:-1} != 0 ]] || return 0
    local -a words
    words=(${(z)1})
    local name=${(Q)words[1]} feature='' resolved origin
    local root=${NESONOBININSTALLATIONDIR:A}
    [[ -n $name && -n $NESONOBININSTALLATIONDIR ]] || return 0

    # Only names registered by this repository are eligible for recording.
    if (( ${+aliases[$name]} )) && [[ ${aliases[$name]} == ${_nesono_usage_aliases[$name]-} ]]; then
        feature="alias:$name"
    elif (( ${+functions[$name]} )); then
        origin=${functions_source[$name]}
        [[ ${origin:A} == $root/* && $name != _nesono_usage_* ]] && feature="function:$name"
    else
        resolved=$(whence -p -- "$name" 2>/dev/null)
        [[ -n $resolved && ${resolved:A:h} == $root && -x $resolved ]] && feature="script:${resolved:t}"
    fi
    [[ -n $feature && $feature != *$'\t'* && $feature != *$'\n'* ]] || return 0
    local state=${XDG_STATE_HOME:-$HOME/.local/state}/nesono-bin
    # Fail quietly: telemetry must not prevent the command from running.
    (umask 077; mkdir -p -- "$state" && print -r -- "$EPOCHSECONDS"$'\t'"shell"$'\t'"$feature" >> "$state/usage.tsv") 2>/dev/null
    return 0
}

# Snapshot only the aliases declared in the repo, not arbitrary user aliases.
# zsh records function source locations, but has no equivalent for aliases.
typeset -gA _nesono_usage_aliases
for _nesono_usage_file in "$NESONOBININSTALLATIONDIR"/shtils/aliases*(N); do
    while IFS= read -r _nesono_usage_line; do
        if [[ $_nesono_usage_line =~ '^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_]+)=' ]]; then
            _nesono_usage_aliases[$match[1]]=${aliases[$match[1]]-}
        fi
    done < "$_nesono_usage_file"
done
unset _nesono_usage_file _nesono_usage_line
add-zsh-hook -d preexec _nesono_usage_preexec
add-zsh-hook preexec _nesono_usage_preexec
