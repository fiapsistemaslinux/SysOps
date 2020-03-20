##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br


![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L02_browsers.png)

Imagem de <a href="https://pixabay.com/pt/users/geralt-9301/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=773215">Gerd Altmann</a> por <a href="https://pixabay.com/pt/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=773215">Pixabay</a>
---

# Instalando Pacotes (Configurando um servidor de conteúdo)

Neste LAB revisaremos alguns conteúdos voltados a instalação de pacotes para configurar um servidor linux rodando Nginx implementando uma página estática de conteúdo;

**Objetivo:**
Revisitar o processo de instalação de pacotes e configuração de repositórios em ambientes GNU/Linux utilizando a  família Debian e em seguida habilitar repositório um  de terceiros para obter a versão mais recente de uma aplicação;

---

## 1. Atualizando os pacotes do servidor

Após o acesso ao sistema operacional, verifique os repositórios configurados:

```sh
cat /etc/apt/sources.list
```

> Essa relação demonstra quais repositórios serão consultados no processo de instalação e atualização de pacotes, a mesma lógica se aplica a qualquer implantação da Família Debian como Kali Linux ou variações do Ubuntu.

> Outro ponto importante é que além do arquivo sources.list o diretório "/etc/apt/sources.list.d" pode ser usado com a mesma finalidade.

Execute o processo de atualização dos pacotes instalados:

```sh
sudo apt-get update
sudo apt-get upgrade
```

---

## 2. Instalação do Nginx:

Nesta segunda etapa execute a instalação do Nginx de acordo com a versão disponível no repositório:

```sh
sudo apt-cache search nginx --names-only
sudo apt-get install nginx -y
```

> Ao instalar o pacote nginx a aplicação implantada é um daemon, ou seja, uma apliação com a função de gerenciar os processos e controlar a execução de um serviço, este serviço é um servidor de conteúdo web, é possível habilitar e atestar seu funcionamento pelo próprio terminal de comandos:

```sh
# Verifique se o pacote foi instalado
dpkg -l | grep nginx

# Verificando a versão instalada:
nginx -v

# Verificando o serviço:
sudo systemctl status nginx

> Na instalação um deamon responsável por controlar um processo é criado, este controle ocorre através de um serviço implantado utilizando a solução systemd um assunto que revisaremos nas próximas aulas mas já está nos anexos do nosso material de apoio;

**Finalmente acesse a página default criada após a instalação pelo navegador Web**

```

## 2.1 Detalhes importantes do processo

2.1.1 É possível averiguar em qual porta a aplicação instalada está rodando com o comando ss:

```sh
ss -ntpl
```

> Verifique os parâmetros utilizados no comando acima da forma como aprendemos com o man!

2.1.2 Embora a verificação pelo navegador seja mais evidente outra possibilidade seria uma análise direta testando uma requisição na porta padrão 80 com o comando curl:

```sh
curl 127.0.0.1:80
```
---

## 3. Atualizando o repositório

Após a instalação execute a configuração de um novo repositório, o que possibilitará obter uma versão atualizada do Nginx:

3.1 Crie um arquivo de repositório:

```sh
sudo su -

source /etc/lsb-release

sudo cat > /etc/apt/sources.list.d/nginx.list << EOF
## Nginx external repository
deb https://nginx.org/packages/ubuntu/ $DISTRIB_CODENAME nginx
deb-src https://nginx.org/packages/ubuntu/ $DISTRIB_CODENAME nginx
EOF
```

```sh
# Verifique se o arquivo foi criado:
cat /etc/apt/sources.list.d/nginx.list
```

3.2 Tente atualizar a relação de repositórios disponíveis:

```sh
apt-get update
```

Nesta etapa você deverá ver o seguinte erro:

```sh
W: GPG error: https://nginx.org/packages/ubuntu bionic InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY ABF5BD827BD9BF62
E: The repository 'https://nginx.org/packages/ubuntu bionic InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
```

