#!/usr/bin/env bash
set -euo pipefail

#set -x

variant="$1"

case $variant in
	2023-1215|2025-3|2023-cosim)
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
	${BASE_DIR}/dockerfile.inc/00-base.inc
	${BASE_DIR}/dockerfile.inc/10-apt-intel.inc
	${BASE_DIR}/dockerfile.inc/20-common-tools.inc
	${BASE_DIR}/${variant}/30-variant-tools.inc
	${BASE_DIR}/dockerfile.inc/40-config.inc
	${BASE_DIR}/${variant}/50-siemens-tools.inc
	${BASE_DIR}/dockerfile.inc/60-user-env-ux.inc
	${BASE_DIR}/dockerfile.inc/70-ownership.inc
	${BASE_DIR}/dockerfile.inc/90-runtime.inc
)

for f in "${fragments[@]}"; do
    if [[ -f "$f" ]]; then
        echo "# included: $f" >> "$out"
        cat "$f" >> "$out"
    else
        echo "# skipped (not found): $f" >> "$out"
    fi
done

echo "Generated for variant $variant: $out"
