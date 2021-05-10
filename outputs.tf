# Inventario para Ansible
resource "local_file" "InventarioAnsible" {
  content = templatefile("inventario.tpl",
  {
    public-dns = aws_instance.aws.*.public_dns,
    public-ip  = aws_instance.aws.*.public_ip,
    public-id  = aws_instance.aws.*.id
  }
  )
  filename = "ansible_inventario.txt"
  file_permission = "400"
}

