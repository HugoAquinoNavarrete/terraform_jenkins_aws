# Integración de Terraform con Ansible para la ejecución de Playbooks aplicados a un inventario dinámico para curso de Jenkins

Script en Terraform que automatiza el despliegue en AWS n instancias EC2 tipo ubuntu y windows con acceso a internet que permiten tráfico SSH, HTTP y HTTPS con el cual a través de un archivo se puede integrar con Ansible para ejecutar Playbooks

## 1. Configura AWS (este script corre en la región "us-west-2")
Antes de ejecutar este script, ejecuta `aws configure` para habilitar
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name 
   - Default output format (json,yaml,yaml-stream,text,table)

## 2. El script generará la llave privada
El archivo se llamará `key_lab_jenkins`

## 3. Conexión por SSH a la máquina virtual 
   ```bash
   ssh -v -l ubuntu -i key_lab_jenkins <ip_publica_instancia_ec2>
   ```

## 4. Script compatible con la versión de Terraform v0.13.5, estos son los pasos para descargarlo e instalarlo
   ```bash
  wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
  unzip terraform_0.13.5_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  terraform --version 
   ```

## 5. Si es la primera vez que corres el script, ejecuta `terraform init`

## 6. Para ejecutar el script `terraform apply -var "nombre_instancia=<nombre_recursos>" -var "cantidad_instancias_ubuntu=<n>" -var "cantidad_instancias_windows=<n>" -var "subred_id=<subred_id>" -var "sg_id=<sg_id>" -auto-approve`. El script te pedirá le facilites los valores del ID de la subred así como el del security group:

   ```bash
   var.sg_id
     Enter a value: 

   var.subred_id
     Enter a value: 
   ```

Una vez el script se ejecuta generará un mensaje parecido a esto:

   ```bash
   Apply complete! Resources: <cantidad_recursos> added, 0 changed, 0 destroyed.
   ```

## 7. Una vez ejecutado el script, se crearán dos archivos que contienen el inventario ubuntu `ansible_inventario.txt` y el inventario windows `ansible_inventario_win.txt`, ve su contenido usando el comando `cat ansible_inventario.txt` o `cat ansible_inventario_win.txt`

## 8. Para eliminar la infraestructura desplegada, ejecuta `terraform destroy -var "subred_id=<subred_id>" -var "sg_id=<sg_id>" -auto-approve`:

El script una vez ejecutado generará un mensaje parecido a esto:

   ```bash
   Destroy complete! Resources: <cantidad_recursos> destroyed.
   ```

## 9. Valida en el portal de AWS que los recursos se hayan eliminado
Las instancias EC2 deberan aparecen con estado `Terminated` y después de algunos minutos desaparecerán de la consola
