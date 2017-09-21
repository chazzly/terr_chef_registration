# Terraform Wondows Chef Module
This modules helps ensure consistent connections to our Chef server when setting up Windows Servers via Terraform.  

## Requirements
Terraform v >= 7.0

This module requires lists as variables.  This capability is only availible in Terraform 7.0 or above.  Download the latest version from www.terraform.io

In order to connect to your chef server(s), this module requires
- chef-validator.pem file for use as the server certificate during the initial connection.
- setting the variable "chef_server_url" to the url of your chef server.


## Usage
To use this module, you will need to supply a password for the Administrator account with as `admin_passwd`.  This is required to Set the Administrator password on the node, then use it to connect via win_rm.

As with the Linux Chef Module (see the 'linux' folder within this module), you will need to supply a count of nodes being set-up, lists of node names and Ip's.  The count is assumed to be 1 if not present. Both the node and ip lists (as variable type 'list')are required.

In the example below, the node with IP 172.28.33.10 will be given the name "example", 172.28.33.11 "another_example", etc.

    module "chef_registration" {
      source = "git::https://github.com/chazzly/terr_chef_registration//windows"  ## NOTE:  double slashes (//) before 'windows' is intentional.
      nodes = ["example","another_example","example3"]
      ips = ["172.28.33.10", "172.28,33.11", "172.28.33.12"]
      admin_passwd = "DumbPassword"
      n_count = 3
    }


Of course, hardcoding IP addresses and passwords is never a good idea, so this can easily be pulled from data already part of the instance definition, or from more secured variables.

You will also need to reference the modules `user_data` property, and pass this as the `user_data` property in your `aws_instance` resource.  This passes a small powershell script which does a number or things required for Chef configuration of a winsows node.
- Sets Administrator password to the one provided.
- Sets Windows firewall rules to allow Chef client to communicate with the Chef Server.
- Turns on the win_rm service, which is then used to install and run the chef-client


### Example:

    resource "aws_instance" "win_example" {
      ....
      user_data = "${module.chef_registration.user_data}"
      tags {
        Name = "win_example"
      }
    }
    
    resource "aws_instance" "another_win_example" {
      ....
      user_data = "${module.chef_registration.user_data}"
      tags {
        Name = "win_example"
      }
    }

    module "chef_registration" {
      source = "git::https://github.com/chazzly/terr_chef_registration//windows"
      nodes = ["${aws_instance.win_example.tags.Name}", "${aws_instance.another_win_example.tags.Name}"]
      ips = ["${aws_instance.win_example.private_ip}", "${aws_instance.another_win_example.private_ip}"]
      n_count = 2
      admin_passwd = "${var.admin_passwd}"
    }

### Using with resource count
Terraform must avoid any circular configurations (A depends on B, B depends on C, C depends on A).  To avoid that when using this module, the n_count variable **CANNOT** be derived from the aws_instance resources.
The easiest way to avoid this is to extract the count as a variable, and use the same variable in both places.  Example:

    resource "aws_instance" "example" {
      count =  "${var.count}"
      ....
      tags {
        Name = "example-${count.index}"
      }
      user_data = "${module.chef_registration.user_data}"
    }
    
    module "chef_registration" {
      source = "git::https://github.com/chazzly/terr_chef_registration//windows"
      nodes = ["${aws_instance.example.*.tags.Name}"]
      ips = ["${aws_instance.example.*.private_ip}"]
      n_count = "${var.count}"
    }



## Run-lists and Environment
You can optionally supply a run list or chef environment for the node(s) by passing the variables `run_list` & `chef_environment` respectively.  These will be applied to all nodes included in the module call. 

The `run_list` should be comma-separated list of recipes if unspecified the "users" cookbook will be used.  

The `chef_environment` must be one of the currently defined environments.  If unspecified, "Sandbox" will be used.

### Example

    module "chef_registration" {
      source = "git::https://github.com/chazzly/terr_chef_registration//windows"
      nodes = "my_node"
      ips = "${aws_instance.my_node.private_ip}"
      run_list = "Role-BaseServer, jenkins::build_slave"
      chef_environment = "Staging"
    }

## Removing a node
Currently, Terraform does not have a way to remove nodes from the chef server (this is an open request https://github.com/hashicorp/terraform/issues/3605, but it doesn't look like it's going to happen soon).
So, If in the course of your work, nodes are destroyed and re-added, the node & client will need to be removed from the Chef Server.  We are working on a way to make this easier, but here are the current work-around.

### If node is still active:
From the node being destroyed, run the following commands in this order (as root or a user with sudo rights):

    knife node delete <node-name> -y -c c:\chef\client.rb 
    knife client delete <node-name> -y -c c:\chef\client.rb 

### If node has already been destroyed:
Contact Linux Engineering to have the node removed.
