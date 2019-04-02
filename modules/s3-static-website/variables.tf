variable "tags" {
  type        = "map"
  default     = {}
  description = "Tags to append to resources"
}

variable "domain_name" {
  type = "string"
}

variable "index_document" {
  type = "string"
}

variable "error_document" {
  type = "string"
}

variable "routing_rules" {
  description = ""
}
