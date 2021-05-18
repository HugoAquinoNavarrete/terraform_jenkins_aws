# Inventario para Ansible
resource "local_file" "InventarioAnsible" {
  content = templatefile("inventario.tpl",
  {
    public-dns = aws_instance.ubuntu.*.public_dns,
    public-ip  = aws_instance.ubuntu.*.public_ip,
    public-id  = aws_instance.ubuntu.*.id
  }
  )
  filename = "ansible_inventario.txt"
  file_permission = "600"
}

