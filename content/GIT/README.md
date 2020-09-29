# Git

O termo **"Gerenciamento de Configuração" refere-se ao processo a partir do qual os componentes relevantes ao seu projeto e suas respectivas dependências são armazenadas, identificadas e modificadas,** essa lógica é amplamente usada na área de desenvolimento e automação, podendo ser aplicada em diversas esferas, no caso do desenvolvimento a maior prática relacionada ao gerenciamento de configuração seria o versionamento de código.

## Gerenciamento de Código (controle de Versões)

Quando o assunto é desenvolvimento ao considerar a visão e o foco dividido em vários projetos e quantidade de mãos atuando em uma mesma tarefa ou as etapas envolvidas é imperativo que se utilize algum modelo de repositório para armazenamento e gerenciamento de código, esses repositórios são o que chamamos de **repositórios de código**, o objetivo é armazenar seu trabalho em um local mais seguro e mais resiliente que um pen-drive, Uma vez que um bom modelo de versionamento de código seja utilizado ele deverá ser capaz de fornecer respostas para duas perguntas extremamente importantes:

***Quais componentes constituem uma versão específica de um software? E como poderemos reproduzir um estado particular destes binários bem como a configuração do software que existia no ambiente?***

***O que foi alterado e quando foi alterado, quem fez a alteração e qual foi o motivo?***

Essas duas perguntas poderiam ser enquadradas no questionário anterior, mas foram separadas por tratarem de uma questão específica sobre o gerencimaneto de configuração, o versionamento de código.

---

### Ferramentas de Controle de Versão

A maioria dos repositórios utiliza alguma arquitetura baseada em um centralizador, os mais antigos trabalhavam com servidores que faziam essa função utilizando protocolos como FTP, outros implementam tecnologias próprias e esquemas próprios para transporte e controle de dados baseando-se em protocolos como HTTPS e SSH eis alguns exemplos:

