##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L03_logo.png)

Imagem de [janjf93](https://pixabay.com/pt/users/janjf93-3084263/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2126880) obtida via [Pixabay](https://pixabay.com/pt/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2126880");


# Instalando Pacotes Parte 2 
**Configurando um servidor de monitoraçã com ntop**

O Ntopng é um sistema de monitoramento de tráfego de rede de código aberto escrito com base em PHP e Lua, esta ferramenta também será o nosso projeto para entender a instalação de pacotes na família RedHat e aprofundar o contato com a implementação de um serviço controlado via [System-D](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd);

***Recursos do Ntopng:***

- Análise em tempo real em nível de protocolo do tráfego de rede local;
- Geolocalização de endereços IP;
- Matriz de tráfego de rede;
- Análise histórica de tráfego;
- Suporte para sFlow, NetFlow e IPFIX através do nProbe;
- Suporte IPv6;

## 1. Gestão de Pacotes na Família RedHat

1.1 O gerenciamento destes pacotes é feito utilizando a ferramenta RPM que possui uma função similar a função do DPKG, instalar e remover binários do sistema, para testar essa ferramenta executaremos o download do binário de configuração do repositório extra EPEL que será utilizado no processo de resolução de algumas dependências na instalação do ntopng.

```sh
sudo su -

curl https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -o /tmp/epel-release.rpm

# Verifique se o arquivo .rpm foi baixado:
ls /tmp/*.rpm

# Em seguida utilize o comando rpm para instalação do Epel:
sudo rpm -ivh /tmp/epel-release.rpm
```

> Assim como o rpm install foi executado utilizando os parametros ivh (Install, Verbose e Human Format) o mesmo comando também pode ser utilizado para remover ou listar binários, verifique as opções correspondetes no man!

**O que é esse tal de EPEL?**

1.2 Assim como o repositório externo utilizado na instalação do Nginx na família Debian existem repositórios externos na estrutura da Família RedHat, o EPEL é um repositório complementar ao repositório padrão do CentoOS e fornece diversas ferramentas e pacotes complementares aos pacotes que vem nos repositórios "default" da distribuição;

> Dica: O EPEL também pode ser instalado utilizando o gerenciador de pacotes de alto nível da Familia RedHat, o yum através do pacote "epel-release"

Na Família RedHat todo repositório é configurado com base em um arquivo localizado no diretório **"/etc/yum.repos.d"**, verifique o arquivo de configuração do repositório recém instalado:

```sh
sudo cat /etc/yum.repos.d/epel.repo
```

1.3 Os repositórios disponíveis podem ser listados utilizando o comando abaixo:

```sh
sudo yum repolist 
```

**E esse tal de yum?**

Esta é a primeira vez que utilizamos o yum, trata-se do gerenciador de pacotes de alto nível da Família Red Hat, assim como o RPM pode ser comparado em funcionalidade ao DPKG o yum pode ser comparado da mesma forma ao apt, ele é responsável por gerenciar pacotes com base em repositórios alocados nos arquivos .repo do diretório **"/etc/yum.repos.d."** o comando acima foi utilizado para listar esses repositórios.

> Verifique que ao adicionar um repositório não é necessário executar um comando de atualização de cache como o 'apt-get update', essa atualização de cache e relação de pacotes disponíveis ocorre automaticamente toda vez que invocamos as funções do yum;

## 2. Agora sim, Instalando o NTOP

2.1 A versão mais recente do Ntopng não está disponível no repositório padrão do CentOS 7, dessa forma assim como no Lab anterior utilizaremos um repositório personalizado:

```sh
sudo su -

curl http://packages.ntop.org/centos-stable/ntop.repo -o /etc/yum.repos.d/ntop.repo

# Verifique se o arquivo .rpm foi baixado:

# Em seguida utilize o comando yumrepolist para verificar se o repositório foi adicionado:
sudo yum repolist
```

2.2 Executando uma atualização no sistema operacional:

```sh
yum clean all
yum update
```

2.3 Em seguida instale os binários do Epel:

```sh
sudo yum --enablerepo=epel install redis ntopng hiredis-devel -y
```

## Controlando o Serviço

2.4 O pacote Ntop fornece um serviço de monitoração, este serviço atua como um processo em execução no background do sistema operacional sendo controlado pela ferramenta de gerenciamento de serviços [System-D](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd), dessa forma é necessário inicializar o serviço usando o systemD:

```sh
sudo systemctl start redis.service
sudo systemctl start ntopng.service
```

2.5 Verifique se o serviço foi inicializado corretamente executando o comando abaixo:

```sh
sudo systemctl status ntopng
```

2.6 A interface Web do Ntopng escuta conexões na porta TCP 3000, verifique se essa porta está aberta para conexões:

```sh
# Checando se a porta está em listening:
sudo ss -ntpl
```

## 3. Testando o Ntopng:

Após configurar você pode acessar a interface da Web ntopng em um navegador da web acessando a URL:
"http: //<SEU-RM>.fiapdev.com:3000"

Usuário: **admin**

Senha:   **admin**

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L03_ntop.png)


---

## 4. Challenge

O SystemD pode ser configurado para inicializar automaticamente a solução apoś o boot do servidor, descubra como habilitar esse recurso a partir do manual do comando e execute esta configuração.

---

## 5. Exercício:

Com base no exercício que executamos responda a essa três perguntas simples neste formulário, sua resposta será utilizada como mérito na nossa avaliação semestral;

Link do formulário: [https://form.jotform.com/200794325273051](https://form.jotform.com/200794325273051)

---

## Material de Referência e Recomendações:

* [Install Ntopng Network Traffic Monitoring Tool on CentOS 7](https://devops.profitbricks.com/tutorials/install-ntopng-network-traffic-monitoring-tool-on-centos-7/);

---

**Free Software, Hell Yeah!**
