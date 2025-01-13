# These are just so warnings don't appear
# when the demo is run on TF Cloud.
variable "AWS_SECRET_ACCESS_KEY" {
  type    = string
  default = ""
}
variable "AWS_ACCESS_KEY_ID" {
  type    = string
  default = ""
}
