##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---
# iptables

## Base para construção de um firewall iptables

> O exemplo abaixo apresenta o passo a passo necessário para construirmos nosso firewall utilizando "apenas" iptables e outros recursos nativos do próprio sistema operacional como systemd e script shell, soluções como PFSense são extremamente úteis pela facilidade, quantidade de recursos e suporte da própria comunidade, mas a idéia aqui é sujar as mãos com o objetivo de evoluir nossa bagagem sobre o assunto.

### Preparação de ambiente:

Para facilitar a execução do Lab altere o hostname dos servidores envolvidos:

Execute a configuração do hostname:

```sh
echo webserver.fiaplabs.com > /etc/hostname
hostname -F /etc/hostname
bash
```

Para o DNS utilizaremos dois endereços publicos da Google e Cloudflare:

```sh
cat <<EOF >> /etc/sysconfig/network
DNS1=8.8.8.8
DNS2=1.1.1.1
EOF
```

Reinicie a configuração de rede e verifique se as alterações foram processadas:

```sh
systemctl restart network
dig # Verifique o campo SERVER na saída do comando
```

### Alterando a policy do firewall:

Libere o trafego com destino a porta 22 do firewall:
```sh
# iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
# iptables -t filter -A OUTPUT -p tcp --sport 22 -d 0/0 -j ACCEPT
```

A configuração acima deverá garantir os acessos via ssh mesmo após mudarmos as policys do firewall, PARA EVITAR A PERDA DE ACESSO cheque as configurações antes de proseguir:

```sh
iptables -S
```

Você deverá ver um resultado similar as linhas abaixo:

```sh
[root@webserver ~]# iptables -S
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT
```

Altere a policy do firewall para garantir o DROP de pacotes em todas as CHAINS da tabela filter:

```sh
# iptables -t filter -P INPUT DROP
# iptables -t filter -P OUTPUT DROP
# iptables -t filter -P FORWARD DROP
# iptables -S
```

### Criando regras de configuração de DNS: 

Faça um novo teste com resolução de nomes:

```sh
dig
```

**Neste caso o comando deverá retornar um timed out com a mensagem: "no servers could be reached" após alguns segundos

Crie as regras conforme abaixo para outgoing de DNS:
```sh
# iptables -t filter -A INPUT -p udp --sport 53 -d 0/0 -j ACCEPT
# iptables -t filter -A OUTPUT -p udp -s 0/0 --dport 53 -j ACCEPT
```

Teste novamente o processo de resolução de nomes:

```sh
dig +short
```

> E se fosse necessário liberar apenas com base na interface eth0? Poderiamos utilizar a seguinte abordagem: iptables -t filter -A INPUT -p udp --sport 53 -d 0/0 -i eth0 -j ACCEPT

### Regras de configuração de acesso a porta 80 e 443:

```sh
curl -i https://api.github.com -m 3
```

***Você deverá obter um timeout nesta requisição"***

Para corriger isso liberaremos o acesso nas portas 80 e 443, é possível criar regras que se apliquem a mais de uma porta sem que seja necessário executar dois comandos diferentes no iptables, para esta finalidade utilizamos o parâmetro "-m":

```sh
# iptables -t filter -A OUTPUT -p tcp -m multiport -d 0/0 --dport 80,443 -j ACCEPT
# iptables -t filter -A INPUT -p tcp -m multiport --sport 80,443 -j ACCEPT
```

Teste novamente o acesso da instância a internet utilizando o yum makecache que tentará atualizar o cache de repositórios disponíveis:

```sh
curl -i https://api.github.com -m 3
yum makecache
```

> O parametro **-m** ou **--match** é utilizado para criar um condição de aplicação para a regra a partir de um módulo do iptables como connect, state ou multiport, ou seja a regra passa a depender, neste caso a condição utiliza o módulo multiport, para habilitar especificação de mais de uma porta na mesma regra, neste exemplos as portas 80 e 443.

### Liberando icmp com base no icmp-type do pacote:

O conjunto de regras abaixo possuirá a função de liberar o ping porém sob condições específicas:

- A CHAIN de OUTPUT permitirá apenas a saída de pacotes icmp do tipo 8 ou seja **icmp request**;
- A CHAIN de INPUT permitirá apenas a entrada de pacotes icmp do tipo 0 ou seja **icmp reply**;

```sh
# iptables -t filter -A INPUT -p icmp --icmp-type 0 -s 0/0 -j ACCEPT
# iptables -t filter -A OUTPUT -p icmp --icmp-type 8 -d 0/0 -j ACCEPT
```

