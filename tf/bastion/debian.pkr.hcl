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
  instance_type    = "t3.micro"
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
      "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y fzf git gh lcov neofetch vim curl unzip",
      "echo 'eval \"$(/usr/local/bin/starship init bash)\"' | sudo tee -a /etc/bash.bashrc > /dev/null"
    ]
  }
}


