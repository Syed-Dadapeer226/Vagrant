#!/bin/bash

echo "Fetching the details..."

# Output file for YAML results
OUTPUT_FILE="servers.yaml"
TMP_FILE="/tmp/vm_results_$$.tmp"

# Clear previous output
> "$OUTPUT_FILE"
> "$TMP_FILE"

# Write YAML header
echo "servers:" >> "$OUTPUT_FILE"

# Get list of running VMs
VM_LIST=$(vagrant status --machine-readable | awk -F, '$3=="state" && $4=="running" {print $2}' | sort -u)
COUNT=$(echo "$VM_LIST" | wc -l | xargs)

# Function to process each VM and extract IP
process_vm() {
    vm=$1

    # Extract IP address using vagrant ssh
    IP=$(vagrant ssh "$vm" -c "
        IF=\$(ip route | awk '/default/ {print \$5; exit}')
        ip -4 -o addr show \$IF | awk '{print \$4}' | cut -d/ -f1
    " 2>/dev/null | tr -d '\r' | xargs)

    # Write VM and IP to temporary file
    echo "$vm|$IP" >> "$TMP_FILE"
}

# Export variables and function for parallel execution
export TMP_FILE
export -f process_vm

# Parallel execution
echo "$VM_LIST" | xargs -I {} -P 4 bash -c 'process_vm "$@"' _ {}

# Sort and write final OUTPUT_FILE
sort "$TMP_FILE" | while IFS='|' read -r VM IP; do
cat >> "$OUTPUT_FILE" <<EOF
  - hostname: $VM
    ip: $IP
EOF
done

# Cleanup temporary file
rm -f "$TMP_FILE"

# Display results
echo "🖥 Total Servers running: $COUNT ✅"
echo "  $(cat "$OUTPUT_FILE")"
