# ======================================================================
# 🚀 Vagrantfile | Virtual Box (Reusable & Scalable)
# Author : Syed Dadapeer
# Purpose: Multi-VM lab for DevOps / Cloud practice (Local Setup)
# Note   : Requires 'vagrant-disksize' plugin
#          Install via: vagrant plugin install vagrant-disksize
# ======================================================================

# ----------------------------------------------------------------------
# 🔧 DEFAULT PROVIDER
# ----------------------------------------------------------------------
ENV["VAGRANT_DEFAULT_PROVIDER"] = "virtualbox"

Vagrant.configure("2") do |config|

  # ===================================================================
  # 🔧 GLOBAL VARIABLES (EDIT ONLY HERE)
  # =================================================================== 
  VM_COUNT  = 2                               # Number of servers to create
  VM_MEMORY = 4096                            # RAM in MB (GB)
  VM_CPU    = 2
  VM_DISK   = 25                              # Disk in GB
  VM_NAME   = "server"                        # Base name for the servers
  SSH_USER  = "ubuntu"                        # SSH Username
  SSH_PASS  = "1234"                          # SSH Password
  BASE_BOX  = "ubuntu-server24/ubuntu_24.04.02" # Base box to use
  HOST_FILE = "/vagrant/hosts.yaml"           # File to store IP addresses

  # ===================================================================== 
  # 📦 BASE BOX
  # =====================================================================
  config.vm.box = BASE_BOX
  config.vm.box_check_update = true # Check for box updates on 'vagrant up'

  # vagrant-vbguest plugin configuration (if installed)
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_install  = true
  end

  unless Vagrant.has_plugin?("vagrant-disksize")
    raise 'Please install plugin: vagrant plugin install vagrant-disksize'
  end

  # ======================================================================
  # 🔁 LOOP TO CREATE SERVERS
  # ======================================================================
  (1..VM_COUNT).each do |i|
    config.vm.define "#{VM_NAME}-#{i}" do |node|
      node.vm.hostname = "#{VM_NAME}-#{i}"         # 🖥 HOSTNAME

      # 🌐 Bridged Network (Automatic)
      node.vm.network "public_network", bridge: "Automatic"

      # 💽 STORAGE (requires vagrant-disksize plugin)
      node.disksize.size = "#{VM_DISK}GB"

      # =================================================================== 
      # 🖥️ VirtualBox Provider
      # ===================================================================
      node.vm.provider "virtualbox" do |vb|
        vb.name = "#{VM_NAME}-#{i}"   # VM Name in VirtualBox
        vb.memory = VM_MEMORY         # RAM in MB
        vb.cpus = VM_CPU              # CPU cores

        # Optional but recommended VirtualBox optimizations
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
        vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
        vb.customize ["modifyvm", :id, "--macaddress1", "auto"]
        
        # Disable unnecessary features
        vb.customize ["modifyvm", :id, "--biosbootmenu", "disabled"]
        vb.customize ["modifyvm", :id, "--audio", "none"]
        vb.customize ["modifyvm", :id, "--usb", "off"]
        
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
        echo "🔐 Configuring SSH to allow password authentication..."
        sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sudo systemctl restart ssh

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
        # 🌐 Capture IP
        IP_ADDR=$(ip -4 addr | grep 192.168 | awk '{print $2}' | cut -d/ -f1)
        echo "    ip: $IP_ADDR" >> #{HOST_FILE}
        
        echo "✅ #{node.vm.hostname} ready with IP: $IP_ADDR"

        echo "✅ Provisioning completed on #{node.vm.hostname}"

      SHELL

    end
  end

end

