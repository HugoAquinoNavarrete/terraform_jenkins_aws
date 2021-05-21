# Script en Terraform para desplegar en AWS n instancias EC2 tipo ubuntu y windows server
# con acceso a internet que permiten tráfico SSH, HTTP, HTTPS, RDP, WINRM
# que logra integrarse con Ansible al generar un archivo dinámico de inventario (ubuntu y windows server)
# utilizado para curso de Jenkins, el script instala python para su uso con Ansible
# Hugo Aquino
# Mayo 2021

# Antes de ejecutar este script, ejecuta "aws configure" para poder habilitar
# AWS Access Key ID
# AWS Secret Access Key
# Default region name
# Default output format (YAML)

# El script creará la llave privada y cambiará el permiso a 400 al archivo de la llave

# Para conectarte con la VM una vez creada
# ssh -v -l ubuntu -i key <ip_publica_instancia_creada> 

# Para correr este script desde la consola:
# terraform apply -var "nombre_instancia=<nombre_recursos>" -var "cantidad_instancias_ubuntu=<n>" -var "cantidad_instancias_windows=<n>" -var "subred_id=<subred_id>" -var "sg_id=<sg_id>"-auto-approve

# Variable para saber cuantas instancias ubuntu crear
variable cantidad_instancias_ubuntu {
  default = 1
}

# Variable para saber cuantas instancias windows crear
variable cantidad_instancias_windows {
  default = 1
}

# Para ajustar el nombre de los recursos hay que cambiar el valor de la siguiente variable al nombre que desees "default = <nombre>"
variable nombre_instancia {
  default = "lab"
}

# Para ajustar el subred ID hay que indicar el valor del ID de la subred previamente creada"
variable subred_id {
  default = "subnet"
}

# Para ajustar el security group ID hay que indicar el valor del ID del security group previamente creado"
variable sg_id {
  default = "sg"
}

# Haremos despliegue en AWS
provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

# Veamos la creación automática de la llave privada
variable "key_name" {
   default = "key_lab_jenkins"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner local-exec { 
    command = "echo '${self.private_key_pem}' > ./key_lab_jenkins"
  }

  provisioner "local-exec" {
    command = "chmod 600 ./key_lab_jenkins"
  }

}

resource "aws_key_pair" "key_lab_jenkins" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}

# Crea n instancias Ubuntu
resource "aws_instance" "ubuntu" {
  count                       = var.cantidad_instancias_ubuntu
  ami                         = "ami-0d1cd67c26f5fca19"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.key_lab_jenkins.key_name
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subred_id
  associate_public_ip_address = "true"

  root_block_device {
    volume_size           = "10"
    volume_type           = "standard"
    delete_on_termination = "true"
  }

  connection {
    host = self.public_ip
    user = "ubuntu"
    private_key = file("./key_lab_jenkins")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y python"
    ]
  }

  tags = {
    Name = "${var.nombre_instancia}-${count.index + 1}"
  }

}

# Creemos una contraseña temporal
resource "random_string" "winrm_password" {
  length = 10
  special = false
}

output "password_data" {
  description = "List of Base-64 encoded encrypted password data for the instance"
  value       = random_string.winrm_password.result
}

# User-data
data "template_file" "user_data" {
  template = file("./windows.tpl")

  vars = {
    password = random_string.winrm_password.result
  }
}

# Crea n instancias Windows
resource "aws_instance" "windows" {
  count                       = var.cantidad_instancias_windows
  ami                         = "ami-0763b8ab71c00da54"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.key_lab_jenkins.key_name
  user_data                   = data.template_file.user_data.rendered
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subred_id
  associate_public_ip_address = "true"
  get_password_data           = "true"

  root_block_device {
    volume_size           = "100"
    volume_type           = "standard"
    delete_on_termination = "true"
  }

  connection {
    password              = rsadecrypt(self.password_data,file("key_lab_jenkins"))
  }

  tags = {
    Name = "${var.nombre_instancia}-win-${count.index + 1}"
  }

}
