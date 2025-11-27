#
# variables
###

variable "blog_domain" {
  default = "dev-knot.com"
  type    = string
}

variable "repository" {
  default = "https://github.com/h4ndzdatm0ld/dev-knot-blog"
  type    = string
}

variable "blog_name" {
  default = "Dev-Knot-Blog"
  type    = string
}

variable "hugo_version" {
  description = "The version of Hugo to use"
  type        = string
  default     = "0.112.7"  // replace with the version you want
}

variable "gh_access_token" {
  type = string
}
