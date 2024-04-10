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
# HTTP related variables
variable "enabled_http" {
  description = "Whether HTTP is enabled or not"
}

variable "protocol" {
  description = "Protocol to be used"
}

variable "port_allowed" {
  description = "Port to be used"
}

# SSH related variables
variable "block_ssh" {
  description = "Whether SSH access is blocked or not"
}

variable "disable_port" {
  description = "Whether the port should be disabled or not"
}

# Networking related variables
variable "source_ranges" {
  description = "Source IP ranges for network rules"
}

variable "target_tags" {
  description = "Target tags for network rules"
}

variable "tags" {
  description = "Tags associated with the resources"
}

# VM related variables
variable "webapp_VM_Name" {
  description = "Name of the virtual machine"
}

variable "machinetype" {
  description = "Type of machine"
}

variable "zone" {
  description = "Zone where the VM will be deployed"
}

variable "image" {
  description = "Image to be used for the VM"
}

variable "disksize" {
  description = "Size of the disk for the VM"
}

variable "disktype" {
  description = "Type of disk for the VM"
}

# Service account related variables
variable "service_email" {
  description = "Email address associated with the service account"
}

variable "scope" {
  description = "Scope of the service account"
}
variable "global_address_name"  {
  description = "global compute address name"
}   
variable "global_address_type"{
  description = "global address type"
}    
variable "global_address_purpose"{
  description = "global compute address purpose"
} 
variable "global_prefix_length"{
  description = "global address prefix length"
}   
variable "web_dbname" {
  description = "web app database instance name"
}             
variable "db_version"{
  description = "database version"
}        
variable "db_tier"{
  description = "databse tier"
}         
variable "db_availability"{
  description = "database instance availability type"
}   
variable "db_disktype"{
  description = "disk type"
}         
variable "db_disk_resize"{
  description = "disk resize"
}       
variable "db_disk_size"{
  description = "disk size"
}               
variable "db_backup_enable"{
  description = "db backup"
}                    
variable "db_binary_log"{
  description = "db binary"
}                         
variable "db_ipv4_enable"{
  description = "ipv4 enable"
}                        
variable "database_name"{
  description = "dbname"
}                          
variable "database_pass_special"{
  description = "dbpass"
}                  
variable "database_pass_length"{
  description = "dbpass length"
}
variable "DBNAME" {
  description = "DBNAME"
}
variable "dns_name"{
  description = "Dns Name"
} 
variable "dns_type"{
  description = "Dns type"
}  
variable "dns_managed_zone"{
  description = "Dns Zone"
} 
variable "dns_ttl"{
  description = "Dns ttl"
} 
variable "account_id"{
  description = "Service Account Id"
} 
variable "display_name"{
  description = "Service Account Display Name"
} 
variable "log_role"{
  description = "Dns Name"
} 
variable "monitor_role" {
  description = "Monitor Role"
}
variable "pubsub_role" {
  description = "Monitor Role"
}
variable "pubsub_topic_name" {
  description = "Monitor Role"
}
variable "pubsub_subscription_name" {
  description = "pubsub subscription name"
}
variable "serverless_connector_name" {
  description = "serverless connector name"
}
variable "ack_seconds" {
  description = "ack_deadline_seconds"
}
variable "message_duration" {
  description = "message retention suration"
}
variable "sub_expire" {
  description = "expiration policy ttl"
}
variable "bucket_name" {
  description = "cloud bucket name"
}
variable "bucket_location" {
  description = "location of bucket"
}
variable "bucket_object_name" {
  description = "bucket oject name"
}
variable "bucket_source" {
  description = "file path"
}
variable "pubsub_sub_bind" {
  description = "google pubsub subscription iam binding"
}
variable "subscription_members" {
  description = "members"
}
variable "connector_ipcidr" {
  description = "Ip cidr for connector"
}
variable "min_no" {
  description = "minimum number of instance"
}
variable "max_no" {
  description = "maximum nuber of instance"
}
variable "variable_machinetype" {
  description = "machine type for connector"
}
variable "cloud_function" {
  description = "Cloud function name"
}
variable "cloud_function_description" {
  description = "description"
}
variable "function_entry"{
description = "function entry point"
}
variable "function_runtime" {
  description = "function runtime"
}
variable "function_max_instance_count" {
  description = "max no of instance count"
}
variable "function_memory" {
  description = "function memory"
}
variable "function_timeout" {
  description = "function time out"
}
variable "function_egress" {
  description = "vpc_connector_egress_settings"
}
variable "function_retry_policy" {
  description = "function retry policy"
}
variable "mailgun_api_key" {
  description = "mailgun api key"
}
variable "domain_name" {
  description = "domain_name"
}
variable "lb_forwarding_rule" {
  description = "forearding rule for load balancing"
}
variable "forwarding_protocol" {
  description = "forwarding rule protocol"
}
variable "lb_forwarding_schema" {
  description = "loadbalancing schema"
}
variable "lb_forwarding_port" {
  description = "forwarding "
}
variable "https_proxy_name" {
  description = "https proxy name"
}
variable "domain_names" {
  description = "domain name for ssl certificate"
}
variable "https_proxy_description" {
  description = "https proxy descrption"
}
variable "ssl_certificate_name" {
  description = "ssl certificate name"
}
variable "url_mapping_name" {
  description = "url map id name name"
}
variable "lb_balanced_mode" {
  description = "lb balanced mode"
}
variable "backend_named_port" {
  description = "backend named port"
}
variable "backend_timeout" {
  description = "backend timout"
}
variable "backend_session_affinity" {
  description = "session_affinity"
}
variable "backend_protocol" {
  description = "backend protocol "
}
variable "backend_name" {
  description = "backend name"
}
variable "auto_scaler_name" {
  description = "auto sclaer name"
}
variable "auto_scaler_max" {
  description = "auto scaler max replicas"
}
variable "auto_scaler_min" {
  description = "auto sclaer minimum repica"
}
variable "auto_scaler_cooldown" {
  description = "autosclaer cooldown"
}
variable "autoscaler_cpu_utilization" {
  description = "autoscaler cpu utilization"
}
variable "group_manager_basename" {
  description = "group mabager vm base name"
}
variable "group_manager_primary_version" {
  description = "group mabager vm base name"
}
variable "nameport_port" {
  description = "named port "
}
variable "group_manager_name" {
  description = "group mabager  name"
}
variable "health_firewall_name" {
  description = "health check fire wall"
}
variable "health_fire_protocol" {
  description = "health_fire_protocol"
}
variable "health_fire_ports" {
  description = "health_fire_ports"
}
variable "health_fire_direction" {
  description = "direction firewall"
}
variable "health_fire_priority" {
  description = "health_fire_priority"
}
variable "health_fire_source_range" {
  description = "health_fire_source_range"
}
variable "health_fire_target_tags" {
  description = "health_fire_target_tags"
}
variable "template_machine_type" {
  description = "instance template machine type"
}
variable "template_instance_type" {
  description = "template_instance_type"
}
variable "template_instance_mode" {
  description = "template_instance_mode"
}
variable "template_instance_devicename" {
  description = "template_instance_devicename"
}
variable "template_instance_name" {
  description = "template_instance_name"
}
variable "template_instance_auto_delete" {
  description = "template_instance_auto_delete"
}
variable "template_instance_boot" {
  description = "template_instance_boot"
}
variable "cloud_function_name" {
  description = "cloud_function_name"
}
variable "cloud_function_decription" {
  description = "cloud_function_decription"
}
variable "cloud_function_entrypoint" {
  description = "cloud_function_entrypoint"
}
variable "cloud_function_runtinme" {
  description = "cloud_function_runtinme"
}
variable "cloud_function_available_memory" {
  description = "cloud_function_available_memory"
}
variable "cloud_function_timeout" {
  description = "cloud_function_timeout"
}
variable "cloud_function_vpc_engress" {
  description = "cloud_function_vpc_engress"
}
variable "cloud_function_event_retrypolicy" {
  description = "cloud_function_event_retrypolicy"
}
variable "cloud_function_instance_count" {
  description = "cloud_function_instance_count"
}
variable "health_checker_name" {
  description = "name for health_checker"
}
variable "health_checker_time_check_interval" {
  description = "health_checker_time_check_interval"
}

