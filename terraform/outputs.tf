resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/hosts.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    nodes = {
      for name, instance in aws_instance.nodes :
      name => {
        role       = instance.tags.Role
        public_ip  = instance.public_ip
        private_ip = instance.private_ip
      }
    }
  })

  depends_on = [aws_instance.nodes]
}

output "public_ips" {
  description = "IPs publicos das instancias"
  value = {
    for name, instance in aws_instance.nodes :
    name => instance.public_ip
  }
}

output "private_ips" {
  description = "IPs privados das instancias"
  value = {
    for name, instance in aws_instance.nodes :
    name => instance.private_ip
  }
}

output "instance_ids" {
  description = "IDs das instancias"
  value = {
    for name, instance in aws_instance.nodes :
    name => instance.id
  }
}