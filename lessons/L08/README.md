##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---

Neste laboratório criaremos uma configuração de DNS utilizando a arquitetura abaixo:

---


## Instalação do Serviço Bind9

1.1 O Bind9 é um dos projetos mais utilizados em arquiteturas de DNS, ele é fornecido e mantido pela [ISC](https://www.isc.org/downloads/bind/), sendo provavelmente solução mais utilizada e consequente aquela que oferece melhor suporte da comunidade e documentação online.

```sh
# apt-get update && apt-get install bind9 dnsutils bind9-doc -y 
```

> Para ambientes da familia RedHat o processo de instalação utiliza o pacote bind ao invés de bind9 e cria um serviço cuja unidade no systemd é chamada named.

1.2 Para testar essa implementação primeiro inicialize o serviço bind9 nos servidores Ubuntu:

```sh
# systemctl start bind9
# journalctl -fu bind9
```

1.3 Faça um teste simples utilizando o comando dig:

```sh
# dig @127.0.0.1 www.fiap.com.br
```

> Se a conutla falhar teste novamente em 10 a 20 segundos;

Ao executar o dig verifique duas informações:

1. O campo **"Query time:"** apresentara o tempo necessário no processo de resolução de nomes;
2. O campo **"SERVER:"** apresenta o servidor DNS consultado, em nosso exemplo 127.0.0.1 na porta 53;
3. Ao rodar novamente o mesmo teste de resolução de nomes o Query time deverá ser reduzido drasticamente uma vez que o resultado da consulta já está em cache no bind9;

## Estrutura base do bind9 na familia Debian

No Ubuntu a estrutura do bind9 utiliza um arquivo base de configuração chamado **named.conf**, basicamnente este arquivo é um apontamento para outros arquivos com finalidades específicas:

```sh
# cat /etc/bind/named.conf
```

- **named.conf.local:** Utilizado para adicionar configurações locais no DNS;
- **named.conf.options:** Utilizado para customizar opções de segurança, repasse de requisições e localização dos arquivos de registro, na configuração padrão da familia Debian esta localização aponta para o diretório "/var/cache/bind";
- **named.conf.default-zones:** Utilizado para declarar as zonas de DNS sob controle do bind9;

A primeira entrada do arquivo "named.conf.default-zones" contém uma zona do tipo hint que aponta quais são os root servers a serem utilizados no processo de resolução de nomes, verifique o conteúdo deste arquivo:

```sh
# cat /etc/bind/db.root
# dig L.ROOT-SERVERS.NET
```

> A relação recebida na consulta acima representa o cluster de servidores DNS responsáveis pela composição do cluster
> do root server "L.ROOT-SERVERS.NET" um dos 13 root servers que compoem a infra-estrutura de DNS, alias a relação completa 
> destes servidores pode ser consultado neste [MAPA](http://www.root-servers.org/).

---

# Configurando um SOA

O exemplo anterior serviu para esquentar um pouco e para entendermos a estrutura basica do bind, para este laboratório executaremos o processo de configuração do bind como SOA "Start of Authority" do domínio fictício fiaplabs.com.br.

2.1 Para este laboratório crie uma interface virtual ipv4 e outra ipv6, elas serão usadas em alguns exemplos:

```sh
ip a add 192.168.100.10 dev eth0:DNS
ping -c 3 192.168.100.10


ip -6 address add 2A00:0C98:2060:A000:0001:0000:1d1e:ca75/64 dev eth0:DNS6
ping6 -c3 2a00:c98:2060:a000:1:0:1d1e:ca75
```



2.2 Crie um novo arquivo de configuração de zona, ele será adicionado com o nome ***/etc/bind/named.conf.fiaplabs***:

```sh
cat <<EOF > /etc/bind/named.conf.fiaplabs
zone "fiaplabs.com.br" {
        type master;
        file "db.fiaplabs.com.br";
};
EOF
```

2.3 Inclua o arquivo como parte da configuração do bind9:

```sh
cat <<EOF >> /etc/bind/named.conf
include "/etc/bind/named.conf.fiaplabs";
EOF
```

As linhas acima descrevem o seguinte:

1. A Zona a ser configurada é a zona ***fiaplabs.com.br***, a string ***zone*** declara que inicamos a configuração de uma nova zona;
2. O tipo de zona escolhido foi ***master*** ou seja, esse será o DNS principal resposnável pela zona;
3. Outros DNS tambem poderão responder por essa zona porem como tipo ***slave***;
4. O campo file determina onde está o arquivo de zona, o diretório "/var/cache/bind/" é a pasta default para armazenar arquivo de zona cofigurada automaticamente na instalação do bind9, portanto a PATH compelta do arquivo será: "/var/cache/bind/db.fiaplabs.com.br";

2.4 Configure a zona fiaplabs.com.br copiando o arquivo base entregue na própria documentação do bind9:

```sh
curl https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/lessons/L08/ubuntu/db.fiaplabs.com.br \
-o /var/cache/bind/db.fiaplabs.com.br
```

2.5 Verifique a configuração aplicada ao arquivo de DNS:

```sh
cat /var/cache/bind/db.fiaplabs.com.br
```

O formato deverá ser similar ao modelo abaixo:

```sh
$TTL    604800
@       IN      SOA     fiaplabs.com.br. helpdesk.fiaplabs.com.br. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@          IN      NS      ns1.fiaplabs.com.br.
ns1        IN      A       192.168.100.10
ns1        IN      AAAA    2a00:c98:2060:a000:1:0:1d1e:ca75

@          IN      MX      10 mail
mail       IN      A       192.168.100.10
smtp       IN      CNAME   mail
pop        IN      CNAME   mail
```

2.6 Antes de reiniciar o bind9 faça uma checagem do arquivo de zona: 

```sh
# named-checkzone fiaplabs.com.br /var/cache/bind/db.fiaplabs.com.br
zone fiaplabs.com.br/IN: loaded serial 2
OK
```

2.7 Reinicie o bind9

```sh
# systemctl restart bind9
```

2.8 Teste o processo de resolução de nomes, com base na configuração anterior execute os testes abaixo e salve os resultados no formulário:

```sh
# Verifique quem é SOA sobre o domínio fiaplabs.com.br:
dig @127.0.0.1 -t SOA fiaplabs.com.br +short
        -> fiaplabs.com.br. helpdesk.fiaplabs.com.br. 2 604800 86400 2419200 604800

# Verifique quem é o nameserver responsável pelo domínio fiaplabs.com.br:
dig @127.0.0.1 -t NS fiaplabs.com.br +short
        -> ns1.fiaplabs.com.br.

# Faça um teste de resolução de nomes para ipv4:
dig @127.0.0.1 -t A ns1.fiaplabs.com.br.
        -> 192.168.100.10

# Faça um teste de resolução de nomes para ipv6:
dig @127.0.0.1 -t AAAA ns1.fiaplabs.com.br. +short
        -> 2a00:c98:2060:a000:1:0:1d1e:ca75
 
# Faça um teste de resolução de nomes para um CNAME:
dig @127.0.0.1  smtp.fiaplabs.com.br. +short
        -> mail.fiaplabs.com.br.
        -> 192.168.100.10

# Faça um teste de resolução de nomes para um ponteiro MX:
dig @127.0.0.1 -t MX fiaplabs.com.br. +short
        -> 10 mail.fiaplabs.com.br.
        
# Faça um teste de resolução de nomes para usando a interface de ipv6 do bind9:
dig @::1 pop.fiaplabs.com.br. +short
        -> mail.fiaplabs.com.br.
        -> 192.168.100.10

```

---

**Free Software, Hell Yeah!**
