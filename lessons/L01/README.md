##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br



---

# Customizando a Shell

Neste LAB algumas funções relacionadas a gerenciamento de acessos e customização básica de um sistema linux serão abordados;

**Objetivo:**
Customizar o histórico e as informações que aparecem no banner de autenticação em um terminal linux

---

## 1. Customizando o histórico com base em variavéis da SHELL

Em um sistema GNU/Linux o histórico de execução de comandos pode ser manipulado a partir do comando History, o formato dessa informação pode ser alterado a partir da customização das variáveis de ambiente referentes ao histórico, são elas:

```console
HISTSIZE
HISTCONTROL
HISTFORMAT
HISTFILESIZE
```

Identifique qual a função dessas variaveis e configure o seguinte cenário:

1.1 O histórico deverá possuir o formato: YYYY-MM-DD h:m - <Comando do Histórico>
Por exemplo: "2020-02-16 19:15 - sudo apt update" 
Esta configuração deverá ser definitiva e aplicada apenas ao usuário "root";

1.2 Configure o histórico com 3000 linhas de conteudo, esta configuração deve ser definitiva e aplicada a TODOS os usuários;

## 2. Customizando a mensagem de boas vindas

Outra customização aplicável na configuração de um sistema é definir um padrão de mensagem a ser exibida após a autenticação do usuário, chamamos este tipo de mensagem de banner;

O banner de sessão nas distro derivadas da Familia Debian se encontra nos arquivos:

| Arquivo        | Função                                                                                |
|----------------|---------------------------------------------------------------------------------------|
| /etc/issue     | Configuração da mensagem exibida no login de um usuário via sessão local no terminal; |
| /etc/issue.net | Configuração da mensagem exibida no login de um usuário via acesso remoto;            |

**step-by-step**

2.1 - Altere o arquivo referente ao acesso remoto (se estiver utilizando um host linux instalado localmente altere o arquivo "/etc/issue");

Exmeplo:

```sh

ACESSO RESTRITO
---------------

Todas as conexões a este ambiente são monitoradas e gravadas;
Desconecte imediatamente se não possui autorização de acesso;

@Fiap Linux Systems

```

2.2 - Além da alteração no arquivo é necessário liberar o uso do banner, para isso com um editor de textos abra o seguinte arquivo:

```sh
# sudo vim /etc/ssh/sshd_config
```

2.3 - Localize a linha com a instruçãode configuração do banner (trata-se de uma linha comentada, remova o comentário e edite conforme abaixo);

```sh
# no default banner path
Banner /etc/issue.net
```

2.4 - Após alterar o arquivo reinicie o serviço de SSH:

```sh
# sudo systemctl restart sshd
```

2.5 - Finalmente abre um segundo terminal e faça a autenticação para verificar se a mensagem customizada foi exibida;

---

**Free Software, Hell Yeah!**
