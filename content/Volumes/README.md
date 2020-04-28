##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---

# Gerenciando Volumes

Do ponto de vista técnico da pra dividir as tarefas relacionadas a sistemas de arquivos em duas partes, o gerenciamento físico voltada para infra-estrutura de hardware e suporte a esquema de partições e o gerenciamento lógico voltado para a definição dos pontos de montagem.

## Montagem de Partições:

Uma das questões mais importantes sobre a administração de infraestrutura Linux é saber como aplicar um sistema de arquivos e executar a montagem destes sistemas em partições falando de forma simplificada o processo de motagem de uma partição consiste em criar o relacionamento lógico entre uma determinada partição de disco ( na maioria dos casos hardware físico mesmo ) e um ponto de montagem, o ponto de montagem é o endereço lógico a partir do qual se acessa detrminada partição.

Do ponto de vista da FHS dois diretórios cosutam ser usados na montagem de partições:

* /media: Utilizado para montagem automática de partições como por exemplo pen drives, unidades de CDROM, eletrônicos etc.
* /mnt: Usado para montagem de diretórios fixos, diretórios que não dependem de dispositivos externos e cuja montagem deverá ocorrer a cada inicialização do sistema.

> Existem outras possibilidades como uso de diretórios dentro do /srv para configuração de serviços ou a montagem de pontos especificos do /var como diretórios de logs, cache de  outros conteudos cujo tamanho tenda a crescer com o tempo. A ideia é utilizar um ponto de montagem seprada para não comprometer o sistema inteiro em caso de uso de 100% do disco e até para facilitar operações de expansão nessas partições.

```sh
# O comando mount permite verificar quais são as partições montadas:
mount
```

Quando executado sem a passgem de parâmetros o comando acima permite visualizar a relação de sistemas de pontos de montagem ativos no sistema, essa relação vem do arquivo /proc/mounts:

```sh
cat /proc/mounts
```

> Da relação da saida do comando mount acima abordaremos apenas os filesystems usados nos pontos destacados e o udev, para outros vale uma olhada na DOC oficial do kernel.
Já para o cgroups verificar conteudo extra no final do capítulo.

## Testando um ponto de montagem:

**Objetivo:** 	Para explicar os conceitos relacionados a filesystem e pontos de montagem faremos a montagem manualmente do seguinte grupo de partições:

| Disco      | Montagem             | Filesystem | Tamanho | Função                                                                      |
|------------|----------------------|------------|---------|-----------------------------------------------------------------------------|
| /dev/xvdh1 | /var/lib/ redis/data | ext4       | 8G      | Simular a migração do conteúdo de uma base de dados para um volume distinto |
| /dev/xvdh2 | SWAP                 | SWAP       | 2G      | Testar o conceito de memória SWAP                                           |


## Aplicação de filesystem:

Para começar adicione um disco ao sistema linux sendo utilizado nestes testes, qualquer sistema relaticamente atualizado entre as familias RedHat e Ubuntu deverá servir.

Para aplicar um determinado filesystem a um disco utilizamos o utilitário fdisk, um recurso  bem antigo que inclusive faz parte do MS-DOS

> Outra opção é o uso do CFDISK que utiliza uma biblioteca ncurses para propor uma interface consideravelmente mais intuiva que a do fdisk.  

```sh
fdisk /dev/xvdh
```

>  Ao executar o fdisk aponte para um determinado disco, em seguida utilize a letra “m” para visualizar um menu com os recursos disponíveis para gerenciar o disco.

```sh
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x29ff228b.

Command (m for help): m
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   g   create a new empty GPT partition table
   G   create an IRIX (SGI) partition table
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)

Command (m for help):
```

Dentre as opções oferecidas pelo fdisk as tarefas mais comuns são as seguintes:

* p: Exibir as partições configuradas no disco escolhido de acordo com a tabela de partições.
* n: Criar uma nova tabela de partição;
* d: Apagar uma partição existente;
* w: Gravar alterações no sistema de arquivos;
* q: Sair ( Caso precise salvar as alterações utilizar a opção “w” antes )

1. Para nosso exemplo utilize **n** para novo, escolha uma partição do tipo **primária**:

```sh
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1):
```

2. Defina a partição como sendo a primeira partição do disco e portanto a partição **1**:

```sh
Partition number (1-4, default 1): 1
First sector (2048-20971519, default 2048):
```

3. Você será questionado sobre qual o primeiro setor a ser utilizado neste particionamento precione enter para manter a escolha padrão baseada noprimeiro setor livre no seu disco:

```sh
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-20971519, default 20971519):
```

4. O passo seguinte será definir o tamanho da partição, utilizaremos 8G:

```sh
Last sector, +sectors or +size{K,M,G} (2048-20971519, default 20971519): +8G
Partition 1 of type Linux and of size 8 GiB is set

Command (m for help):
```

5. Utilize a **opção p** para visualizar suas alterações e em seguida salve utilizando a **opção “w”**:

```sh
Command (m for help): p

Disk /dev/xvdh: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x29ff228b

    Device Boot      Start         End      Blocks   Id  System
/dev/xvdh1            2048    16779263     8388608   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

```

**sua vez:**
Repita os mesmos passos para criar a partição de 2GB conforme o exemplo anterior e a tabela proposta para a aula, o resultado final ao exibir novamente a tabela de partições deverá ser algo mais ou menos assim:

> Lembre-se que dessa vez a partição criada é a segunda por tanto indice "2", utilize o tamanho total disponível no disco de aproximadamente 2G;

Finalizado a configuração Do disco será possível visualizar o esquema de particionamento aplicado a partir do arquivo /proc/partitions:
  
  ```sh
  cat /proc/partitions | grep xvdh
  ```
  
