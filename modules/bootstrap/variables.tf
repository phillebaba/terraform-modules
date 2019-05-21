variable "name" {
  type        = "string"
  description = "Base name of infrastructure"
}

variable "deletion_window_in_days" {
  default = 30
}
