variable "domain_name" {
  description = "Domain name for ACM cert"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "tags" {
  description = "Tags map"
  type        = map(string)
}
