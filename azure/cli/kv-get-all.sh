#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: kv-get-all.sh <vault-name>

Fetches all secret names and their latest values from Azure Key Vault.
Outputs: <secret-name><TAB><secret-value>

Requires: az login (with access to the vault) and az CLI installed.
WARNING: This prints secret values to stdout—redirect/handle carefully.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

vault="$1"

mapfile -t secrets < <(az keyvault secret list --vault-name "$vault" --query "[].name" -o tsv)

for name in "${secrets[@]}"; do
  value=$(az keyvault secret show --vault-name "$vault" --name "$name" --query value -o tsv)
  printf "%s\t%s\n" "$name" "$value"
done
