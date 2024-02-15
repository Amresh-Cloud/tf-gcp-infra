variable "vpc_network_name" {
  description = "Name of the VPC network"
  default     = "amresh"
}

variable "webapp_subnet_name" {
  description = "Name of the webapp subnet"
  default     = "webapp"
}

variable "db_subnet_name" {
  description = "Name of the database subnet"
  default     = "db"
}

variable "webapp_subnet_cidr" {
  description = "CIDR range for the webapp subnet"
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR range for the database subnet"
  default     = "10.0.2.0/24"
}

variable "region" {
  description = "Google Cloud region"
  default     = "us-east1"
}

variable "dest_range" {
  description = "Destination CIDR range for the route"
  default     = "0.0.0.0/0"
}

variable "next_hop_gateway_default" {
  description = "Next hop gateway for the route"
  default     = "default-internet-gateway"
}

variable "credentials_file_path" {
  description = "Path to the Google Cloud credentials JSON file"
}

variable "project_id" {
  description = "Google Cloud Project ID"
}
variable "webapp_internet_route" {
  description = "Webapp internet route"
  default     = "webapp-internet-route"
}
variable "autocreate_subnet" {
  description = "autocreate subnet true or false"
  default     = false
}
variable "Routing_mode" {
  description = "Routing mode regional ?"
  default     = "REGIONAL"
}

