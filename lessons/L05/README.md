##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L04_wordpress_logo.png)

Imagem de: [https://br.wordpress.org/about/logos/](https://br.wordpress.org/about/logos/), Licenciada por: [Trademark Policy](http://wordpressfoundation.org/trademark-policy/);

# Laboratório: Convertendo uma arquitetura em containers

Overview sobre a arquitetura de containers: [An Overview of Docker Architecture](https://medium.com/better-programming/an-overview-to-docker-architecture-15407c482c52) criado por [Victor Suárez Fernández](https://medium.com/@vicsufer)

**Consolidando alguns conceitos:**

* Configurando aplicações em Docker
* Trabalhando com containers statefull
* Manipulação básica de rede e publicação de portas

> Neste laboratório converteremos todo o cenário criado no exercício anterior [L04](https://github.com/fiapsistemaslinux/SysOps/tree/master/lessons/L04) em containers, para essa finalidade utilizaremos um host com docker configurado e acesso a internet para download das imagens no docker hub.

## 1. Crie uma rede bridge no Docker usando o seguinte comando:

```sh
docker network create wordpress
```

1.1 Você pode inspecionar o status e a configuração da rede criada utilizando os comandos abaixo:

```sh
docker network
docker network ls
docker network inspect wordpress
```

## 2. Configurando um volume para a nossa aplicação:

Crie os seguintes volumes para guardar os dados do banco e o conteúdo estático da aplicação rodando em Wordpress usando os seguintes comandos de criação de volume do docker:

```sh
docker volume create www-data
docker volume create mysql-data
```

2.1 Utilize os comandos abaixo para inspecionar o volume configurado:

```sh
docker volume
docker volume ls
docker volume inspect mysql-data
ls /var/lib/docker/volumes/
```

## 3. Entregando o container de banco de dados: 

Lembrando da configuração usada para interconecção com o banco:


| Campo         | Valor           |
|---------------|-----------------|
| Database name | wordpress       |
| Username      | wordpress-adm   |
| Password      | mydatabasepass  |
| Database Host | localhost       |
| Table Prefix  | wp_             |

> Essa configuração será entregue utilizando a passagem de variaveis de configuração prevista para o mysql durante a execução do comando para instanciar o container;

Com base na configuração detalhada na [documentação do docker hub do projeto mysql](https://hub.docker.com/_/mysql) criaremos o container de banco de dados:

```sh
docker run -d --rm --name mysql-database \
  --privileged --network wordpress \
  --env MYSQL_ROOT_PASSWORD=myrootpass \
  --env MYSQL_DATABASE=wordpress \
  --env MYSQL_USER=wordpress-adm \
  --env MYSQL_PASSWORD=mydatabasepass \
  --volume mysql-data:/var/lib/mysql mysql:5.7
```
---

## 4. Entregando o container com o Wordpress: 

Com base na configuração detalhada na [documentação do docker hub do projeto worpdres](https://hub.docker.com/_/wordpress/) criaremos o container da aplicação:

```sh
docker run -d --rm --name wordpress-app \
  --privileged --network wordpress \
  --env WORDPRESS_DB_USER=wordpress-adm \
  --env WORDPRESS_DB_PASSWORD=mydatabasepass \
  --env WORDPRESS_DB_NAME=wordpress \
  --env WORDPRESS_DB_HOST=mysql-database \
  --restart unless-stopped \
  --publish 80:80 wordpress
```

---

# Etapa Bônus

## 5. O que acontecerá se reiniciarmos o docker?

E se reiniciarmos o servidor inteiro?

5.1 Faça os testes e determine se a aplicação subirá automaticamente ou não;

5.2 Caso o resultado do teste apresente um cenário onde a aplicação não subirá automaticamente e pesquise e determine o que deve ser feito para subir os containers de forma automática.

5.3 Quanto a persistencia de dados o que acontece com as informações estáticas da página em PHP? determine qual o ponto de montagem correto e crie um volume persistente para o wordpress;

---

## Material de Referência e Recomendações:

Este material não foi usado como referencia nesta aula mas é uma recomendação muito didática para estudos iniciais sobre docker:
[Docker para desenvolvedores](https://github.com/gomex/docker-para-desenvolvedores);

---

**Free Software, Hell Yeah!**
