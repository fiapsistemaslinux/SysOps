##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/apache-0.png)

---

O projeto Apache é um esforço comunitário de desenvolvedores cujo objetivo é prover um servidor web de código fonte aberto, estável e seguro. Sua origem está em um projeto da NSCA (Nacional Center of Supercomputing Aplications) criado pelo desenvolvedor de softwares e arquiteto de aplicações Robert M. McCool. O projeto inicial foi retomado por desenvolvedores dando origem a Fundação Apache (Apache Foudation).

Você encontrará um detalhamento maior dessas informações no site do projeto o [apache.org](http://www.apache.org)

### Histórico

A primeira versão do Apache foi lançada em 1995, sendo que a partir de 1996 o projeto ganhou grande reconhecimento e popularidade, hoje em dia pode se dizer sem chances de erro que o Apache é ainda hoje, a maior e uma das mais usadas soluções em relação a disponibilização de sites na internet. Essa informação pode ser aferida atráves do site [NetCraft](https://news.netcraft.com/) conforme abaixo:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/apache-1.png)

> O gráfico dispoe informações sobre a fatia de uso de cada um dos principais projetos de Servidor de Conteúdo Web, aqui vemos o Apache liderando a preferência dos desenvolvedores sendo seguido de perto pelo IIS da Microsoft e pelo promissor NGINX.

***Principais vantagens do Apache:***

- O projeto está sobre licença GPL, ou seja, Software Livre, podendo ser estudado, modificado, adaptado e redistribuído;
- Suporta várias linguagens de programação como "PHP", "Python", "Ruby", "Perl" e inclusive "ASP" e ".NET";
- Aplicação Multiplataforma podendo ser implementado em Unix, Linux ou Windows;
- Pode trabalhar com multi "threads", isto é, MultiProcessamento, uma funcionalidade disponível apartir de sua segunda versão o Apache2;
- Tratase de uma aplicação Modular, você libera os módulos (funcionalidades) de acordo com sua necessidade;## Modulos de operação

Para dominar o apache um dos primeiros conceitos a serem entendidos é a questão dos MPM`s (Multi-Processing Modules) ou módulos de multi-processamento do servidor, estes módulos podem ser entendidos como duas opções diferentes de configuração para o Apache, são eles o módulo PreFork e o módulo Worker. Um deles lhe concederá compatibilidade com algumas linguagens de programação mais antigas e o outro fornecerá otimização na performance do servidor e consequentemente de sua aplicação.

### MPM Pré-Fork

Neste modo, o Apache trabalhará com a implementação de multi-processos, onde um processo será responsável por executar novos processos que serão utilizados para aguardar novas conexões e responder as requisições existentes. Este modo é ideal para quem precisa manter compatibilidade com aplicações e bibliotecas que ***NÃO SUPORTAM*** o método de operação conhecido como Worker.

### MPM Worker

No modo de Operação conhecido como "MPM Worker", o Apache trabalhará com uma implementação mista de processos e "threads", o que possibilita atender mais conexões simultâneas com um custo menor de hardware, já que "threads" são mais velozes que processos.

Neste modo de operação, o apache mantém uma série de "threads" ociosas, fazendo com que novas conexões sejam processadas e respondidas de uma maneira mais rápida do que no modo "Pre Fork". Infelizmente nem toda aplicação se dá bem com "threads", como o "PHP5", por exemplo.

---

## Deploy de um servidor de conteúdo:

Nos processos que seguem executaremos a instalação e configuração do apache2 em ambiente Ubuntu, adicionaremos suporte a PHP para executarmos alguns deploys de aplicações opensource, para isso começe pela instalação dos pacotes básicos:

### Executando instalação do apache2

```sh
apt update && apt install apache2 curl
```

No processo acima executamos uma instalação simples do apache, verifique o funcionamento do serviço executando o seguinte:

```sh
systemctl start apache2
ss -ntpl
```

Caso sua instalação tenha sido finalizada com sucesso e caso o acesso a partir da porta 80 esteja OK você já deverá ser capaz de visualizar uma página em CSS com conteúdo default entregue pela instalação, esse conteúdo localiza-se no diretório raiz que armazena o conteúdo do site, chamamos esse diretório de ***DocumentRoot***, no Ubuntu trata-se do diretório ***/var/www/html***

Se o seu acesso estiver bloqueado por qualquer motivo você ainda pode acessar localmente no terminal de comandos pelo curl ou tunnelar uma porta ssh 

```sh
curl --verbose 127.0.0.1
```

> Na execução acima tome como base que estamos rodando uma distro derivada da Familia Debian, o apache assim como o bind9 possui grandes variações na sua nomenclatura, caso ele seja executado na Familia RedHat o demon do serviço seria o httpd, mesmo nome a ser utilizado na instalação do pacote via yum;

> Outra variação esperada é relativa ao caminho da instalação, aqui (Debian/Ubuntu) sua configuração esta distribuida dentro da pasta /etc/apache2 enquanto no RedHat a estrutura basei-se na pasta /etc/httpd.

### Estrutura do apache na Familia Debian

Desconsiderando variações específicas que ocorrem na implementação entre uma versão da distro e outra o layout geral da configuração do apache na instalação em um sistema operacional da Familia Debian é o seguinte:

```sh
/etc/apache2/
├── apache2.conf
├── conf-available
├── conf-enabled
├── envvars
├── magic
├── mods-available
├── mods-enabled
├── ports.conf
├── sites-available
└── sites-enabled
```


***apache2.conf:*** Principal arquivo de configuração. Esse arquivo agrada cada configuração aplicada ao apache, incluindo todos os arquivos de configuração restantes indicados por funções de include iniciar o servidor web;

***ports.conf:*** Na familia Debian esse arquivo é sempre incluído a partir do arquivo de configuração principal. Ele é usado para determinar as portas de escuta para conexões de entrada, em outras distros esses parametros em geral se encontram dentro do arquivo de configuração principal;

***mods-enabled /, conf-enabled / e sites-enabled / :*** Diretórios que contêm determinados trechos de configuração para gerenciamneto de módulos, o que facilita no modelo de gestão modular proposto pelo projeto, aqui encontram-se fragmentos de configuração global ou configurações de hosts virtuais do apache.

 ***mods-available /, conf-available / e sites-available / :*** São os diretórios responsáveis por alocar as configurações ativam, cada um deles é populado por links simbólicos para outros diretórios de configuração , os diretórios citados anteriormente com o nome "*-enable".

> Esses links simbólicos alocados nos diretórios "*-available" devem ser gerenciados usando os comandos a2enmod, a2dismod, a2ensite, a2dissite e a2enconf, a2disconf, o modelo é exclusivo da Família Debian/Ubuntu... parece complicado mas após o primeiro teste você pega o jeito!

### Gerência de configurações com o comando apache2ctl:

Na familia Debian o apache utiliza um binário de configuração chamado apache2ctl:

```sh
apache2ctl -h
```

A patir deste binário é possível executar diversas ações como por exemplo testar a configuração atual de seu servidor ou efetuar um restart:

```sh
apache2ctl configtest
apache2ctl restart
apache2ctl fullstatus
```

Existem situações em que talvez não seja interessante efetuar um restart direto no seu servidor, isso porque o comando reinicializaria todas as conexões, inclusive aquelas ativas o que em um ambiente em produção poderia ser sentido pelo usuoario acessando sua aplicação. Para isso o apache utiliza um modelo de restart do tipo ***gracefull*** que permite reinicilizar o serviço aos pocuos, aguardando até que os processo em aberto seja finalizado:

```sh
apache2ctl graceful
```

> A diferença entre este comando e os anteriores é que neste caso o servidor não irá finalizar todos os processos e conexões para subir uma nova configuração, ele simplesmente irá iniciar novas conexões com as alterações em vigor sem matar as antigas, ou seja, sem que haja qualquer impacto na aplicação.

### Virtualhosts

O termo Virtual Host refere-se à pratica de rodar mais de um site em um único host, ou seja, hospedar e acessar duas páginas diferentes hospedadas no mesmo servidor utilizando registros de DNS para que o apache saiba qual conteúdo deve entregar, na prática hosts virtuais também podem ser "baseadas em IP", o que significa que você tem um endereço IP diferente para cada site, mas o mais comum é utilizaor o DNS, o que também significa ter vários nomes de domínio em execução em cada endereço IP. Ao utilizar um Virtual Host o fato de ter dois ou mais sites em execução no mesmo servidor físico não é aparente para o usuário final.

> O Apache foi um dos primeiros servidores de conteúdo a suportar hosts virtuais e possui uma forte documentação sobre o assunto no [site oficial do projeto](https://httpd.apache.org/docs/2.4/vhosts/);

#### Configurando virtualhosts no apache

A configuração de um virtual host no projeto apache é executada a partir da função [<VirtualHost>](https://httpd.apache.org/docs/2.4/mod/core.html#virtualhost) sendo que o local de sua declaração varia de acordo com a implementação do apache ( Existem diferenças sobre onde declarar um virtual host nas familias Debian e RedHat );

Para este exemplo faremos a configuração do Virtual Host para delivery de um [template](https://github.com/fiapsistemaslinux/apostila/raw/master/content/Apache/templates/cloud.tar.bz2) utilizando uma implementação 2.4 do apache no ubuntu server, para começar garanta a existencia do template no DocumentRoot do apache em /var/www/

```sh
cd /var/www/
wget https://github.com/fiapsistemaslinux/apostila/raw/master/content/Apache/templates/cloud.tar.bz2
```

No Ubuntu o apache utiliza o diretório /etc/apache2/sites-available como base para criação de virtual hosts, acesse esse diretório e crie um arquivo chamado [001-openstack.conf](https://raw.githubusercontent.com/fiapsistemaslinux/apostila/master/content/Apache/vhosts/001-cloud.conf)

Outros exemplos de criação de virtual hosts podém ser acessados [AQUI](https://httpd.apache.org/docs/2.4/vhosts/examples.html)

```sh
sudo su -
cd /etc/apache2/sites-available
wget https://raw.githubusercontent.com/fiapsistemaslinux/apostila/master/content/Apache/vhosts/001-cloud.conf
```

Após criar um Virtual Host será necessário ativa-lo para isso utilize o comando a2ensite ou crie manualmente um link simbolico entre o arquivo criado e um arquivo de mesmo no na pasta sites-enabled

```sh
a2ensite 001-cloud
systemctl reload apache2
```

Faça um teste acessando o conteúdo de seu site pelo Server Name ou por um dos Server Alias que utilizou ao criar o seu VirtualHost, Não se esqueça, o apache não cria as entradas de DNS para o domínio desejado, logo você terá de fazer isso manualmente adicionando um registro em seu servidor de DNS;

No nosso caso temos a opção de forçar um HEADER na requisição a partir do próprio sistema operacional utilizando o nome de DNS ou FQDN esperado pela aplicação conforme o exemplo abaixo:

```sh
curl -v -H 'Host: cloud.fiapdev.com' http://127.0.0.1:80
```

---

### Documentação Oficial do Projeto:

* [Security Tips](https://httpd.apache.org/docs/2.4/misc/security_tips.html);

* [Apache Performance Tuning](https://httpd.apache.org/docs/2.4/misc/perf-tuning.html);

* [Server-Wide Configuration](http://httpd.apache.org/docs/current/server-wide.html);
( Este ultimo inclui as definições sobre para configuração de ServerTokens e ServerSignature );

---

**Free Software, Hell Yeah!**