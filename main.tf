module "assertion" {
  source = "plzdontbanme/assertion/null"
  //source = "../terraform-null-assertion"
  version = "0.1.0"

  condition     = (1 + 2 == 3)
  error_message = "Your math is invalid"
}

