variable "chef_environment" {
  Description = "environment for Chef"  #TODO:  limit to valid environments??
  default = "Sandbox"
}

variable "run_list" {
  Description = "run_list to apply to node"
  type = "list"
  default = ["users"]
}

variable "aws_run_list" {
  Description = "base run-list to add to all instances"
  type = "list"
  default = ["Role-AWS"]
}

variable "n_count" {
  Description = "Count of Nodes being registered"
  default = "1"
}

variable "nodes" {
  Description = "Comma separated list of node names of nodes to put in Chef.  Must match number and order of ips"
  type = "list"
}

variable "ips" {
  description = "Comma separated list of IP's of nodes, must match number and order of nodes"
  type = "list"
}

variable "attributes_json" {
  description = "JSON string to use as initial attributes for the node"
  default = "{}"
}

variable "chef_server_url" {
  description = "URL used to connect to the Chef Server."
  default = "YOUR_SERVER_URL_HERE"
}

variable "ssh-key" {
  description = "User ssh key to be used to connect to node"
}
