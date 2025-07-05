variable "env_map" {
  description = "Map of env parameters to store in SSM"
  type        = map(string)
}

variable "path_prefix" {
  description = "Parameter store path prefix e.g. /myapp/dev"
  type        = string
}

variable "tags" {
  description = "Tags map"
  type        = map(string)
}