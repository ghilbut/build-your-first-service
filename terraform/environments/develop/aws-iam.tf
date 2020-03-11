data aws_iam_policy_document assume_role_policy {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource aws_iam_role ecsTaskExecutionRole {
  name               = "iam-role-byfs-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource aws_iam_role_policy_attachment ecsTaskExecutionRole_policy {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# https://aws.amazon.com/ko/premiumsupport/knowledge-center/ecs-data-security-container-task/
resource aws_iam_policy secret_access_policy {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:ssm:ap-northeast-2:*:parameter/*",
        "arn:aws:secretsmanager:ap-northeast-2:*:secret:*"
      ]
    }
  ]
}
EOF
}

resource aws_iam_role_policy_attachment secrets {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.secret_access_policy.arn
}
