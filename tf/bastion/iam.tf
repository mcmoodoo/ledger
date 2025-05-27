resource "aws_iam_role" "bastion_eks_access" {
  name = "bastion-eks-access-role"

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
}

resource "aws_iam_role_policy" "eks_access" {
  name = "eks-access-policy"
  role = aws_iam_role.bastion_eks_access.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = "arn:aws:s3:::mcmoodoo-terraform-state-bucket"
      },
      {
        Effect   = "Allow",
        Action   = "s3:GetObject",
        Resource = "arn:aws:s3:::mcmoodoo-terraform-state-bucket/bastion/*"
      },
      {
        Effect   = "Allow",
        Action   = "iam:GetRole",
        Resource = "arn:aws:iam::489475227541:role/bastion-eks-access-role"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_eks_access.name
}
