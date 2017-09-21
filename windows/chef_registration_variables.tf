variable "chef_environment"{
  Description = "environment for Chef"  #TODO:  limit to valid environments??
  default = "Sandbox"
}

variable "run_list" {
  Description = "run_list to apply to node"
  type = "list"
  default = ["users"]
}

variable "n_count" {
  Description = "Count of Nodes being registered"
  default = "1"
}

variable "nodes" {
  type = "list"
  Description = "Comma separated list of node names of nodes to put in Chef.  Must match number and order of ips"
}

variable "ips" {
  type = "list"
  description = "Comma separated list of IP's of nodes, must match number and order of nodes"
}

variable "admin_passwd" {
  description = "Password for administrator account"
}

variable "attributes_json" {
  description = "JSON string to use as initial attributes for the node"
  default = "{}"
}

variable "chef_server_url" {
  description = "URL used to connect to the Chef Server."
  default = "YOUR_SERVER_URL_HERE"
}
