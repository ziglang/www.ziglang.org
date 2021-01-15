---
title: "Visão Geral"
mobile_menu_title: "Visão Geral"
toc: true
---
# Destaques
## Linguagem simples e pequena

Concentre-se na depuração de sua aplicação em vez de depurar seus conhecimentos em uma linguagem de programação.

Toda a sintaxe do Zig é especificada com um [Arquivo gramatical PEG de 500 linhas](https://ziglang.org/documentation/master/#Grammar).

Não há **nenhum fluxo de controle oculto**, nenhuma alocação de memória oculta, nenhum pré-processador, e nenhuma macros. Se o código Zig não parece estar pulando para chamar uma função, então não está. Isto significa que você pode ter certeza de que o seguinte código chama apenas `foo()` e depois `bar()`, e isto é garantido sem a necessidade de saber os tipos de nada:

```zig
var a = b + c.d;
foo();
bar();
```

Exemplos de fluxo de controle oculto:

- D tem funções `@property`, que são métodos que você chama com o que parece ser acesso de campo, então no exemplo acima, `c.d` poderia chamar uma função.
- C++, D, e Rust têm sobrecarga do operador, portanto o operador `+` pode chamar uma função.
- C++, D, e Go têm exceções do tipo `throw/catch`, portanto `foo()` pode lançar uma exceção, e impedir que `bar()` seja chamado.

Zig promove a manutenção do código e a legibilidade, fazendo com que todo o fluxo de controle seja gerenciado exclusivamente com palavras-chave do idioma e chamadas de função.

## Performance and Safety: Choose Two

Zig tem quatro [modos de compilação](https://ziglang.org/documentation/master/#Build-Mode), e todas elas podem ser misturadas e combinadas até a [granularidade do escopo](https://ziglang.org/documentation/master/#setRuntimeSafety).

| Parametro | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
Otimizações - melhorar a velocidade, depuração de danos, tempo de compilação de danos | | -O3 | -O3| -Os |
Verificações de segurança em tempo de execução - velocidade do dano, tamanho do dano, acidente ao invés de comportamento indefinido | On | On | | |

Aqui temos [Sobrecarga de Inteiros (Integer Overflow)](https://ziglang.org/documentation/master/#Integer-Overflow) que parece estar em tempo de compilação, independentemente do modo de compilação:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

Aqui está o que parece em tempo de execução, em construções verificadas em termos de segurança:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


Esses [rastreamentos de pilhas funcionam em todos os dispositivos](https://ziglang.org/#Stack-traces-on-all-targets), incluindo [freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

Com Zig pode-se confiar em um modo de compilação `safe-enabled`, e desativar seletivamente a segurança nos gargalos de desempenho. Por exemplo, o exemplo anterior poderia ser modificado desta forma:

{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig utiliza [comportamento indefinido](https://ziglang.org/documentation/master/#Undefined-Behavior) com inteligência tanto para a prevenção de bugs quanto para a melhoria do desempenho.

Por falar em desempenho, Zig é mais rápido que C.

- A implementação de referência utiliza LLVM como um backend para as otimizações de ponta.
- O que outros projetos chamam de "Link Time Optimization" e Zig faz automaticamente.
- Compila de forma nativa para qualquer dispositivo, utilizando recursos avançados da CPU que são habilitados (-march=native), graças ao fato da [compilação cruzada ser um caso de uso de primeira classe](https://ziglang.org/#Cross-compiling-is-a-first-class-use-case).
- Comportamento cuidadosamente escolhido e indefinido. Por exemplo, em Zig, tanto os inteiros assinados como os não assinados têm um comportamento indefinido no transbordamento, ao contrário de apenas os inteiros assinados em C. Isto [facilita as otimizações que não estão disponíveis em C](https://godbolt.org/z/n_nLEU).
- Zig expõe diretamente a [vetores tipo SIMD](https://ziglang.org/documentation/master/#Vectors), facilitando a escrita de código vetorizado portátil.

Favor notar que Zig não é uma linguagem totalmente segura. Para aqueles interessados em seguir a história de segurança do Zig, inscrevam-se para estas questões:

- [enumerate all kinds of undefined behavior, even that which cannot be safety-checked](https://github.com/ziglang/zig/issues/1966)
- [make Debug and ReleaseSafe modes fully safe](https://github.com/ziglang/zig/issues/2301)

## Zig compete com C, em vez de depender dele

A biblioteca padrão do Zig se integra com a libc, mas não depende dela. Aqui está o "Hello World":

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Quando compilado com `-O ReleaseSmall`, símbolos de depuração são removidos (stripped), modo de thread única, isto produz um executável estático de 9,8 KiB para a plataforma x86_64-linux:
```
$ zig build-exe hello.zig --release-small --strip --single-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

No Windows é ainda menor, gerando um binário de 4096 bytes:
```
$ zig build-exe hello.zig --release-small --strip --single-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Pedir declarações independentes de alto nível

Declarações de alto nível, tais como variáveis globais, são independentes de ordem e analisadas preguiçosamente. O valor de inicialização das variáveis globais é [avaliado em tempo de compilação](https://ziglang.org/#Compile-time-reflection-and-compile-time-code-execution).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## Tipo optional em vez de ponteiros nulos

Em outras linguagens de programação, referências nulas são a fonte de muitas exceções de tempo de execução, e até mesmo são acusadas de ser [o pior erro da ciência da computação](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

As indicações Unadorned Zig não podem ser nulas:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

Entretanto, qualquer tipo pode ser transformado em um [tipo optional](https://ziglang.org/documentation/master/#Optionals) prefixando-o com ?:

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

Para utilizar um valor opcional, pode-se utilizar `orelse` para fornecer um valor padrão:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

Outra opção é usar `if`:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

 A mesma sintaxe funciona com [while](https://ziglang.org/documentation/master/#while):

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## Gerenciamento manual de memória

Uma biblioteca escrita em Zig é elegível para ser usada em qualquer lugar:

- [Aplicações desktop](https://github.com/TM35-Metronome/) & [Jogos](https://github.com/dbandstra/oxid)
- Servidores de baixa latência
- [Kernel do Sistema Operacional](https://github.com/AndreaOrru/zen)
- [Dispositívos Embarcados](https://github.com/skyfex/zig-nrf-demo/)
- Software em tempo real, por exemplo, apresentações ao vivo, aviões, marcapassos
- [Em navegadores web ou outros plugins com WebAssembly](https://shritesh.github.io/zigfmt-web/)
- Por outras linguagens de programação, utilizando a C ABI

Para conseguir isto, os programadores Zig devem gerenciar sua própria memória e devem lidar com falhas na alocação de memória.

Isto também é verdade para a Biblioteca Padrão Zig. Qualquer função que precise alocar memória aceita um parâmetro do alocador. Como resultado, a Biblioteca Padrão Zig pode ser usada até mesmo para o dispositivo freestanding.

Além de [Uma nova tomada de controle de erros](https://ziglang.org/#A-fresh-take-on-error-handling), Zig fornece [defer](https://ziglang.org/documentation/master/#defer) e [errdefer](https://ziglang.org/documentation/master/#errdefer) para tornar a gestão de todos os recursos - não apenas a memória - simples e facilmente verificável.

Por exemplo o `defer`, veja [Integração com bibliotecas C sem FFI/bindings](https://ziglang.org/#Integration-with-C-libraries-without-FFIbindings). Aqui está um exemplo de utilização de `errdefer`:
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## Uma nova tomada de controle de erros

Os erros são valores, e não podem ser ignorados:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

Os erros podem ser tratados com [catch](https://ziglang.org/documentation/master/#catch):

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

A palavra-chave [try](https://ziglang.org/documentation/master/#try) é um atalho para `catch |err| return err`:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

Note que é um [Rastreamento do retorno de erro](https://ziglang.org/documentation/master/#Error-Return-Traces), não um [rastreamento da pilha](https://ziglang.org/#Stack-traces-on-all-targets). O código não pagou o preço de desenrolar a pilha para chegar a esse rastreamento.

O [switch](https://ziglang.org/documentation/master/#switch) palavra-chave utilizada em um erro garante que todos os erros possíveis sejam tratados:

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

A palavra-chave [unreachable](https://ziglang.org/documentation/master/#unreachable) é usado para afirmar que não ocorrerão erros:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

Isto invoca um [comportamento indefinido](https://ziglang.org/#Performance-and-Safety-Choose-Two) nos modos de compilação inseguros, portanto, certifique-se de usá-lo somente quando o sucesso for garantido.

### Rastreamento de pilha em todos os dispositivos

O rastreamento da pilha e [rastreamento do retorno de erros](https://ziglang.org/documentation/master/#Error-Return-Traces) mostram que nesta página funcionam todos os dispositivos da tabela [Suporte Tier 1](https://ziglang.org/#Tier-1-Support) e alguns da [Suporte Tier 2](https://ziglang.org/#Tier-2-Support). [Até mesmo freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

Além disso, a biblioteca padrão tem a capacidade de capturar um traço de pilha em qualquer ponto e depois despejá-la em erro padrão mais tarde:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

Você pode ver esta técnica sendo utilizada no projeto [GeneralPurposeDebugAllocator](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status).

## Estruturas e funções genéricas de dados

Os tipos são valores que devem ser conhecidos em tempo de compilação:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Uma estrutura de dados genérica é simplesmente uma função que retorna um `type`:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## Compilar o tempo de reflexão e compilar o tempo de execução do código

A função de compilação [@typeInfo](https://ziglang.org/documentation/master/#typeInfo) proporciona reflexão:

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

A Biblioteca Padrão Zig usa esta técnica para implementar a impressão formatada. Apesar de ser uma [Linguagem simples e pequena](https://ziglang.org/#Small-simple-language), A impressão formatada em Zig é implementada inteiramente em Zig. Enquanto isso, em C, os erros de compilação para impressão são codificados pelo compilador de forma arcaica. Da mesma forma, em Rust a macro de impressão formatada é codificada de forma arcaica e complexa pelo compilador.

Zig também pode avaliar funções e blocos de código em tempo de compilação. Em alguns contextos, tais como inicializações globais de variáveis, a expressão é implicitamente avaliada em tempo de compilação. Caso contrário, é possível avaliar explicitamente o código em tempo de compilação com a palavra-chave [comptime](https://ziglang.org/documentation/master/#comptime). Isto pode ser especialmente poderoso quando combinado com afirmações:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## Integration with C libraries without FFI/bindings

[@cImport](https://ziglang.org/documentation/master/#cImport) importa diretamente tipos, variáveis, funções e macros simples para uso em Zig. Ele até traduz funções em linha de C para Zig.

Aqui está um exemplo de emissão de uma onda sinusoidal usando [libsoundio](http://libsound.io/):

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[Este código Zig é significativamente mais simples do que o equivalente ao código C](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), bem como ter mais proteções de segurança, e tudo isso é conseguido através da importação direta do arquivo de cabeçalho C - sem ligações de API.

*Zig é melhor no uso de bibliotecas C do que C é no uso de bibliotecas C.*

### O Zig também é um compilador C

Aqui está um exemplo de Zig compilando código C:

<u>hello.c</u>
```c
#include <stdio.h>

int main(int argc, char **argv) {
    printf("Hello world\n");
    return 0;
}
```

```
$ zig build-exe --c-source hello.c --library c
$ ./hello
Hello world
```

Você pode utilizar `--verbose-cc` para ver quais os comandos que o compilador C executará:
```
$ zig build-exe --c-source hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

Note que se eu executar o comando novamente, não há saída, e ele termina instantaneamente:
```
$ time zig build-exe --c-source hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```

Isto se deve a [Cache de Compilação](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching). Zig analisa automaticamente o arquivo .d usando um sistema de cache robusto para evitar duplicação de trabalho.

O Zig não só pode compilar o código C, mas há uma razão muito boa para usar Zig como um compilador C: [Zig vincula-se com a libc](https://ziglang.org/#Zig-ships-with-libc).

### Exportar funções, variáveis e tipos definidos pelo código C para depender de

Um dos casos de uso primário para Zig é a exportação de uma biblioteca com a ABI C para outras linguagens de programação a serem utilizadas. A palavra-chave `export` em frente às funções, variáveis e tipos faz com que elas façam parte da API da biblioteca:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

Fazer uma biblioteca estática:
```
$ zig build-lib mathtest.zig
```

Fazer uma biblioteca dinâmica:
```
$ zig build-lib mathtest.zig -dynamic
```

Eis um exemplo com o [Sistema de Compilação do Zig](https://ziglang.org/#Zig-Build-System):

<u>test.c</u>
```c
#include "mathtest.h"
#include <stdio.h>

int main(int argc, char **argv) {
    int32_t result = add(42, 1337);
    printf("%d\n", result);
    return 0;
}
```

<u>build.zig</u>
{{< zigdoctest "assets/zig-code/features/24-build.zig" >}}

```
$ zig build test
1379
```

## A compilação cruzada é um caso de uso de primeira classe

Zig pode compilar para qualquer um dos dispositivos listados na [Tabela de Suporte](https://ziglang.org/#Support-Table) com [Suporte Tier 3](https://ziglang.org/#Tier-3-Support) ou melhor. Nenhum "conjunto de ferramentas cruzada" precisa ser instalada ou algo parecido. Aqui está um "Hello World" nativo:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Você pode compilar para: x86_64-windows, x86_64-macosx, e aarch64v8-linux:
```
$ zig build-exe hello.zig -target x86_64-windows
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
$ zig build-exe hello.zig -target x86_64-macosx
$ file hello
hello: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
$ zig build-exe hello.zig -target aarch64v8-linux
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, with debug_info, not stripped
```

Isto funciona em qualquer [Tier 3](https://ziglang.org/#Tier-3-Support)+ dispositivos, para qualquer [Tier 3](https://ziglang.org/#Tier-3-Support)+ plataformas.

### Zig vinculado com libc

Você pode encontrar as plataformas disponíveis que suportam libc, através do comando `zig targets`:
```
...
 "libc": [
  "aarch64_be-linux-gnu",
  "aarch64_be-linux-musl",
  "aarch64_be-windows-gnu",
  "aarch64-linux-gnu",
  "aarch64-linux-musl",
  "aarch64-windows-gnu",
  "armeb-linux-gnueabi",
  "armeb-linux-gnueabihf",
  "armeb-linux-musleabi",
  "armeb-linux-musleabihf",
  "armeb-windows-gnu",
  "arm-linux-gnueabi",
  "arm-linux-gnueabihf",
  "arm-linux-musleabi",
  "arm-linux-musleabihf",
  "arm-windows-gnu",
  "i386-linux-gnu",
  "i386-linux-musl",
  "i386-windows-gnu",
  "mips64el-linux-gnuabi64",
  "mips64el-linux-gnuabin32",
  "mips64el-linux-musl",
  "mips64-linux-gnuabi64",
  "mips64-linux-gnuabin32",
  "mips64-linux-musl",
  "mipsel-linux-gnu",
  "mipsel-linux-musl",
  "mips-linux-gnu",
  "mips-linux-musl",
  "powerpc64le-linux-gnu",
  "powerpc64le-linux-musl",
  "powerpc64-linux-gnu",
  "powerpc64-linux-musl",
  "powerpc-linux-gnu",
  "powerpc-linux-musl",
  "riscv64-linux-gnu",
  "riscv64-linux-musl",
  "s390x-linux-gnu",
  "s390x-linux-musl",
  "sparc-linux-gnu",
  "sparcv9-linux-gnu",
  "wasm32-freestanding-musl",
  "x86_64-linux-gnu",
  "x86_64-linux-gnux32",
  "x86_64-linux-musl",
  "x86_64-windows-gnu"
 ],
 ```

O que isto significa é que `--library c` para estas plataformas *não depende de nenhum arquivo do sistema*!

Vejamos o [exemplo do hello world em C](https://ziglang.org/#Zig-is-also-a-C-compiler) novamente:
```
$ zig build-exe --c-source hello.c --library c
$ ./hello
Hello world
$ ldd ./hello
	linux-vdso.so.1 (0x00007ffd03dc9000)
	libc.so.6 => /lib/libc.so.6 (0x00007fc4b62be000)
	libm.so.6 => /lib/libm.so.6 (0x00007fc4b5f29000)
	libpthread.so.0 => /lib/libpthread.so.0 (0x00007fc4b5d0a000)
	libdl.so.2 => /lib/libdl.so.2 (0x00007fc4b5b06000)
	librt.so.1 => /lib/librt.so.1 (0x00007fc4b58fe000)
	/lib/ld-linux-x86-64.so.2 => /lib64/ld-linux-x86-64.so.2 (0x00007fc4b6672000)
```

[glibc](https://www.gnu.org/software/libc/) não suporta a compilação estática, mas [musl](https://www.musl-libc.org/) suporta:
```
$ zig build-exe --c-source hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```

Neste exemplo, Zig construiu musl libc a partir da fonte e depois ligou-se a ela. A compilação da musl libc para x86_64-linux continua disponível graças ao [sistema de caching](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching), portanto, a qualquer momento esta libc é necessária novamente, ela estará disponível instantaneamente.

Isto significa que esta funcionalidade está disponível em qualquer plataforma. Os usuários de Windows e macOS podem criar códigos Zig e C, e vincular-se a libc, para qualquer uma das plataformas listados acima. Da mesma forma, o código pode ser compilado de forma cruzada para outras arquiteturas:
```
$ zig build-exe --c-source hello.c --library c -target aarch64v8-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```

Em alguns aspectos, Zig é um compilador C melhor do que os próprios compiladores C!

Esta funcionalidade é mais do que o agrupamento de um conjunto de ferramentas de compilação cruzada junto ao Zig. Por exemplo, o tamanho total dos cabeçalhos da libc que o Zig envia é de 22 MiB sem compressão. Enquanto isso, os cabeçalhos para musl libc + linux em x86_64 são 8 MiB, e para glibc são 3,1 MiB (falta no glibc os cabeçalhos linux), ainda assim Zig atualmente envia com 40 libcs. Com um agrupamento ingênuo que seria de 444 MiB. No entanto, graças a isto, a [ferramenta process_headers](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig) que eu fiz, e algum [bom e velho trabalho manual](https://github.com/ziglang/zig/wiki/Updating-libc), Os tarballs binários Zig permanecem em torno de 30 MiB no total, apesar de apoiar a libc para todos essas plataformas, bem como a compiler-rt, libunwind e libcxx, e apesar de ser um compilador C compatível com o clang. Para comparação, a compilação do binário no próprio Windows usando clang 8.0.0 do llvm.org é de 132 MiB.

Note que apenas no [Suporte Tier 1](https://ziglang.org/#Tier-1-Support) os dispositivos foram exaustivamente testados. Está previsto [acrescentar mais libcs](https://github.com/ziglang/zig/issues/514) (inclusive para o Windows), e para [adicionar cobertura de testes para compilação em relação a todas as libcs](https://github.com/ziglang/zig/issues/2058).

Já está sendo [planejado para ter um Gerenciador de Pacotes do Zig](https://github.com/ziglang/zig/issues/943), mas isso ainda não está pronto. Uma das coisas que será possível é criar um pacote para as bibliotecas C. Isto fará com que o [Sistema de Compilação do Zig](https://ziglang.org/#Zig-Build-System) tornando mais atraente tanto para programadores Zig como para programadores C.

## Sistema de Compilação do Zig

O Zig vem com um sistema de compilação, por isso você não precisa fazer, fabricar ou qualquer coisa do gênero.
```
$ zig init-exe
Created build.zig
Created src/main.zig

Next, try `zig build --help` or `zig build run`
```

<u>src/main.zig</u>
{{< zigdoctest "assets/zig-code/features/25-all-bases.zig" >}}


<u>build.zig</u>
{{< zigdoctest "assets/zig-code/features/26-build.zig" >}}


Vamos dar uma olhada nesse menu `--help`.
```
$ zig build --help
Usage: zig build [steps] [options]

Steps:
  install (default)      Copy build artifacts to prefix path
  uninstall              Remove build artifacts from prefix path
  run                    Run the app

General Options:
  --help                 Print this help and exit
  --verbose              Print commands before executing them
  --prefix [path]        Override default install prefix
  --search-prefix [path] Add a path to look for binaries, libraries, headers

Project-Specific Options:
  -Dtarget=[string]      The CPU architecture, OS, and ABI to build for.
  -Drelease-safe=[bool]  optimizations on and safety on
  -Drelease-fast=[bool]  optimizations on and safety off
  -Drelease-small=[bool] size optimizations on and safety off

Advanced Options:
  --build-file [file]         Override path to build.zig
  --cache-dir [path]          Override path to zig cache directory
  --override-lib-dir [arg]    Override path to Zig lib directory
  --verbose-tokenize          Enable compiler debug output for tokenization
  --verbose-ast               Enable compiler debug output for parsing into an AST
  --verbose-link              Enable compiler debug output for linking
  --verbose-ir                Enable compiler debug output for Zig IR
  --verbose-llvm-ir           Enable compiler debug output for LLVM IR
  --verbose-cimport           Enable compiler debug output for C imports
  --verbose-cc                Enable compiler debug output for C compilation
  --verbose-llvm-cpu-features Enable compiler debug output for LLVM CPU features
```

Você pode ver que uma das etapas disponíveis é executada.
```
$ zig build run
All your base are belong to us.
```

Aqui estão alguns exemplos de scripts de compilação:

- [Compilação do jogo Tetris - OpenGL](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Compilação do jogo arcade no Raspberry Pi 3 (bare-metal)](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Compilação do compilador auto-hospedado Zig](https://github.com/ziglang/zig/blob/master/build.zig)

## Concorrência via funções Async

Zig v0.5.0 [introduziu funções assíncronas](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). Esta característica não depende de um sistema operacional host ou mesmo de uma memória alocada em pilha. Isso significa que funções assimétricas estão disponíveis para os dispositivos freestanding.

Zig infere se uma função é assimétrica, e permite `async`/`await` em funções não assíncronas, o que significa que **as bibliotecas Zig são agnósticos de bloqueio ao invés de E/S assíncrona**. [Zig evita as cores das funções (inglês)](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).



A Biblioteca Padrão Zig implementa um loop de eventos que multiplexam as funções assimétricas em um pool de threads para concorrência M:N. A segurança multithreading e a detecção de corrida são áreas de pesquisa ativa.

## Ampla gama de dispositivos suportados

Zig utiliza um sistema de "tiers" para comunicar o nível de suporte para diferentes dispositivos. Note que a barra para [Suporte Tier 1](https://ziglang.org/#Tier-1-Support) é maior - [Suporte Tier 2](https://ziglang.org/#Tier-2-Support) é ainda bastante útil.

### Tabela de Suporte

| | free standing | Linux 3.16+ | macOS 10.13+ | Windows 8.1+ | FreeBSD 12.0+ | NetBSD 8.0+ | DragonFly​BSD 5.8+ | UEFI |
|-|---------------|-------------|--------------|--------------|---------------|-------------|-------------------|------|
| x86_64 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) |
| arm64 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) |
| arm32 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) |
| mips32 LE | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| i386 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 2](https://ziglang.org/#Tier-2-Support) |
| riscv64 | [Tier 1](https://ziglang.org/#Tier-1-Support) | [Tier 2](https://ziglang.org/#Tier-2-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) |
| bpf | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| hexagon | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| mips32 BE | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| mips64 | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| amdgcn | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| sparc | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| s390x | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| lanai | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| powerpc32 | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| powerpc64 | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | [Tier 3](https://ziglang.org/#Tier-3-Support) | [Tier 3](https://ziglang.org/#Tier-3-Support) | N/A | N/A |
| avr | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| riscv32 | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) |
| xcore | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| nvptx | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| msp430 | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| r600 | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| arc | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| tce | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| le | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| amdil | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| hsail | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| spir | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| kalimba | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| shave | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |
| renderscript | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A | [Tier 4](https://ziglang.org/#Tier-4-Support) | [Tier 4](https://ziglang.org/#Tier-4-Support) | N/A | N/A |


### Tabela de suporte para WebAssembly

|        | free standing | emscripten | WASI   |
|--------|---------------|------------|--------|
| wasm32 | [Tier 1](https://ziglang.org/#Tier-1-Support)        | [Tier 3](https://ziglang.org/#Tier-3-Support)     | [Tier 1](https://ziglang.org/#Tier-1-Support) |
| wasm64 | [Tier 4](https://ziglang.org/#Tier-4-Support)        | [Tier 4](https://ziglang.org/#Tier-4-Support)     | [Tier 4](https://ziglang.org/#Tier-4-Support) |


### Tier System

#### Suporte Tier 1
- O Zig não só pode gerar código de máquina para estes dispositivos, mas a biblioteca padrão de abstrações entre plataformas tem implementações para estes dispositivos.
- O servidor CI testa automaticamente estes dispositivos de saida em cada compromisso com o *master branch*, e atualiza a página [Baixar](https://ziglang.org/download) com links para binários pré-construídos.
- Estes dispositivos têm capacidade de depuração e, portanto, produzem [rastreamento de pilha](https://ziglang.org/#Stack-traces-on-all-targets) sobre asserções fracassadas.
- [libc está disponível para este dispositivo, mesmo quando a compilação cruzada](https://ziglang.org/#Zig-ships-with-libc).
- Todos os testes de comportamento e testes de biblioteca padrão aplicáveis são aprovados para esta plataforma. Todas as características da linguagem são conhecidas por funcionarem corretamente.

#### Suporte Tier 2
- A biblioteca padrão suporta esta plataforma, mas é possível que algumas APIs dêem um erro de compilação "Unsupported OS". Pode-se fazer uma vinculação com a libc ou outras bibliotecas para preencher as lacunas da biblioteca padrão.
- Estes dispositivos são conhecidos por funcionarem, mas podem não ser testados automaticamente, portanto, há regressões ocasionais.
- Alguns testes podem ser desativados para estes dispositivos enquanto trabalhamos para [Suporte Tier 1](https://ziglang.org/#Tier-1-Support).

#### Suporte Tier 3

- A biblioteca padrão tem pouco ou nenhum conhecimento da existência desta palataforma.
- Como Zig é baseado em LLVM, ele tem a capacidade de construir para esses dispositivos, e LLVM tendo a plataforma habilitado por padrão.
- Estas plataformas não são testadas com freqüência; provavelmente será necessário contribuir para o Zig a fim de compilar para estes dispositivos.
- O compilador Zig pode precisar ser atualizado com algumas coisas, tais como
  - quais são os tamanhos dos tipos C inteiros
  - C ABI convoca convenção para esta plataforma
  - código bootstrap e manipulador de pânico padrão
- zig garante incluir estas plataformas listadas.

#### Suporte Tier 4

- O apoio a esses objetivos é inteiramente experimental.
- LLVM pode ter a paltaforma como experimental, o que significa que você precisa usar binários fornecidos em Zig para que a paltaforma esteja disponível, ou construir LLVM a partir da fonte com bandeiras de configuração especiais.
- Esta plataforma pode ser considerada depreciada por uma parte oficial, como por exemplo [macosx/i386](https://support.apple.com/en-us/HT208436), neste caso, esta meta permanecerá para sempre presa no Nível 4.
- Esta plataforma só pode suportar `--emit` asm e não pode emitir arquivos objeto.

## Colaboradores de pacotes 

O compilador Zig ainda não é completamente auto-hospedado, mas não importa o, [permanecerá exatamente 3 etapas](https://github.com/ziglang/zig/issues/853) para deixar de usar um compilador C++ no sistema para ter um compilador Zig totalmente auto-hospedado para qualquer plataforma. Como observa Maya Rashish, [portando o Zig para outras plataformas é divertido e rápido](http://coypu.sdf.org/porting-zig.html).

Os [modos de compilação](https://ziglang.org/documentation/master/#Build-Mode) sem depuração (non-debug) são reprodutíveis/determináveis.

Há um [Versão JSON da página de download](https://ziglang.org/download/index.json).

Vários membros da equipe Zig têm experiência na manutenção de pacotes.

- [Daurnimator](https://github.com/daurnimator) mantém o [Arch Linux package](https://www.archlinux.org/packages/community/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) mantém o pacote Visual Studio Code.
- [Andrew Kelley](https://andrewkelley.me/) passou cerca de um ano ou mais fazendo [pacotes do Debian e Ubuntu](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes), e contribui casualmente para [nixpkgs](https://github.com/NixOS/nixpkgs/).
- [Jeff Fowler](https://blog.jfo.click/) mantém o pacote Homebrew e iniciou o [Sublime package](https://github.com/ziglang/sublime-zig-language) (agora mantido por [emekoi](https://github.com/emekoi)).
