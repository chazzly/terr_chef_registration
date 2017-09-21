resource "null_resource" "chef-reg" {
  count = "${var.n_count}"
  provisioner "chef" {
    environment = "${var.chef_environment}"
    fetch_chef_certificates = true
    run_list = "${distinct(compact(concat(var.aws_run_list, var.run_list)))}"
    node_name = "${trimspace(element(var.nodes, count.index))}"
    server_url = "${var.chef_server_url}"
    validation_client_name = "chef-validator"
    validation_key = "${file("${path.module}/chef-validator.pem")}"
    attributes_json = "${var.attributes_json}"
    connection {
      host = "${trimspace(element(var.ips, count.index))}"
      user = "ec2-user"
      type = "ssh"
      private_key = "${ssh-key}"
    }
  }
}
