resource "aws_subnet" "az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-cf-az1-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "az2" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.az2}"

  tags {
    Name        = "${var.environment}-cf-az2-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "az3" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.6.0/24"
  availability_zone = "${var.az3}"

  tags {
    Name        = "${var.environment}-cf-az3-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "rds_az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.7.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-cf-rds-az1-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "rds_az2" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.8.0/24"
  availability_zone = "${var.az2}"

  tags {
    Name        = "${var.environment}-cf-rds-az2-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "rds_az3" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.9.0/24"
  availability_zone = "${var.az3}"

  tags {
    Name        = "${var.environment}-cf-rds-az3-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}


resource "aws_subnet" "services" {
  count = "${local.num_azs}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(local.services_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-services-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}