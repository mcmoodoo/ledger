resource "aws_iam_role" "bastion_role" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "bastion_policy" {
  name = "${var.name}-policy"
  role = aws_iam_role.bastion_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      var.custom_policy_statements,
      [
        {
          Effect = "Allow",
          Action = [
            "sts:GetCallerIdentity"
          ],
          Resource = "*"
        }
      ]
    )
  })
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.bastion_role.name

  tags = var.tags
}