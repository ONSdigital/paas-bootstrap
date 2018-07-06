resource "aws_subnet" "az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-bosh-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "rds_az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.10.0/26"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-bosh-rds-az1-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "rds_az2" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.10.64/26"
  availability_zone = "${var.az2}"

  tags {
    Name        = "${var.environment}-bosh-rds-az2-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "rds_az3" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.10.128/26"
  availability_zone = "${var.az3}"

  tags {
    Name        = "${var.environment}-bosh-rds-az3-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}
