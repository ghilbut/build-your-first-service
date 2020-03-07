data aws_iam_user terraform {
  user_name = "byfs"
}

resource aws_iam_user_policy all {
  name = "byfs-terraform-all"
  user = data.aws_iam_user.terraform.user_name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}
