set shell := ["bash", "-euo", "pipefail", "-c"]

# vendor path
VENDOR := "vendor"

# external sources
ECDICT := "https://raw.githubusercontent.com/skywind3000/ECDICT/master"

# List all commands
default:
    @just --list

# Download all vendor files
vd-dl: vd-ecdict

# Vendor: ECDICT https://github.com/skywind3000/ECDICT
vd-ecdict: \
    (fetch "ECDICT" ECDICT + "/stardict.py") \
    (fetch "ECDICT" ECDICT + "/lemma.en.txt") \
    (fetch "ECDICT" ECDICT + "/linguist.py")


# Fetch the file from remote and save it to {{dir}}/{{name}}.
# Skip download if the ETag is unchanged.
[private]
fetch dir url name="":
    #!/usr/bin/env bash
    set -euo pipefail

    file="{{ if name == "" { file_name(url) } else { name } }}"
    dest="{{VENDOR}}/{{dir}}/$file"
    etag="{{VENDOR}}/.etag/{{dir}}/$file"
    label="{{dir}}/$file"
    mkdir -p "$(dirname "$dest")" "$(dirname "$etag")"

    # Color only for terminal output; plain text in pipes or logs.
    if [[ -t 1 ]]; then
        C_DIM=$'\e[2m'; C_GRN=$'\e[32m'; C_RED=$'\e[31m'; C_RST=$'\e[0m'
    else
        C_DIM=""; C_GRN=""; C_RED=""; C_RST=""
    fi

    printf '%s↓ fetching  %s%s\n' "$C_DIM" "$label" "$C_RST"

    args=()
    # Only perform ETag request if the ETag file exists
    if [[ -f "$dest" && -f "$etag" ]]; then
        args+=(--etag-compare "$etag")
    fi

    if ! code=$(curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 \
            --connect-timeout 10 --max-time 120 \
            ${args[@]+"${args[@]}"} \
            --etag-save "$etag.new" \
            -w '%{http_code}' \
            -o "$dest.tmp" "{{url}}"); then
        rm -f "$dest.tmp" "$etag.new"
        printf '%s✗ failed    %s%s\n' "$C_RED" "$label" "$C_RST" >&2
        exit 1
    fi

    if [[ "$code" == "304" ]]; then
        rm -f "$dest.tmp" "$etag.new"
        printf '%s= newest    %s%s\n' "$C_DIM" "$label" "$C_RST"
    else
        mv "$dest.tmp" "$dest"
        if [[ -s "$etag.new" ]]; then
            mv "$etag.new" "$etag"
        else
            rm -f "$etag.new" "$etag"
        fi
        size=$(wc -c < "$dest" | awk '{ printf "%.1f KB", $1/1024 }')
        printf '%s✓ updated   %s (%s)%s\n' "$C_GRN" "$label" "$size" "$C_RST"
    fi

