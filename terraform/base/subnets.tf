
resource "aws_subnet" "public" {
  count = "${local.num_azs}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(local.public_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-public-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "public"
  }
}

resource "aws_subnet" "internal" {
  count = "${local.num_azs}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(local.internal_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-internal-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "services" {
  count = "${local.num_azs}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(local.services_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-services-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "rds" {
  count = "${local.num_azs}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(local.rds_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-rds-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "prometheus" {
  count = "${local.num_azs}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(local.prometheus_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-prometheus-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}

resource "aws_subnet" "concourse" {
  count             = "${local.num_azs}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(local.concourse_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-concourse-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}