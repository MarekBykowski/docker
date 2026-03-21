#!/usr/bin/env bash
set -euo pipefail

#set -x

variant="$1"

case $variant in
	2023-1215|2025-3|2023-cosim|2025-3-ubuntu-24.04)
		:
		;;
	*)
		echo "Variant $variant doesn't exist"; exit 127
		;;
esac

BASE_DIR=$(dirname $0)

out=${BASE_DIR}/${variant}/Dockerfile
echo "rm $out"
rm -f "$out"

fragments=(
	00-base.inc
	10-apt-intel.inc
	20-common-tools.inc
	30-variant-tools.inc
	40-config.inc
	50-siemens-tools.inc
	60-user-env-ux.inc
	70-ownership.inc
	90-runtime.inc
)

for name in "${fragments[@]}"; do
	variant_path="${BASE_DIR}/${variant}/${name}"
	common_path="${BASE_DIR}/dockerfile.inc/${name}"

	if [[ -f "$variant_path" ]]; then
		echo "# included (variant override): $variant_path" >> "$out"
		cat "$variant_path" >> "$out"
	elif [[ -f "$common_path" ]]; then
		echo "# included (default): $common_path" >> "$out"
		cat "$common_path" >> "$out"
	else
		echo "# skipped (not found): $name" >> "$out"
	fi
done

echo "Generated for variant $variant: $out"