- [Git](https://git-scm.com/)
- [Marcurial](https://pypi.python.org/pypi/Mercurial)
- [Team Foundation Server](https://www.visualstudio.com/team-services/)
- [SVN](https://subversion.apache.org/)
- [CVS](https://sourceforge.net/p/mx4j/cvs/)

> A primeira ferramenta de controle de versão utilizada em grande escala foi a [SCCS](https://en.wikipedia.org/wiki/Source_Code_Control_System) (Source Code Control System) uma ferramenta proprietária desenvolvida para UNIX por volta de 1970, predecessores famosos foram tomando lugar como o [RCS](https://pt.wikipedia.org/wiki/Revision_Control_System) e o [CVS](https://pt.wikipedia.org/wiki/CVS) sendo que todas elas ainda são projetos ativos atualmente.

---

### O que exatamente deve ser versionado? ( Na verdade Tudo )

- Todo o código relativo a sua aplicação;
- Todos os scripts de configuração;
- Todo código de implementação interna ( O que chamamos de DSL ou domain-specific language );
- Todos os scripts utilizados para Build de imagens ( Dockerfile por exemplo );
- Todos os metadados ( Json, Yaml etc );
- Todos os scripts de Teste automatizados e TDDs;
- Toda a documentação e procedimentos de configuração ( Esta wiki é um exemplo );
- Todos os templates de modelos de "Infraestructure as a Code";
- Todos os templates utilizados em automação como (Cloudformation, Terraform ou Heat);
- Todos os schemas de Databases, configurações e definições de DNS e Firewall;
- ***Basicamente tudo mesmo...***

#### Na verdade quase tudo...

Existe uma tipo de componentes que gera alguma discussão sobre manter ou nçao sobre controle de versão, os **binários que compoẽm a aplicação**, particularmente neste conteúdo defenderemos que NÃO deve ser algo mantido sobre controle de versão por alguns razões gerais e outras baseadas na minha experiência pessoal com o assunto, A primeira delas é o tamanho, binários gerados com base em versões podem ocupar muito espeço e deifenrete do que ocorre com compiladores se proliferam bem rápido, (geralmente na mesma velocidade em que versionamos e liberamos releases).

---

Para nossos testes utilizaremos o git, atualmente a mais famosa ferramenta para versionamento e controle de código sendo utilizado em diversos projetos famosos como por exemplo:

- [Google](https://github.com/google)
- [Facebook](https://github.com/facebook)
- [Rails](https://github.com/rails/rails)
- [Twitter](https://github.com/twitter)
- [Linkedin](https://github.com/linkedin)
- [Netflix](https://github.com/netflix)
- [Microsoft](https://github.com/Microsoft)

> Na maioria dos casos as empresas que utilizam o git trabalham com o modelo de organizações, dentro dessas organizações esses projetos são disponibilizados em repositórios privados de uso interno ou abertos geralmente com código protejido por licenças baseadas na filosofia Open Source como as licenças [Apache](http://www.apache.org/licenses/LICENSE-2.0) e [GPLv3](https://www.gnu.org/licenses/gpl-3.0.pt-br.html);

## Ferramentas Saas para Git

Saas ou ( **S**oftware **a**s **a** **S**ervice ), esse termo refere-se a ferramentas comercializadas como serviços geralmente baseadas e hospedadas em Cloud Computing, no caso do Git essas ferramentas comerciais proporcionam um meio para armazenamento de repositórios online sendo o github o mais popular atualmente;

- [Github](http://www.github.com/)

O Github é um poderoso repositório online, o maior e mais famoso utilizando git, seu uso é gratuito para criação e administração de repositórios abertos, alguns exemplos podem ser encontrados na lista passada anteriromente.

Além do github outras duas ferramentas famosas podem ser boas opções:

- [Bitbucket](https://bitbucket.org/product)

O Bitbucket é um repositório mantido pela Atlassian, sua principal vantagem é a possibilidade de criar repositórios fechados para até 5 usuários um recurso que seria pago utilizando o github. Além disso a interface de gerenciamento é intuitiva e simples, o projeto também pode ser implementado como um servidor interno utilizando licenças pagas.

- [Gitlab](https://about.gitlab.com/gitlab-com/)

Fechando essa pequena lista temos o gitlab, um repositório Free que assim como o Bitbucket possui versões para instalação offline, entretanto neste caso com licença gratuita, logo a melhor relação custo benefício caso por algum motivo pretenda manter seu código longe da nuvem.

## Instalando e configurando o git

A instalação do git em sistemas linux é relativamente simples estando quase sempre disponível nos repositórios oficiais da distro, siga a [Documentação referente no github.io](https://git-scm.com/download/linux) e tudo deverá funcionar conforme esperado;

Para usuários do windows naturalmente não temos uma SHELL completa que permita a execução nativa, portanto o comum é que se utilize o pacote Git Bash conforme a prórpria documentação [Disponível no github.io](git-for-windows.github.io/).

Após a instalação execute o git config para definir os campos user.name e  user.email:

```sh
git config --global user.mail "usuario@email.com.br"
git config --global user.name "usuario"
```

## Estados de um repositório

Todo diretório tratado como repositório pelo git possuirá sempre um estado, este estado define como o repositório está em relação ao repositório principal do projeto, na prática temos três possibilidades:

- **working directory:** Representa o estado atual dos arquivos no repositório.

- **index:** Trata-se de uma area de "staging" que representa uma visão preliminar das modificações a serem integradas projeto;

- **HEAD:**  Versão "em produção" do projeto, funciona como uma referência para comparação com o conteúdo no working directory na execução de commits e merge de alterações;

> Partindo do inicio ao executarmos alterações em conteúdos no working directory essas alterações mantem-se em armazenamento local até que sejam adicionadas ao index, (Utilizando a função git add fazemos essa adição), uma vez que estejam no index essa alterações poderão ser adicionada ao repositório do projeto a partir de um commit (Caso estejamos utilizando branchs o processo de merge também será necessário);

## Recursos interessantes do Git

O uso do git vai desde o conteúdo básico presente no processo de commits até algumas possibilidades de nível intermediário e avançado, sendo que algumas delas podem ser realmente úteis no dia a dia, abaixo alguns desses processos são descritos como recomendação de estudos:

### Resolução de Conflitos com merge

O proceso de merge para resolução de conflitos é uma das questões mais importantes sobre o git, afinal acidentes acontecem... principalmente ao se trabalhar com repositórios remotos e branchs de forma colaborativa;

A documentação oficial do git possui uma boa referência sobre o processo de merge e pode ser acessada neste endereço: [https://git-scm.com/docs/git-merge](https://git-scm.com/docs/git-merge);

### O git rebase

O Git rebase é uma poderosa ferramenta de auxilio e otmização de seus processos de merge entre branchs podendo ser muito útil na reestruturação de commits, ou seja, a partir dele é possível modificar a quantidade de commits que envolveram uma determinada alteração, assim em um cenário onde vários commits foram feitos podemos usar o rebase para mandar isso ao repositório principal remoto como um único commit por exemplo;

Outra função muito útil no processo de rebase é a integração de mudanças, a ideia por trás do rebase é alterar a referencia de uma branch evitando conflitos no processo de push e evitando merge de código;

Você encontrará mais detalhes na documentação do git no scm: [Git Branching - Rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing).

Vale a pena entender como o reabase atua, pois pode ser muito util e economizar um boa dor de cabeça;

### Trabalhando com Tags

O uso de tags é um recurso muito útil no trbalho colaborativo e na geração de releases, a ideia por trás das tags é que podemos marcar pontos especificos do desenvolvimento que são considerados importantes, esses pontos geralmente são representados por release de códigos e facilitam o processo de recuperação de versões especificas de seu trabalho; verifique a documentação do git no scm em [Git Basics - Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging) e se você nunca utilizou tags essa é uma boa hora para começar a pensar no assunto;

### Usando o cherry-pick para manipulação avançada

O recurso cherry pick do git é uma ferramenta avançada útil em processos onde é necessário adicionar apenas alguns commits de uma determinada branch em outra;

> A diferença básica para o rebase é que usando o rebase ou um processo padrão de merge todos os commits de uma branch são aplicados a branch de destino,  com o cherry-pick é possível que somente alguns commits sejam aplicados em outra branch.

***Quando utilizar o cherry-pick?***

Um dos casos mais comuns para uso do cherry-pick é em situações onde um pull request ou um merge entre branchs  será recusado, porém existem commits com código que podem ser aproveitados. Neste caso estes commits teria mde ser isolados e importados pra dentro da sua branch atual, dai o uso do cherry-pick.

---

### Outros Pontos Importantes

***Mensagens de "Commits" Inteligentes***

Todo e qualquer sistema de versionamento possui um mecanismo a partir do qual é possível adicionar mensagens e informações descritivas ao commit, criar mensagens descritivas e que remetam ao que foi modificado facilita muito o processo de depuração de erros e até a documentação de seu projeto.

Um modelo interessante é o uso de mensagens em várias linhas ou parágrafos, onde a primeira linha ou paragrafo seria um resumo do que foi feito, como o titulo de uma redação e as outras linhas ou parágrafos adicionariam detalhes. Essa lógica faz sentido pois na mairoai das ferramtnas principalmente aquelas baseadas em git o primeiro parágrafo é exibido em destaque na interface da ferramentas de versionamento.

Você também pode incluir links para o identificar a task relacionada em sua ferramenta de gerenciamento de projetos como um quadro kanban ou scruem e quando existir o link para bug reportado, no caso de ferramentas de acionamento de chamados por exemplo.

Em muitas equipes administradores de sistema criam bloqueios em suas ferramentas de controle de versão, de modo a garantir que essas informações sejam adicionadas.

> Existem vários termos que vieram do inglês e não possuem uma tradução literal, pelo menos não uma que seja usual. Commit é uma caso, é muito comum ouvir entre os times de desenvolvimento o termo "commitar" referindo-se a atualização de repositórios remotos de acordo com as mudanças feitas em uma cópia local, iremos por esse caminho também, e o ponto a ser abordado aqui é a importãncia em commitar no repositório principal com frequência:

***"Commits" frequentes, tanto quanto possível***

Quando você executa o commit de código no repositório principal suas mudanças tornam-se disponíveis para todos os outros no time. Caso você possua algum modelo de integração contínua implementado (e você realmente deveria ter), suas mudanças também acabarão por dar origem a um processo de build, testes automatizados e quem sabe na entrada dessas mudanças em produção.

Por esse motivo é quase instintivo que façamos o contrário, deixemos os commits para o final de ciclos de desenvolvimento, o que pode querer dizer que suas alterações entraram a cada uma ou duas semanas, dai a ideia de agendamento de deliverys amplamente utilizada até hoje. Essa prática tende a ser desencorajada no cenário devops.

A abordagem recomandada é desenvolver e implementar de forma incremental, o commit regular proporcionará a longo prazo maior segurança e diminuirá os ciclos no processo de entrega de código, afinal uma nova feature só é realmente entregue quando quando colocada em produção gerando valor ao negócio. Isso também significará passar a se importar mais com a fase de testes e com a qualidade de suas entregas garantindo que falhas e bugs sejam enctrados imediatamente e reduzindo a complexidade dos deliverys, e o temido conflito no processo de merge. Essa lógica vale tanto para o código quanto para configurações e outras coisas mantidas sob controle via versionamento.

Testes automatizados são essenciais e sua execução obviamente deve ser feita antes do processo de commit. Logo você deverá ter como fazer isso de forma local, estamos falando de um conjunto de testes rápidos (menos de dez minutos) mas relativamente abrangentes, capazes de verificar se você não introduziu nenhuma falha capaz de quebrar o build ou algum tipo de regressão no que já foi feito.

>  Muitos servidores de integração contínua possuem um recurso chamado "pretested commit" que permite que você execute estes testes em um ambiente semelhante ao de produção antes de fazer o check-in.

---

## Material de Referência e Recomendações

Conforme descrito acima a Alura oferece um interessante curso sobre git que pode ser obtido no endereço abaixo:

 - [Curso de git Alura](https://www.alura.com.br/curso-online-git);

O Git Immersion é um curso voltado a prática que funciona como um guide line sobre git:
 - [Git Immersion Guide](http://gitimmersion.com/)

No mesmo layout do Git Immersion porém com um formato mais básico temos o TryGit:
 - [Trygit](https://try.github.io)

A melhor das referências que já encontrei até aqui, o Guia Prático Git:
 - [Git - Guia Prático](http://rogerdudler.github.io/git-guide/index.pt_BR.html)

Conteúdo oficial do git publicado no formato de um ebook online:
 - [Git Book](https://git-scm.com/book/pt-br/v2)

Guia de referência Git exemplificando o processo em formato gráfico:
 - [A Visual Git Reference](http://marklodato.github.io/visual-git-guide/index-en.html)

Recentemente descobri um pacote de recursos extras para o git capaz de adicionar features interessantes para usuários intermediários e avançados:
- [Git extras](https://github.com/tj/git-extras)

---

**Free Software, Hell Yeah!**
