# Integración de Terraform con Ansible para la ejecución de Playbooks aplicados a un inventario dinámico para curso de Jenkins

Script en Terraform que automatiza el despliegue en AWS n instancias EC2 tipo ubuntu y windows con acceso a internet que permiten tráfico SSH, HTTP, HTTPS, RDP y WINRM con el cual a través de un archivo se puede integrar con Ansible para ejecutar Playbooks

## 1. Configura AWS (este script corre en la región "us-west-2")
Antes de ejecutar este script, ejecuta `aws configure` para habilitar
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name 
   - Default output format (json,yaml,yaml-stream,text,table)

## 2. Para generar una llave hay que hacer los siguientes ajustes en el archivo `main.tf` ajustando `<nombre_llave>` con el nombre que deseas tenga la llave privada
Línea 55
   - Aparece `default = "<nombre_llave>"`, cambia `<nombre_llave>` con el nombre (sin espacios) que deseas tenga la llave

Línea 72
   - Aparece `resource "aws_key_pair" "<nombre_llave>" {`, cambia `<nombre_llave>` con el nombre (sin espacios y dejando las comillas al inicio y final del nombre) que deseas tenga la llave

Línea 82
   - Aparece `key_name = aws_key_pair.<nombre_llave>.key_name`, cambia `<nombre_llave>` con el nombre (sin espacios) que deseas tenga la llave

Línea 137
   - Aparece `key_name = aws_key_pair.<nombre_llave>.key_name`, cambia `<nombre_llave>` con el nombre (sin espacios) que deseas tenga la llave

## 3. Una vez hechos los cambios al archivo `main.tf`, hay que hacer un `commit` al repositorio
   ```bash
   git add main.tf
   git commit -m "Ajustes en main.tf para reflejar cambios en el nombre de la llave privada"
   git push
   ```

## 4. Conexión por SSH a la máquina virtual 
   ```bash
   ssh -v -l ubuntu -i <nombre_llave> <ip_publica_instancia_ec2>
   ```

## 5. Script compatible con la versión de Terraform v0.13.5, estos son los pasos para descargarlo e instalarlo
   ```bash
  wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
  unzip terraform_0.13.5_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  terraform --version 
   ```

## 6. Si es la primera vez que corres el script, ejecuta `terraform init`

## 7. Para ejecutar el script `terraform apply -var "nombre_instancia=<nombre_recursos>" -var "cantidad_instancias_ubuntu=<n>" -var "cantidad_instancias_windows=<n>" -var "subred_id=<subred_id>" -var "sg_id=<sg_id>" -var "key_name=<nombre_llave>" -auto-approve`. El script te pedirá le facilites los valores del ID de la subred así como el del security group y el nombre de la llave:

   ```bash
   var.sg_id
     Enter a value: 

   var.subred_id
     Enter a value: 

   var.key_name
     Enter a value:

   ```

Una vez el script se ejecuta generará un mensaje parecido a esto:

   ```bash
   Apply complete! Resources: <cantidad_recursos> added, 0 changed, 0 destroyed.
   ```

## 8. Una vez ejecutado el script, se crearán dos archivos que contienen el inventario ubuntu `ansible_inventario.txt` y el inventario windows `ansible_inventario_win.txt`, ve su contenido usando el comando `cat ansible_inventario.txt` o `cat ansible_inventario_win.txt`

## 9. Para eliminar la infraestructura desplegada, ejecuta `terraform destroy -var "subred_id=<subred_id>" -var "sg_id=<sg_id>" -auto-approve`:

El script una vez ejecutado generará un mensaje parecido a esto:

   ```bash
   Destroy complete! Resources: <cantidad_recursos> destroyed.
   ```

## 10. Valida en el portal de AWS que los recursos se hayan eliminado
Las instancias EC2 deberan aparecen con estado `Terminated` y después de algunos minutos desaparecerán de la consola
