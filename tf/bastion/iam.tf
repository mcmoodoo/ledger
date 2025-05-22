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
          "eks:*",
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::mcmoodoo-terraform-state-bucket",
          "arn:aws:s3:::mcmoodoo-terraform-state-bucket/bastion/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "iam:GetRole"
        ],
        Resource = "arn:aws:iam::489475227541:role/bastion-eks-access-role"
      }
    ]
  })
}

resource "aws_iam_role_policy" "kms_and_logs_access" {
  name = "kms-and-logs-access"
  role = aws_iam_role.bastion_eks_access.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:CreateKey",
          "kms:TagResource",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_full_access" {
  role       = aws_iam_role.bastion_eks_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "iam_full_access" {
  role       = aws_iam_role.bastion_eks_access.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.bastion_eks_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_eks_access.name
}
