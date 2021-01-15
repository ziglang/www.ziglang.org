---
title: Começando
mobile_menu_title: "Começando"
toc: true
---

{{% div class="box thin"%}}
**<center>Nota para usuários do Apple Silicon</center>**
Zig tem suporte experimental para a assinatura de códigos. Você poderá usar Zig com seu M1 Mac,
mas a única maneira de conseguir Zig para macOS em ARM64 é compilá-lo você mesmo.
Certifique-se de verificar a seção [Compilando da Fonte](#compilando-da-fonte).
{{% /div %}}


## Marcar (Tags) as versões de lançamento e nightly?
Zig ainda não atingiu a v1.0 e o atual ciclo de liberação está ligado a novas liberações de LLVM, que têm uma cadência de ~6 meses.
Em termos práticos, **As versões Zig tendem a ser muito distantes e eventualmente se tornam obsoletas, dada a velocidade atual de desenvolvimento**.

É bom avaliar o Zig usando uma versão com tags, mas se você decidir que gosta do Zig e quer mergulhar mais fundo, **nós o encorajamos a atualizar para versão nightly**, principalmente porque dessa forma será mais fácil para você obter ajuda: a maioria da comunidade e sites como
[ziglearn.org](https://ziglearn.org) se baseiam no *master branch* pelas razões acima expostas.

A boa notícia é que é muito fácil mudar de uma versão Zig para outra, ou mesmo ter várias versões presentes no sistema ao mesmo tempo: As versões Zig são arquivos autocontidos que podem ser colocados em qualquer lugar em seu sistema.


## Instalando Zig
### Baixar diretamente
Esta é a maneira mais direta de obter o Zig: pegue um pacote Zig para sua plataforma a partir da página [Baixar](../../download),
extrair em um diretório qualquer e adicioná-lo ao seu `PATH` para poder utilizar o executável `zig` de qualquer lugar.

#### Configurando PATH no Windows
Para configurar seu caminho no Windows, execute **um** dos seguintes trechos de código em uma instância Powershell.
Escolha se você deseja aplicar esta mudança em nível de sistema (requer a execução de Powershell com privilégios administrativos) ou apenas para seu usuário, e ** certifique-se de mudar o trecho para apontar para o local onde se encontra sua cópia do Zig***.
O `;` antes do `C:` não é um erro de tipo.

Modo privilegiado do sistema (**admin** no Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\your-path\zig-windows-x86_64-your-version",
   "Machine"
)
```

Modo usuário (**sem privilégio** no Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\your-path\zig-windows-x86_64-your-version",
   "User"
)
```
Depois de terminar, reinicie sua instância do Powershell.

#### Configurando PATH no Linux, macOS, BSD
Adicione a localização de seu binário zig à sua variável de ambiente `PATH`.

Isso geralmente é feito adicionando uma linha de exportação ao seu script de inicialização do shell. (`.profile`, `.zshrc`, ...)
```bash
export PATH=$PATH:~/path/to/zig
```
Depois de feito, seu arquivo inicial ou `source`, reinicie o shell.




### Gerenciadores de pacotes
#### Windows
Zig está disponível no [Chocolatey](https://chocolatey.org/packages/zig).
```
choco install zig
```

#### macOS

**Homebrew**  
NOTA: Homebrew ainda não possui os pacotes para Apple Silicon. Se você tem um M1 Mac, você deve compilar o Zig a partir da fonte.

Última versão de lançamento:
```
brew install zig
```

Última compilação do *master branch* de Git:
```
brew install zig --HEAD
```

**MacPorts**
```
port install zig
```
#### Linux
Zig também está presente em muitos gerentes de pacotes para Linux. [Aqui](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
você pode encontrar uma lista atualizada, mas tenha em mente que alguns pacotes podem conter versões desatualizadas do Zig.

### Compilando da Fonte
[Aqui](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) 
você pode encontrar mais informações sobre como construir Zig a partir da fonte para Linux, MacOS e Windows.

## Ferramentas recomendadas
### Sintaxe dos Higlighters e LSP
Todos os principais editores de texto têm suporte de destaque de sintaxe para Zig. 
Alguns o empacotam, outros requerem a instalação de um plugin.  

Se você estiver interessado em uma integração mais profunda entre o Zig e seu editor, confira [zigtools/zls](https://github.com/zigtools/zls).

Se você estiver interessado no que mais está disponível, confira a seção [Tools](../tools/).

## Executar Hello World
Se você completou o processo de instalação corretamente, agora você deverá ser capaz de invocar o compilador Zig a partir do shell.  
Vamos testar isso criando seu primeiro programa Zig!

Navegue até o diretório de seus projetos e execute:
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

Isto deve sair:
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

Executando `zig build run` deve então compilar o executável e executá-lo, resultando em última instância:
```
info: All your codebase are belong to us.
```

Parabéns, você tem uma instalação Zig funcionando!  

## Próximos passos
**Verifique outros recursos presentes na seção** [Aprender](../), certifique-se de encontrar a Documentação de sua versão do Zig (nota: as construções nightly devem utilizar documentação `master`) e considerar dar uma lida no [ziglearn.org](https://ziglearn.org) também.

Zig é um projeto jovem e infelizmente ainda não temos a capacidade de produzir extensa documentação e materiais de aprendizagem para tudo, portanto, você deve considerar [juntando-se a uma das comunidades Zig existentes](https://github.com/ziglang/zig/wiki/Community)
para obter ajuda quando você ficar confuso, bem como para verificar iniciativas como [Zig SHOWTIME](https://zig.show).

Finalmente, se você gosta de Zig e quer ajudar a acelerar o desenvolvimento, [considere fazer uma doação para a Zig Software Foundation](../../zsf)
<img src="/heart.svg" style="vertical-align:middle; margin-right: 5px">.
