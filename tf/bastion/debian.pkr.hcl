packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "region" {
  default = "us-east-1"
}

source "amazon-ebs" "debian" {
  region           = var.region
  instance_type    = "t3.xlarge"
  ami_name         = "debian-dev-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "debian-12-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"] # Official Debian AMIs
  }

  ssh_username = "admin"
}

build {
  name    = "debian-dev-box"
  sources = ["source.amazon-ebs.debian"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y fzf git gh lcov neofetch ncurses-term vim curl wget unzip fontconfig build-essential",

      # Install Rust non-interactively (installs rustup, cargo, rustc)
      "curl https://sh.rustup.rs -sSf | sh -s -- -y",
      # "echo '. $HOME/.cargo/env' >> $HOME/.bashrc",
      # ". $HOME/.cargo/env",

      "cargo install bat zellij yazi-cli xh viu sd ripgrep fd-find eza",

      # Install Starship prompt
      "mkdir -p /tmp/starship",
      "curl -sSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir /tmp/starship",
      "sudo mv /tmp/starship/starship /usr/local/bin/",
      "echo 'eval \"$(/usr/local/bin/starship init bash)\"' | sudo tee -a /etc/bash.bashrc > /dev/null",
      "echo 'alias ll=\"ls -al\"' >> $HOME/.bashrc",

      # Install MesloLGS Nerd Font
      "wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip -O /tmp/Meslo.zip",
      "sudo mkdir -p /usr/local/share/fonts/meslo",
      "sudo unzip -o /tmp/Meslo.zip -d /usr/local/share/fonts/meslo",
      "sudo fc-cache -fv"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}


