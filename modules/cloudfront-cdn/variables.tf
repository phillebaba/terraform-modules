variable "tags" {
  type        = "map"
  default     = {}
  description = "Tags to append to resources"
}

variable "domain_name" {
  description = "Domain name to link to the CloudFront distribution"
  type = "string"
}

variable "origin_domain_name" {
  description = "Domain name for CloudFront origin"
  type = "string"
}

variable "origin_id" {
  description = "Origin id sent by CloudFront to the target"
  default = ""
}

variable "price_class" {
  description = "Price class for CloudFront distribution"
  default = "PriceClass_100"
}
