# Redis (Elasticache)
resource "aws_security_group" "redis" {
  name        = "${var.environment}_redis_security_group"
  description = "Redis access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-redis-security-group"
    Environment = "${var.environment}"
  }
}

# resource "aws_security_group_rule" "allow-all" {
#   security_group_id = "${aws_security_group.bosh.id}"
#   type              = "egress"
#   protocol          = "-1"
#   from_port         = 0
#   to_port           = 0
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# CREATE USER

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = ["${aws_subnet.rds.*.id}"]
}

# User and permissions
resource "aws_iam_user" "redis" {
  name = "${var.environment}-redis-user"
  path = "/services/"
}

resource "aws_iam_user_policy" "redis" {
  name = "${var.environment}-redis-policy"
  user = "${aws_iam_user.redis.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "elasticache:DescribeCacheClusters",
        "elasticache:ModifyCacheCluster",
        "elasticache:DeleteCacheCluster",
        "elasticache:AddTagsToResource"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "AllowElasticacheSizes",
      "Effect": "Allow",
      "Action": "elasticache:CreateCacheCluster",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "elasticache:CacheNodeType": [
            "cache.t2.micro",
            "cache.t2.small",
            "cache.t2.medium",
            "cache.m3.large",
            "cache.m3.large",
            "cache.m4.large",
            "cache.r4.large",
            "cache.r3.large"
          ]
        }
      }
    },
    {
      "Action": [
        "iam:GetUser"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
