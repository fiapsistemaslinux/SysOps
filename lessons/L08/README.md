##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---

Neste laboratório criaremos uma configuração de DNS utilizando a arquitetura abaixo:

---


## Instalação do Serviço Bind9

O Bind9 é um dos projetos mais utilizados em arquiteturas de DNS, ele é fornecido e mantido pela [ISC](https://www.isc.org/downloads/bind/), sendo provavelmente solução mais utilizada e consequente aquela que oferece melhor suporte da comunidade e documentação online.

```sh
# apt-get update
# apt-get install bind9 dnsutils bind9-doc
```

> Para ambientes da familia RedHat o processo de instalação utiliza o pacote bind ao invés de bind9 e cria um serviço cuja unidade no systemd é chamada named.

Para testar essa implementação primeiro inicialize o serviço bind9 nos servidores Ubuntu:

```sh
# systemctl start bind9
# journalctl -fu bind9
```

Faça um teste simples utilizando o comando dig:

```sh
# dig @127.0.0.1 www.fiap.com.br
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


---

**Free Software, Hell Yeah!**
