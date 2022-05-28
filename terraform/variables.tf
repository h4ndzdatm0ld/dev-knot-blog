#
# variables
###

variable "region" {
  default = "us-west-2"
  type    = string
}

variable "blog_domain" {
  default = "dev-knot.com"
  type    = string
}

variable "repository" {
  default = "https://github.com/h4ndzdatm0ld/dev-knot-blog"
  type    = string
}

variable "blog_name" {
  default = "Dev-Knot Blog"
  type    = string
}

variable "gh_access_token" {
  type = string
}
