provider "aws" {
  region = var.region
}

# ========================
# EKS Cluster Role
# ========================
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  depends_on = [aws_iam_role.eks_cluster_role]
}

# ========================
# EKS Node Group Role
# ========================
resource "aws_iam_role" "eks_node_role" {
  name = "${var.prefix}-eks-node-role"

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

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  depends_on = [aws_iam_role.eks_node_role]
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  depends_on = [aws_iam_role.eks_node_role]
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  depends_on = [aws_iam_role.eks_node_role]
}


# ========================
# IRSA Role for Spark Pod S3 Access
# ========================
resource "aws_iam_role" "irsa_s3_role" {
  name = "${var.prefix}-irsa-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.eks_oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:spark:spark-service-account"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "irsa_s3_policy" {
  name = "${var.prefix}-irsa-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "irsa_s3_attach" {
  role       = aws_iam_role.irsa_s3_role.name
  policy_arn = aws_iam_policy.irsa_s3_policy.arn
}

