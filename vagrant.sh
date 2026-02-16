#!/bin/bash

# ======================================================================
# Script to set up Vagrant environment
# Purpose: Cleans old data, runs Vagrant, and displays environment details
# Author: Syed Dadapeer
# ======================================================================

# Define host file path
HOST_FILE="./hosts.yaml"

# Clean old data
echo "Cleaning old data in $HOST_FILE..."
rm -rf ./.vagrant/  # Remove old Vagrant data
echo "servers: " > "$HOST_FILE"
echo "Old data cleaned successfully"

# Run vagrant
echo "✓Running Vagrant..."
vagrant up

# Check if vagrant executed successfully
if [ $? -eq 0 ]; then
    echo "-----------------------------------------------------------------------------------"
    echo "🎉  ENVIRONMENT READY!  ✅"
    echo "-----------------------------------------------------------------------------------"

    # Count total VMs
    VM_COUNT=$(vagrant status --machine-readable | grep ',state,' | wc -l)
    echo "  🖥 Total Servers: $VM_COUNT"
    echo "    ✅ ALL servers are UP and RUNNING...! 🚀 "
    echo "    📄 Inventory(Hostname + IP)) file location: $HOST_FILE"
    echo ""
    echo "  👉 Inventory details:" 
    sed 's/^/  /' ./hosts.yaml
    echo ""
    echo "  👉 To login into a server:"
    echo "      vagrant ssh <VM_NAME>"
    echo ""
    echo "  👉 List VM status:"
    echo "      vagrant status"
    echo ""
    echo "  👉 To list IP addresses:"
    echo "      vagrant ssh-config | grep HostName        # Get all IP addresses"
    echo "                    or"
    echo "      vagrant ssh <VM_NAME> -c "hostname -I"   # Get IP of a specific server"
    echo ""
    echo "  👉 To destroy everything:"
    echo "      vagrant destroy -f"
    echo ""
    echo "🚀 Environment is ready for use!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "Error: Vagrant execution failed"
    exit 1
fi