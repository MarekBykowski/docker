#!/bin/bash

: << 'EOF'
# Check if the script is being sourced
(return 0 2>/dev/null)
if [ $? -eq 0 ]; then
echo "Script is being sourced"
else
echo "Script is being executed"
fi
EOF

# Range of ports to check
START_PORT=1024
END_PORT=65535

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

ports=()
while [ "${#ports[@]}" -lt 3 ]; do
	port=$(echo_free_port $START_PORT)
	if [[ ! " ${ports[*]} " =~ " $port " ]]; then
		ports+=($port)
		((START_PORT+=1))
	fi
done

echo "The 3x ports found unused: ${ports[@]}"
