mock_provider "aws" {
  override_data {
    target = data.aws_availability_zones.available
    values = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }
}

variables {
  vpc_cidr = "10.0.0.0/16"
  az_count = 2
  env      = "test"
}

run "vpc_has_correct_cidr" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should be 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.main.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled"
  }

  assert {
    condition     = aws_vpc.main.enable_dns_support == true
    error_message = "DNS support should be enabled"
  }
}

run "vpc_tagged_with_environment" {
  command = plan

  assert {
    condition     = aws_vpc.main.tags["Name"] == "portfolio-test-vpc"
    error_message = "VPC Name tag should include environment"
  }
}

run "creates_correct_number_of_public_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Should create 2 public subnets for az_count=2"
  }
}

run "creates_correct_number_of_app_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.app) == 2
    error_message = "Should create 2 app subnets for az_count=2"
  }
}

run "creates_correct_number_of_db_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.db) == 2
    error_message = "Should create 2 db subnets for az_count=2"
  }
}

run "public_subnets_have_public_ip" {
  command = plan

  assert {
    condition     = aws_subnet.public[0].map_public_ip_on_launch == true
    error_message = "Public subnets should map public IP on launch"
  }
}

run "app_subnets_are_private" {
  command = plan

  assert {
    condition     = aws_subnet.app[0].map_public_ip_on_launch == false
    error_message = "App subnets should not have public IP"
  }
}

run "db_subnets_are_private" {
  command = plan

  assert {
    condition     = aws_subnet.db[0].map_public_ip_on_launch == false
    error_message = "DB subnets should not have public IP"
  }
}

run "creates_nat_gateway_per_az" {
  command = plan

  assert {
    condition     = length(aws_nat_gateway.main) == 2
    error_message = "Should create one NAT gateway per AZ"
  }
}

run "creates_eip_per_nat" {
  command = plan

  assert {
    condition     = length(aws_eip.nat) == 2
    error_message = "Should create one EIP per NAT gateway"
  }
}

run "public_route_table_routes_to_igw" {
  command = plan

  assert {
    condition     = aws_route_table.public.route[0].cidr_block == "0.0.0.0/0"
    error_message = "Public route table should have default route"
  }
}

run "app_route_tables_per_az" {
  command = plan

  assert {
    condition     = length(aws_route_table.app) == 2
    error_message = "Should create one app route table per AZ"
  }
}
