#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: kv-get.sh <vault-name> <secret-name> [version]

Reads a secret value from Azure Key Vault using Azure CLI.
- vault-name: name of the Key Vault (not the DNS name)
- secret-name: name of the secret
- version (optional): specific secret version; omit for latest

Requires: az login (with access to the vault) and az CLI installed.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 1
fi

vault="$1"
secret="$2"
version="${3:-}"

cmd=(az keyvault secret show --vault-name "$vault" --name "$secret" --query value -o tsv)
if [[ -n "$version" ]]; then
  cmd+=(--version "$version")
fi

# Prints the secret value to stdout. Redirect/pipe as needed to avoid logging secrets.
"${cmd[@]}"
