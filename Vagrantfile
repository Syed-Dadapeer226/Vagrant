# ======================================================================
# 🚀 Vagrantfile | VMware Fusion (Reusable & Scalable)
# Author : Syed Dadapeer
# Purpose: Multi-VM lab for DevOps / Cloud practice (Local Setup)
# Note   : Requires 'vagrant-disksize' & 'vagrant_vmware_desktop' plugin
#          Install via: vagrant plugin install vagrant-disksize
#                       vagrant plugin install vagrant_vmware_desktop
# ======================================================================

# ----------------------------------------------------------------------
# 🔧 DEFAULT PROVIDER
# ----------------------------------------------------------------------
ENV["VAGRANT_DEFAULT_PROVIDER"] = "vmware_desktop"

Vagrant.configure("2") do |config|

  # ===================================================================
  # 🔧 GLOBAL VARIABLES (EDIT ONLY HERE)
  # =================================================================== 
  VM_COUNT   = 2                    # Number of servers to create
  VM_MEMORY = 4096                  # RAM in MB (GB)
  VM_CPU    = 2
  VM_DISK   = 25                    # Disk in GB
  VM_NAME = "server"                # Base name for the servers
  SSH_USER   = "ubuntu"             # SSH Username
  SSH_PASS   = "1234"               # SSH Password
  BASE_BOX  = "bento/ubuntu-24.04"  # Base box to use
  HOST_FILE = "/vagrant/hosts.yaml" # File to store IP addresses

  # ===================================================================== 
  # 📦 BASE BOX
  # =====================================================================
  config.vm.box = BASE_BOX
  config.vm.box_check_update = false

  # ======================================================================
  # 🔁 LOOP TO CREATE SERVERS
  # ======================================================================
  (1..VM_COUNT).each do |i|
    config.vm.define "#{VM_NAME}-#{i}" do |node|
      node.vm.hostname = "#{VM_NAME}-#{i}"         # 🖥 HOSTNAME

      # 🌐 Bridged Network (Automatic)
      node.vm.network "public_network", bridge: "Automatic"

      # 💽 Disk Resize (requires vagrant-disksize plugin)
      node.disksize.size = "#{VM_DISK}GB"

      # =================================================================== 
      # 🖥️ VMware Fusion Provider
      # ===================================================================
      node.vm.provider "vmware_desktop" do |v|
        v.vmx["memsize"]  = VM_MEMORY.to_s        # RAM in MB
        v.vmx["numvcpus"] = VM_CPU.to_s           # CPU cores
        v.vmx["displayName"] = "#{VM_NAME}-#{i}"
        v.vmx["scsi0:0.fileSize"] = "#{VM_DISK}GB"
        # DISK – FORCE SIZE AT VMX LEVEL
        v.vmx["scsi0.present"] = "TRUE"
        v.vmx["scsi0.virtualDev"] = "lsilogic"

        v.vmx["scsi0:0.fileName"] = "#{VM_NAME}-#{i}.vmdk"
        v.vmx["scsi0:0.redo"] = ""
        v.vmx["scsi0:0.mode"] = "persistent"
        v.vmx["scsi0:0.deviceType"] = "scsi-hardDisk"

        # 🚫 Disable extra disks
        v.vmx["scsi0:1.present"] = "FALSE"
        v.vmx["scsi0:2.present"] = "FALSE"

        # ✅ Force exact size
        v.vmx["disk.enableUUID"] = "TRUE"

        # REMOVE NAT COMPLETELY
        v.vmx["ethernet0.present"] = "FALSE"

        # FORCE SINGLE BRIDGED ADAPTER
        v.vmx["ethernet1.present"]        = "TRUE"
        v.vmx["ethernet1.connectionType"] = "bridged"
        v.vmx["ethernet1.addressType"]    = "generated"
      end

      # =====================================================================
      # 📦 PROVISIONING
      # =====================================================================
      node.vm.provision "shell", inline: <<-SHELL
        echo "🚀 Provisioning #{node.vm.hostname}..."

        # 👤 Create ubuntu user if not exists
        echo "👤 Setting up user #{SSH_USER}..."
        if ! id "#{SSH_USER}" &>/dev/null; then
          sudo useradd -m -s /bin/bash #{SSH_USER}
          echo "#{SSH_USER}:#{SSH_PASS}" | sudo chpasswd
          sudo usermod -aG sudo "#{SSH_USER}"
        fi

        # Update & install packages
        echo "🔧 Updating system..."
        sudo apt-get update -y

        echo "📦 Installing packages..."
        sudo apt-get install -y openssh-server curl vim git net-tools

        echo "🔐 Enabling SSH..."
        sudo systemctl enable ssh
        sudo systemctl start ssh

        # 🔐 Enable SSH password auth
        #echo "🔐 Configuring SSH to allow password authentication..."
        #sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
        #sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
        #sudo systemctl restart ssh

        # 🔑 Passwordless SSH for ubuntu
        echo "🔑 Setting up passwordless SSH for #{SSH_USER}..."
        sudo -u "#{SSH_USER}" mkdir -p /home/"#{SSH_USER}"/.ssh
        sudo -u "#{SSH_USER}" ssh-keygen -t rsa -b 4096 -N "" -f /home/"#{SSH_USER}"/.ssh/id_rsa || true
        sudo cat /home/"#{SSH_USER}"/.ssh/id_rsa.pub | sudo tee -a /home/"#{SSH_USER}"/.ssh/authorized_keys
        sudo chmod 600 /home/"#{SSH_USER}"/.ssh/authorized_keys
        sudo chown -R "#{SSH_USER}:#{SSH_USER}" /home/"#{SSH_USER}"/.ssh
        
        # Write host info to YAML file
        echo "📝 Writing host info to #{HOST_FILE}..."
        echo "  - hostname: $(hostname)" >> #{HOST_FILE}
        echo "    ip: $(hostname -I | awk '{print $1}')" >> #{HOST_FILE}

        # 🌐 Capture IP
        IP_ADDR=$(ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n1)
        
        echo "✅ #{node.vm.hostname} ready with IP: $IP_ADDR"

        echo "✅ Provisioning completed on #{node.vm.hostname}"

      SHELL

    end
  end

end