variable "health_checker_time_out" {
  description = "health_checker_time_out"
}
variable "health_checker_healthy_vm_threshold" {
  description = "health_checker_healthy_vm_threshold"
}
variable "health_checker_unhealthy_vm_threshold" {
  description = "health_checker_unhealthy_vm_threshold"
}
variable "health_checker_http_endpoint_port" {
  description = "health_checker_http_endpoint_port"
}
variable "health_checker_http_endpoint_path" {
  description = "health_checker_http_endpoint_path"
}
variable "health_checker_http_endpoint_port_speci" {
  description = "health_checker_http_endpoint_port_speci"
}
variable "health_checker_http_endpoint_proxy_h"{
description = "health_checker_http_endpoint_proxy_h"
}
variable "insatnce_template_webapp" {
  description = "insatnce_template_webapp"
}
variable "insatnce_template_disk_autodelete" {
  description = "insatnce_template_disk_autodelete"
}
variable "instance_template_disk_boot" {
  description = "instance_template_disk_boot"
}
variable "instance_template_disk_device" {
  description = "instance_template_disk_device"
}
variable "instance_template_disk_mode" {
  description = "instance_template_disk_mode"
}
variable "instance_template_disk_type" {
  description = "instance_template_disk_type"
}
variable "instance_template_machine_type" {
  description = "machine type for template"
}

variable "gorup_manager_named_port_name" {
  description = "gorup_manager_named_port_name"
}
variable "gorup_manager_named_port_port" {
  description = "gorup_manager_named_port_port"
}
variable "webapp_instance_tags" {
  description = "webapp_instance_tags"
}
variable "lb_logs" {
  description = "logs for load balancer"
}
variable "lb_log_rate" {
  description = "logs rate for load balancer"
}
variable "keychain_sql_serviceAccount" {
  description = "keychain service account"
}
variable "keychain_sql_serviceAccount_des" {
  description = "keychain service account"
}
variable "keychain_sql_serviceAccount_role" {
  description = "keychain_sql_serviceAccount role"
}
variable "csye_key_ring_name" {
  description = "Key ring name "
}
variable "vm_key_name" {
  description = "vm key name"
}
variable "storage_key_name" {
  description = "strogae key name"
}
variable "sql_instance_key_name" {
  description = "sql strogae key name"
}
variable "key_rotation" {
  description = "key rotation days"
}
variable "key_purpose" {
  description = "key purpose "
}
variable "stroage_member_email" {
  description = "service account used in storage key crypto binding "
}
variable "vm_member_email" {
  description = "service account used in VM key crypto binding"
}
