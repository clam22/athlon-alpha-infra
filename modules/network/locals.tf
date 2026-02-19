locals {
  public_subnets = {
    public_a = {
      cidr_block = "10.0.1.0/24"
      az         = "eu-north-1a"
    }

    public_b = {
      cidr_block = "10.0.2.0/24"
      az         = "eu-north-1b"
    }

    public_c = {
      cidr_block = "10.0.3.0/24"
      az         = "eu-north-1c"
    }
  }

  private_app_subnets = {
    private_app_a = {
      cidr_block = "10.0.11.0/24"
      az         = "eu-north-1a"
    }

    private_app_b = {
      cidr_block = "10.0.12.0/24"
      az         = "eu-north-1b"
    }

    private_app_c = {
      cidr_block = "10.0.13.0/24"
      az         = "eu-north-1c"
    }
  }

  private_data_subnets = {
    private_data_a = {
      cidr_block = "10.0.21.0/24"
      az         = "eu-north-1a"
    }

    private_data_b = {
      cidr_block = "10.0.22.0/24"
      az         = "eu-north-1b"
    }

    private_data_c = {
      cidr_block = "10.0.23.0/24"
      az         = "eu-north-1c"
    }
  }

}