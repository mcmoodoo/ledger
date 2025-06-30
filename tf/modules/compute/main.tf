resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = var.iam_instance_profile_name

  user_data = var.user_data != null ? file(var.user_data) : null

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge(var.tags, {
    Name = "${var.name}-host"
  })
}

resource "aws_eip" "bastion_eip" {
  count      = var.create_eip ? 1 : 0
  instance   = aws_instance.bastion.id
  depends_on = [aws_instance.bastion]
  
  tags = merge(var.tags, {
    Name = "${var.name}-eip"
  })
}