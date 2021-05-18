# Inventario para Ansible
resource "local_file" "InventarioAnsibleWindows" {
  content = templatefile("inventario_win.tpl",
  {
    public-dns = aws_instance.windows.*.public_dns,
    public-ip  = aws_instance.windows.*.public_ip,
    public-id  = aws_instance.windows.*.id
    password   = random_string.winrm_password.result
  }
  )
  filename = "ansible_inventario_win.txt"
  file_permission = "400"
}

