resource "null_resource" "chef-reg" {
  count = "${var.n_count}"
  provisioner "chef" {
    environment = "${var.chef_environment}"
    fetch_chef_certificates = true
    run_list = ["${var.run_list}"]
    node_name = "${trimspace(element(var.nodes, count.index))}"
    server_url = "${var.chef_server_url}"
    validation_client_name = "chef-validator"
    validation_key = "${file("${path.module}/chef-validator.pem")}"
  }

  connection {
    host = "${trimspace(element(var.ips, count.index))}"
    user = "Administrator"
    type = "winrm"
    password = "${var.admin_passwd}"
    timeout = "15m"
  }
}

resource "template_file" "user-data" {
  template = <<EOF
<powershell>
Get-NetFirewallPortFilter | ?{$_.LocalPort -eq 5985 } | Get-NetFirewallRule | ?{ $_.Direction -eq 'Inbound' -and $_.Profile -eq 'Public' -and $_.Action -eq 'Allow'} | Set-NetFirewallRule -RemoteAddress 'Any'
Enable-PSRemoting -Force -SkipNetworkProfileCheck
& winrm.cmd set winrm/config '@{MaxTimeoutms="1800000"}' >> $logfile
& winrm.cmd set winrm/config/winrs "'@{MaxMemoryPerShellMB=1024}' ">> $logfile
& winrm.cmd set winrm/config/winrs '@{MaxShellsPerUser="50"}' >> $logfile
& winrm.cmd set winrm/config/service/auth '@{Basic="true"}' >> $logfile
& winrm.cmd set winrm/config/service '@{AllowUnencrypted="true"}' >> $logfile
& winrm.cmd set winrm/config/winrs "'@{MaxMemoryPerShellMB=1024}' ">> $logfile
& netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" profile=public protocol=tcp localport=5985 remoteip=localsubnet new remoteip=any >> $logfile
& netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow >> $logfile
& net stop winrm
& net start winrm
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${passwd}")
</powershell>
EOF
  vars {
    passwd = "${var.admin_passwd}"
  }
}

output "user_data" {
  value = "${template_file.user-data.rendered}"
}