## Conceitos sobre filesystem
	
Aplicar um "filesystem" significa criar uma estrutura lógica acima das trilhas e setores de um disco rígido de forma que permita organizar seus arquivos em uma estrutura de diretórios e subdiretórios, abaixo uma descrição resumida dos principais filesystem utilizados atualmente em sistemas GNU/Linux:

Sistema de arquivos ext2 → O sistema de arquivos ext2 (também conhecido como o segundo sistema de arquivos estendido) foi desenvolvido para abordar defeitos no sistema de arquivos Minix usado em versões anteriores do Linux. Ele foi usado intensivamente no Linux por muitos anos, hoje em dia praticamente não se utiliza o ext2, isso porque não há journaling nesse sistema de arquivos tendo sido substituído em grande parte pelo ext3 e recentemente pelo ext4, sua introdução aqui é mais a nível de contextualização.


### Sistema de arquivos ext3
O sistema de arquivos ext3 adiciona capacidade de journaling a um sistema de arquivos ext2 padrão e é, portanto, um crescimento evolutivo de um sistema de arquivos muito estável.

### Sistema de arquivos ext4
O sistema de arquivos ext4 foi implementado definitivamente a partir da versão 2.6 do kernel Linux lançado em 2008, este sistema é uma evolução do ext3 com maior escalabilidade e confiabilidade sendo disparado o filesystem mais utilizado nas distros atuais, para obter detalhes siga o link no final da página.

> É possível converter um sistema de arquivos ext3 em ext4 e até mesmo converter de volta se necessário, para isto utilize o comando tune2fs (consulte: man tune2fs).> 

### Sistema de arquivos ReiserFS
Ótimo sistema de arquivos para arquivos menores que 4GB; o ReiserFS é um sistema baseado em árvore que possui um bom desempenho geral, especialmente para um grande número de arquivos pequenos. O ReiserFS também escala bem e possui journaling.

### O sistema de arquivos XFS
Usado geralmente em banco de dados. O XFS é um sistema sem journaling. Ele vem com recursos robustos e é otimizado para escalabilidade. O XFS oculta com rigor dados em trânsito na RAM, de modo que uma fonte de alimentação ininterrupta é recomendada se você usa XFS.

**Ainda sobre o EXT4**:
O ext4 foi lançado em 2008 sendo o padrão mais recente do sistema de arquivo extendido utilizado em partições linux,  não abordaremos detalhes sobre o ext4 ou suas versões anteriores, [portanto utilize este link como opção de estudos](https://www.ibm.com/developerworks/br/library/l-anatomy-ext4/), trata-se de um ótimo artigo da IBM sobre o assunto.

## Aplicando um Filesystem:

Para criarmos um "filesystem" em uma partição, devemos escolher o seu tipo e utilizar o comando "mkfs" com a seguinte sintaxe:

```sh
mkfs –t tipo_de_filesystem <dispositivo>
# ou
mkfs.<tipo_de_filesystem> <dispositivo>
```

1. Para nosso modelo aplique o sistema de arquivos xfs vnas partição 1:

```sh
mkfs.xfs /dev/xvdh1

meta-data=/dev/xvdh1             isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

## Montando uma partição manualmente:

O comando usado para montar dispositivos é "mount". Sem o uso de nenhum parâmetro, ele mostra os dispositivos de armazenamento que estão montados em seu computador junto com a configuração usada para montá-los.

```sh
mount
```

Faça a montagem manual da partição:

```sh
mount /dev/xvdh1 /mnt

 df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        895M     0  895M   0% /dev
tmpfs           919M     0  919M   0% /dev/shm
tmpfs           919M   17M  902M   2% /run
tmpfs           919M     0  919M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  1.4G  6.6G  18% /
tmpfs           184M     0  184M   0% /run/user/1000
/dev/xvdh1      8.0G   33M  8.0G   1% /mnt
```

Para desmontar um dispositivo, o comando usado é "umount". Neste caso é possível usar como parâmetro o ponto de montagem ou o próprio dispositivo, por exemplo:

```sh
umount /dev/xvdh1
# ou 
umount /mnt
```

## Particionamento de SWAP:

Alguns sistemas Linux utilizam SWAP como memória secundária;

> Colocando em termos gerais é um tipo de cache utilizado para otimizar o desempenho servindo como auxilio a própria memória RAM 


Para criar uma partição de SWAP utilize o comando mkswap conforme abaixo:
  
  ```sh
  mkswap /dev/xvdh1
  
Setting up swapspace version 1, size = 2096124 KiB
no label, UUID=4b678eb6-a4ae-4385-830a-2502e5383cf2
```

Após criar a SWAP é necessário que ela seja ativada, para isso utilize o comando swapon, mas antes verifique o montante de memória SWAP atual e faça a comparação:
  
```sh
# Verifique a swap antes da ativação:
free -m

# Ative a memória Swap:
swapon /dev/xvdh2 && free -m
```

## Configuração de montagem automatica utilizando o FSTAB:

Os sistemas GNU/Linux possuem um arquivo que contem as informações a respeito da montagem de todos os "filesystems" do sistema, Este arquivo é o "/etc/fstab". O arquivo é lido na inicialização do sistema e é quem diz ao sistema o que montar, onde montar e os parâmetros de montagem:

```sh
cat /etc/fstab
```

### Representação de discos utilizando UUID e Label

Além do nome uma alternativa inteligente para especificar o disco/partição utilizado  é o método "UUID – Universally Unique Identifier" ou o método de Labels.

No GNU/Linux todo dispositivo possui um UUID que funciona como um registro único ou uma chave primária que identifica o disco em questão, para descobrirmos o "UUID" de nossas partições podemos utilizar o aplicativo blkid:

```sh
blkid
```