> O erro exibido no output do comando refere-se ao fato de que adicionamos um novo repositório sem adicionar a chave GPG pública utilizada para validar a URL de origem, repositórios em distribuições Linux utilizam sempre uma chave pública como referência com o objetivo de permitir que o sistema operacional valide a origem de onde os pacotes serão baixados na família Debian esse conceito é chamado de [Secure Apt conforme detalhado nessa documentação](https://wiki.debian.org/SecureApt), vale a pena a leitura!;

3.3 Para corrigir o repositório adicione uma chave publica:

```sh
curl -O https://nginx.org/keys/nginx_signing.key && apt-key add ./nginx_signing.key && rm nginx_signing.key
```

> Todo repositório oficial disponibiliza uma chave GPG que deve ser adicionada ao sistema operacional, no exemplo acima executamos o download dessa chave e incorporação utilizando o comando 'apt-key add';

---

## 4. Atualizando a aplicação

4.1 Finalmente instale a nova versão do Nginx!

```sh
sudo apt-get update && sudo apt-get install nginx
```

> Verifique que mesmo com a aplicação já instalada ao adicionar o repositório oficial teremos uma nova versão a disposição, essa versão será indexada ao executarmos o comando apt-get update e instalada ao executarmos o comando apt-get install que sempre manterá a versão mais nova disponível instalada o que neste caso representa um upgrade da versão atual.

4.2 Verifique se a versão instalada é mais nova que a anterior:

```sh
nginx -v
```

4.3 Após a atualização reincie o serviço:

```sh
systemctl restart nginx
```

---

# Fast Challenge: Hora de popular o seu servidor de conteúdo

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/DEF_goal.png)
Imagem de <a href="https://pixabay.com/pt/users/Tumisu-148124/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=1955806">Tumisu</a> por <a href="https://pixabay.com/pt/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=1955806">Pixabay</a>

Nesta etapa você substituirá o conteúdo padrão exibido pelo Nginx por um conteúdo próprio customizado;

Todo servidor de conteúdo possui um "document root" isto é, um diretório padrão a partir do qual o conteúdo é entregue a cada requisição HTTP, no caso do nginx em sua instalação padrão na família Debian o diretório responsável por servir o conteúdo é o "/usr/share/nginx/html", seu trabalho será remover o conteúdo deste repositório e substituir pelo conteúdo disponível [neste template](https://github.com/fiapsistemaslinux/SysOps/raw/master/lessons/L02/anexos/pizza.tar.bz2) adequado do [W2School](https://www.w3schools.com/w3css/w3css_templates.asp);

O resultado final deverá ficar mais ou menos assim:

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/L02_challenge01.png)


**Dica:** Para este exercício basicamente seu trabalho será *remover todo o conteúdo do diretório "/usr/share/nginx/html" e em seguida baixar e expandir o novo conteúdo, para isso dois comandos que ainda não testamos em aula serão necessários:

```sh
# WGET: Utilize o wget para baixar o conteúdo do template:
wget  https://github.com/fiapsistemaslinux/SysOps/raw/master/lessons/L02/anexos/pizza.tar.bz2

# RM: Como faremos a substituição do conteúdo remova o diretório /usr/share/nginx/html

# TAR: Quando utilizado para expandir arquivos o tar funciona dessa forma:
tar -xvf <path com o arquivo original>

# Você deve fazer a expansão e em seguida mover a pasta para o local correto (/usr/share/nginx/) não deixe de consultar cada um dos parâmetros do tar no man!
```

> Embora não seja um pré-requisito neste caso, é uma boa práticar adequar as permissões do novo conteúdo de acordo com o usuário que acessa esses recursos, neste caso o usuário de sistemas nginx, não esqueça de fazer isso de forma recursiva praticando o conteúdo das aulas sobre chmod =)

---

# QUIZ:

![alt tag](https://raw.githubusercontent.com/fiapsistemaslinux/SysOps/master/images/DEF_quiz.png)
Imagem de <a href="https://pixabay.com/pt/users/AnnCarter-162688/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2174368">Ann Carter</a> por <a href="https://pixabay.com/pt/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2174368">Pixabay</a>

Com base no exercício que executamos responda a essa três perguntas simples neste formulário, sua resposta será utilizada como mérito na nossa avaliação semestral;

Link do formulário: [https://form.jotform.com/200794325273051](https://form.jotform.com/200794325273051)

---

Referências:

- [Updating the GPG Key for NGINX Products](https://www.nginx.com/blog/updating-gpg-key-nginx-products/);

- [Nginx processo de Instalação e configuração](https://www.nginx.com/resources/wiki/start/topics/tutorials/install/);

