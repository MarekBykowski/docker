#!/bin/bash

# Check if the script is being sourced
(return 0 2>/dev/null)
if [ $? -eq 0 ]; then
#echo "Script is being sourced"
:
else
echo "Script is being executed"
fi

keys=("rvranax" "csmx" "svellipx" "tziyangx" "tonyhunx" "markhox" "test1" "mbykowsx")
vals=(11100 11200 11300 11400 11500 11600 11700 11800)

declare -A START_PORT_PER_USER
for i in "${!keys[@]}"; do
	START_PORT_PER_USER[${keys[$i]}]=${vals[$i]}
done

# Range of ports to check
START_PORT=${START_PORT_PER_USER[$USER]}
END_PORT=$((START_PORT+9))

# Function to check if a port is in use
is_port_in_use() {
	local port=$1
	ss -tuln | awk '{print $5}' | grep -qE ":$port\$"
}


# Spit out next available port. Give START_PORT as an argument.
echo_free_port() {
	if [ -z "$1" ]; then
		START_PORT=1024
	fi
	for ((port=$START_PORT; port<=$END_PORT; port++)); do
		if ! is_port_in_use "$port"; then
			echo "$port"
			break
		fi
	done
}
