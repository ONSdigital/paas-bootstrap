
resource "aws_subnet" "public" {
  count = "${local.num_azs}"
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 8, count.index+local.public_subnet_offset)}"
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
  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 8, count.index+local.internal_subnet_offset)}"
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
  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 8, count.index+local.services_subnet_offset)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "${var.environment}-services-az${count.index+1}-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}