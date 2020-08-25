##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---

## Instalação do Serviço

Existem algumas boas opções de projetos opensource que oferecem sistema de DNS, para nosso escopo utilizaremos o Bind fornecido e mantido pela [ISC](https://www.isc.org/downloads/bind/), esta é sem duvidas a solução mais utilizada e consequente provavelmente aquela que oferece melhor suporte da comunidade e documentação online. Mas fica uma menção 

No host dns-master instale os pacotes necessários para o bind9 e para as ferramentas de consulta:

```sh
# apt-get update
# apt-get install bind9 dnsutils bind9-doc
```

Para ambientes da familia RedHat o processo de instalação utiliza os seguintes pacotes:

```sh
# yum install bind bind-utils
```

## Configurando um DNS "Caching-Only"

Ao finalizar o processo de instalação acima o bind é entregue com a configuração "caching only", esta configuração consiste exatamente no que seu nome diz; Estabelecer o DNS como um recurso para caching de requisições dentro de uma rede sem que este atue como SOA de algum domínio.

Para testar essa implementação primeiro inicialize o serviço bind9 nos servidores Ubuntu:

```sh
# systemctl start bind9
```

Redirecione seu DNS para o localhost alterando o arquivo resolv.conf:

```sh
# echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

Em seguida faça um teste simples utilizando o comando dig:

```sh
# dig www.fiap.com.br
```

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
