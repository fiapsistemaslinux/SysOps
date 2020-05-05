##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L04_wordpress_logo.png)

Imagem de: [https://br.wordpress.org/about/logos/](https://br.wordpress.org/about/logos/), Licenciada por: [Trademark Policy](http://wordpressfoundation.org/trademark-policy/);

# Laboratório: Contruindo um stack Lamp completo

**Consolidando alguns conceitos:**

* Configuração de usuários
* Permissões de acesso
* Instalação de pacotes
* Configuração de serviços
* Configuração de Volumes/LVM

## 1. Configurando o Usuário de Acesso:

Precisamos criar um usuário com o perfil de desenvolvimento que acessará o servidor de aplicação:

* 1.1 Configure este usuário com o username **sysops** e com permissões administrativas via sudo:

```sh
useradd sysops -m -d /home/sysops -G sudo
```

## 2. Configurando nosso Banco de Dados:

Em nossa abordagem com o objetivo de revisar alguns conteudos faremos a configuração manual de um repositório para obter os pacotes do SGBD mysql:

2.1 Adicione a chave GPG do novo repositório:
```sh
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5
```

2.2 Em seguida crie um arquivo com a referência para o repositório:
```sh
sudo su -
echo "deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7" > /etc/apt/sources.list.d/mysql.list  
```

2.3 Não executaremos uma instalação interativa do banco de dados por isso uma variável de ambiente será configurada antes de iniciar o processo:
```sh
export DEBIAN_FRONTEND=noninteractive
```

2.4 Em seguida instale a versão mais recente do pacote mysql e o servidor de conteúdo apache
```sh
sudo apt update -y
sudo apt install mysql-server php php-mysql apache2 -y
```

**Importante:** Este método objetiva garantir que a execução seja completamente feita pelo terminal sem interação o que por consequencia criará dois avisos de segurança:
> 1. mysqladmin: [Warning] Using a password on the command line interface can be insecure.

> 2. Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.

2.5 Para finalizar a primeira parte do LAB faremos um teste na configuração do servidor conteúdo:

```sh
cat <<EOF > /var/www/html/info.php
<?php
phpinfo();
?>
EOF
```

Acesse a URL da instancia na porta 80 na path /info.php o resultado deverá ser entregue conforme abaixo:

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L04_php.png)

---

## 3. Download do Wordpress:

3.1 Baixe a ultima versão do Wordpress:

```sh
mkdir /usr/local/src/wordpres
wget -P /usr/local/src/wordpres https://wordpress.org/latest.tar.gz
```

3.2 Faça a extração do wordpress para a raiz do servidor de conteúdo:

```sh
tar -xf /usr/local/src/wordpres/latest.tar.gz -C /var/www/html/
```

3.3 Altere as permissões de acesso ao conteúdo:

```sh
chown -R www-data:www-data /var/www/html/wordpress/
chmod -R 755 /var/www/html/wordpress/
```

3.4 Você já poderá acessar o servidor de conteúdo na URL da instancia na porta 80 na path /wordpress

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L04_wordpress_page.png)

## 4. Testando a aplicação:

**Para o banco de dados da aplicação executaremos a configuração a seguir:**

4.1 No formato sem a instalação interativa será necessário configurar a senha de acesso ao banco:

```sh
mysqladmin -u root password myrootpass
```

4.2 Acesse o banco de dados com as credenciais configuradas:
```sh
mysql -u root -P myrootpass 
```

4.3 Crie o banco de dados da aplicação:
```sh
CREATE DATABASE wordpress;
```

4.4 Em seguida crie o usuário de acesso ao banco:
```sh
CREATE USER 'sysops'@'localhost' IDENTIFIED BY 'mydatabasepass';
```

4.4.1 Edite as permissções de acesso do usuário
```sh
GRANT ALL ON wordpress.* TO 'dbadmin'@'localhost' IDENTIFIED BY 'mydatabasepass';
```

4.4.2 Execute um flush para atualizar a tabela de permissões e sai do banco:
```sh
FLUSH PRIVILEGES;
exit
```

4.5 Feito, agora na página do wordpress preencha as informações de configuração do banco e salve as alterações com os dados criados:

| Campo         | Valor           |
|---------------|-----------------|
| Database name | wordpress       |
| Username      | sysops          |
| Password      | mydatabasepass  |
| Database Host | localhost       |
| Table Prefix  | wp_             |

**O resultado será similar a este aqui:**

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L04_wordpress_done.png)


---

# Etapa Bônus

## 5. Configurando um volume para o Banco de Dados:

5.1. Neste exercício utilizaremos um volume próprio para o banco de dados, para isso identifique o disco extra adicionado a instância e execute o particionamento:
```sh
sudo cat /proc/partitions  | egrep -v 'xvda|loop'
```

5.2. Para evitar um comando interativo utilizaremos o sgdisk no particionamento:
```sh
sudo sgdisk -n 0:0:0 /dev/xvdh
```

5.3. Verifique se a configuração foi executada com sucesso:
```sh
sudo fdisk -l /dev/xvdh
```

5.4. Em seguida aplique um filesystem (neste LAB ext4) na nova partição:
```sh
sudo mkfs.ext4 /dev/xvdh1
```

5.5. Pare a aplicação para este teste: 
```sh
systemctl stop mysql
```

5.5.1. Monte o volume que foi formatado:
```sh
mount /dev/xvdh1 /mnt
```

5.5.2. Faça uma cópia do conteúdo do banco após montar o volume:
```sh
cp -av /var/lib/mysql/* /mnt/ && umount /mnt
```

5.8. Após configurar o novo volume adicionaremos uma entrada no fstab com base no UUID:
```sh
export UUID=$(blkid -o value -s UUID /dev/xvdh1)
```

5.6 Em seguida construa a linha de configuração no arquivo **/etc/fstab** ele deverá ser montado na partição /var/lib/mysql
```sh
echo -e "# Wordpress db mount point \\nUUID=${UUID} /var/lib/mysql ext4 defaults 0 0" >> /etc/fstab
```

5.6 Remova o conteúdo do banco e substitua pelo novo banco de dados configurado:

```sh
rm -rf /var/lib/mysql/*
```

5.6.1 Faça um teste executando a montagem via "mount -a" o que ajudará a validar o conteúdo do arquivo /etc/fstab
```sh
mount -a
```

5.6.2 Verifique se a montagem ocorreu conforme esperado:
```sh
df -h
```

5.6.3 Após a execucação do processo reinicialize o serviço:
```sh
systemctl restart mysql
```

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L04_error.png)

**Exercício Rápido:**

É provavel que tenha ocorrido um erro na inicialização do serviço, seu trabalho será verificar se a aplicação subiu corretamente e corrigir qualquer erro que ocorra nesta etapa final;

---

## Material de Referência e Recomendações:

A abordagem utilizada neste exercício foi uma complicação criada com base no passo a passo de instalação do JournalDev:
* [How to install WordPress on Ubuntu 18.04](https://www.journaldev.com/24954/install-wordpress-on-ubuntu);
---

**Free Software, Hell Yeah!**
