packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "aws" {
  access_key                  = "${var.aws_access_key}"
  ami_name                    = "opennms-${local.timestamp}"
  associate_public_ip_address = true
  instance_type               = "${var.instance_type}"
  region                      = "${var.region}"
  secret_key                  = "${var.aws_secret_key}"
  source_ami                  = "${var.base_ami}"
  ssh_username                = "${var.ssh_username}"
}

build {
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "HOME_DIR=/home/ubuntu"
    ]
    execute_command   = "echo 'ubuntu' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    expect_disconnect = true
    scripts = ["./scripts/10-update.sh", "./scripts/20-ansible.sh"]
  }

  sources = ["source.amazon-ebs.aws"]

  provisioner "ansible" {
        command = "ansible-playbook"
        playbook_file = "./ansible-opennms/hzn-core-db-deployment.yml"
        user = "ubuntu"
        use_proxy = false
    }
}