> Consequencia: Em nosso cenário apenas será liberado a saída de ping, um cliente externo simplesmente NÃO poderá pingar nosso servidor, visto que o iptables simplesmente deverá "DROPAR" o recebimento do pacotes icmp do tipo Request

```sh
ping 8.8.8.8
```

Caso ache interessante você pode criar um novo conjunto de regras liberando icmp completo na rede lan, ou seja, permitindo que de dentro da rede seja possível pingar o proxy:

```sh
# iptables -t filter -A OUTPUT -p icmp -d 172.31.0.0/20 -j ACCEPT
# iptables -t filter -A INPUT -p icmp -s 172.31.0.0/20 -j ACCEPT
```

## Configurando as regras necessárias para pacotes "comuns" na rede:

Geralmente alguns conjuntos de pacotes tendem a ser liberados por serem de uso comum por parte dos usuarios, em nosso exemplo vamos liberar o trafego nas portas de e-mail e ftp:

```sh
# iptables -A OUTPUT -p tcp --sport 1024:65535 -m multiport --dports 20,21 -j ACCEPT -m comment --comment "Lberar FTP"
# iptables -A INPUT -p tcp --dport 1024:65535 -m multiport --sports 20,21 -j ACCEPT -m comment --comment "Lberar FTP"
```

Para testar essas liberações tente conectar a partir do servidor no ftp da unicamp:

```sh
# ftp
> open ftp.unicamp.br 
```

***Após o teste você receberá um retorno 220 do servidor da Unicamp, neste momento cancele a requisição com Ctrl+D***

> As duas regras criadas acima utilizaram comentarios através do match "comment", o comentario inserido torna-se parte da regra, útil para facilitar processos de troubleshooting em regras especificas.

## Implementando controle de status de conexão no firewall:

Para testarmos o conceito de análise de estado de conexão de pacotes, utilizaremos o módulo ***state***, com um exemplo simples: Liberar o servidor para outgoing de ssh:

```sh
# iptables -t filter -A OUTPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -t filter -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

> Na regra de outgoing (OUTPUT) criada acima aceitamos a ***saída*** de qualquer pacote sob os estados ***NEW*** e ***ESTABLISHED*** com destino a porta 22, ou seja, pacotes que já estabeleceram uma conexão e pacotes novos com destino a porta que por padrão é usada para ssh serão permitidos.

> Na regra de incoming (INPUT) criada acima aceitados a ***entrada*** de qualquer pacote sob o estado ***ESTABLISHED***, vindo da porta 22 de qualquer origem, repare que a regra NÃO contempla tentativas de conexões no servidor uma vez que só pacotes de conexões já estabelecidas são aceitos, eis um exemplo onde o uso do controle de pacotes por estado aumenta a eficiẽncia do controle executado via iptables.


## Configurando inicialização automatica do firewall

As regras de iptables criadas em nossos exemplos foram configuradas pelo frontend iptables que "entrega" as regras diretamente no netfilter, isso quer dizer que após um processo de reboot todas essas regras teriam de ser recriadas novamente, para que isso ocorra de forma automatica é necessário que as regras sejam carregadas na inicialização do sistema.

Em geral essa configuração de inicialização é feita manualmente criando scripts de inicialização de iptables, o processo varia de acordo com o sistema de inicialização utilizado, systemD, systemV ou upstart, em nosso exemplo estamos utilizando o systemD, ele possui um pacote que automativa esse processo, o que facilitara nosso trabalho:

```sh
# yum install iptables-services
# head /etc/sysconfig/iptables
``` 

O pacote iptables-services cria uma unidade de inicialização de regras iptables no systemD, repare que as regras podem ser manualmente carregas dentro do arquivo ***/etc/sysconfig/iptables***, exatamente o que faremos a seguir:

```sh
# iptables-save > /etc/sysconfig/iptables
```

Feito isso faça um teste inicializando o serviço de iptables:

```sh
# systemctl start iptables
# systemctl status iptables
# iptables -S
```

Com o serviço configurado para controle via systemD basta garantirmos a inicialização automatica do serviço:
```sh
# systemctl enable iptables
```

## Material de Referência sobre a iptables, firewallD e systemD:

* [Página do projeto iptables](https://www.netfilter.org/projects/iptables/)

* [Overview sobre o sistema de inicialização systemD](https://access.redhat.com/articles/754933)

----

**Free Software, Hell Yeah!**
