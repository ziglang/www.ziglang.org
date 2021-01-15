---
title: "Por que Zig quando já existe C++, D, e Rust?"
mobile_menu_title: "Por que Zig quando..."
toc: true
---


## Sem fluxo de controle oculto

Se o código Zig não parece estar pulando para chamar uma função, então não está. Isto significa que você pode ter certeza de que o seguinte código chama apenas `foo()` e depois `bar()`, e isto é garantido sem a necessidade de saber os tipos de nada:

```zig
var a = b + c.d;
foo();
bar();
```

Exemplos de fluxo de controle oculto:

- D tem funções `@property`, que são métodos que você chama com o que parece ser acesso de campo, então no exemplo acima, `c.d` poderia chamar uma função.
- C++, D, e Rust têm sobrecarga do operador, portanto o operador `+` pode chamar uma função.
- C++, D, e Go têm exceções de `throw/catch`, portanto `foo()` pode lançar uma exceção, e impedir que `bar()` seja chamado. (Claro que, mesmo em Zig `foo()` poderia bloquear e impedir que `bar()` fosse chamado, mas isso pode acontecer em qualquer linguagem que seja Turing-Completude).

O objetivo desta decisão de projeto é melhorar a legibilidade.

## Sem alocações ocultas

De modo mais geral, ter uma abordagem de mãos livres quando se trata de alocação de pilhas. Não há nenhuma "nova" palavra-chave ou qualquer outro recurso de linguagem que utilize um alocador de pilha (por exemplo, operador de concatenação de strings[1]). Todo o conceito da pilha está estritamente no espaço do usuário. Há algumas características padrão de biblioteca que fornecem e funcionam com alocadores de pilha, mas essas são características opcionais de biblioteca padrão, não incorporadas no próprio idioma. Se você nunca inicializa um alocador de pilhas, então você pode ter certeza de que seu programa nunca vai causar alocações de pilhas.

A biblioteca padrão do Zig ainda é muito jovem, mas o objetivo é que cada recurso que usa um alocador aceite um alocador em tempo de execução, ou possivelmente em tempo de compilação ou de execução.

A motivação para esta filosofia de projeto é permitir aos usuários escrever qualquer tipo de estratégia de alocação personalizada que considerem necessária, em vez de forçá-los ou mesmo encorajá-los a uma estratégia particular que pode não ser adequada às suas necessidades. Por exemplo, Rust parece encorajar uma única estratégia de alocação global, que não é adequada para muitos casos de uso, tais como desenvolvimento de SO e desenvolvimento de jogos de alto desempenho. Zig está recebendo sugestões da postura de [Jai](https://www.youtube.com/watch?v=ciGQCP6HgqI) sobre alocadores, uma vez que essa linguagem está sendo desenvolvida por um designer de jogos de alto desempenho para o uso de jogos de alto desempenho. 

Como afirmado antes, este tópico ainda é um pouco confuso e se tornará mais concreto conforme a biblioteca padrão do Zig amadurece. O importante é que a alocação de heap seja um conceito de espaço do usuário, e não embutido na linguagem.

Nem é preciso dizer que não existe um coletor de lixo embutido como há na linguagem Go.

[O erro [panic] emitido pela biblioteca padrão do Rust quando estiver sem Memória (Out Of Memory)](https://github.com/rust-lang/rust/issues/29802)

[1]: Na verdade, existe um operador de concatenação de cordas (geralmente um operador de concatenação de matriz), mas ele só funciona em tempo de compilação, de modo que ainda não há alocação de pilha de tempo de execução com isso.

## Autonomia

Zig tem uma biblioteca padrão inteiramente opcional que só é compilada em seu programa se você a utilizar. O mesmo ocorre com a libc, a utilização dela é opcional, exceto em casos de interoperabilidade com linguagem C. O Zig é amigável ao desenvolvimento de sistemas de alto desempenho e bare-metal. 


## Uma linguagem portátil para bibliotecas

Um dos santo graal da programação é a reutilização de código. Infelizmente, na prática, acabamos reinventando a roda várias vezes. Muitas vezes é justificado.

 * Se um aplicativo tem requisitos de tempo real, qualquer biblioteca que usa coleta de lixo ou qualquer outro comportamento não determinístico é desqualificada como dependência.
 * Se uma linguagem torna muito fácil ignorar erros e, portanto, verificar se uma biblioteca trata corretamente e gera bolhas de erros, pode ser tentador ignorar a biblioteca e implementá-la novamente, sabendo que todos os erros relevantes foram tratados corretamente. O Zig é projetado de forma que a coisa mais preguiçosa que um programador pode fazer é lidar com os erros corretamente e, portanto, pode-se estar razoavelmente confiante de que uma biblioteca irá propagar erros.
 * Atualmente, é pragmaticamente verdade que C é a linguagem mais versátil e portátil. Qualquer linguagem que não tenha a capacidade de interagir com o código C corre o risco de ser obscurecida. O Zig está tentando se tornar a nova linguagem portátil para bibliotecas, tornando-o simultaneamente direto para a conformidade com a C ABI para funções externas e introduzindo segurança e design de linguagem que evita bugs comuns nas implementações.

## Um Gerenciador de Pacotes e um Sistema de Compilação para projetos existentes

Zig é uma linguagem de programação, mas também é enviada com um sistema de compilação e um gerenciador de pacotes que se destinam a ser úteis mesmo no contexto de um projeto C/C++ tradicional.

Você não só pode escrever o código Zig em vez do código C ou C++, mas também pode usar Zig como um substituto para ferramentas automáticas, fazer, fazer, scons, ninja, etc. E além disso, ele (irá) fornecer um gerenciador de pacotes para dependências nativas. Este sistema de compilação é destinado a ser apropriado mesmo que a base de código de um projeto esteja totalmente em C ou C++.

Gerentes de pacotes de sistema como apt-get, pacman, homebrew, e outros são fundamentais para a experiência do usuário final, mas eles podem ser insuficientes para as necessidades dos desenvolvedores. Um gerenciador de pacotes de idioma específico pode ser a diferença entre não ter contribuidores e ter dezenas. Para projetos de código aberto, a dificuldade de conseguir que o projeto seja construído é um enorme obstáculo para os potenciais contribuintes. Para projetos C/C++, ter dependências pode ser fatal, especialmente no Windows, onde não há um gerenciador de pacotes. Mesmo quando se trata apenas de construir o Zig, a maioria dos colaboradores em potencial tem dificuldades com a dependência da LLVM. O Zig está (estará) oferecendo uma forma de os projetos dependerem diretamente de bibliotecas nativas - sem depender do gerenciador de pacotes do sistema dos usuários para ter a versão correta disponível, e de uma forma que é praticamente garantida para construir projetos com sucesso na primeira tentativa, independentemente do sistema que está sendo usado e independente da plataforma que está sendo visada.

Zig está oferecendo a substituição do sistema de compilação de um projeto por uma linguagem razoável usando uma API declarativa para a compilação de projetos, que também fornece o gerenciamento de pacotes e, portanto, a capacidade de realmente depender de outras bibliotecas C. A capacidade de ter dependências permite abstrações de maior nível e, portanto, a proliferação de códigos reutilizáveis de alto nível.

## Simplicidade

C++, Rust, e D têm um grande número de características e podem distrair do significado real da aplicação em que você está trabalhando. A pessoa se vê depurando seu conhecimento da linguagem de programação ao invés de depurar a aplicação em si.

Zig não tem macros nem metaprogramação, mas ainda é poderoso o suficiente para expressar programas complexos de uma forma clara e não repetitiva. Mesmo Rust, que tem macros com casos especiais `format!`, implementando-o no próprio compilador. Enquanto isso, em Zig, a função equivalente é implementada na biblioteca padrão, sem código de caso especial no compilador.

Quando você observa o código Zig, tudo é uma simples expressão ou uma chamada de função. Não há sobrecarga de operador, métodos de propriedade, despacho de tempo de execução, macros ou fluxo de controle oculto. Zig está indo para toda a bela simplicidade do C, menos as armadilhas.

 * [Struggles With Rust](https://compileandrun.com/stuggles-with-rust.html)
 * [Way Cooler gives up on Rust due to complexity](http://way-cooler.org/blog/2019/04/29/rewriting-way-cooler-in-c.html)
 * [Moving to Zig for ARM Development](https://www.jishuwen.com/d/2Ap9)

## Ferramentas

Zig pode ser baixado na seção [Baixar](/downloads/). Zig fornece arquivos binários para linux, windows, macos e freebsd. O seguinte descreve o que você obtém com este arquivo:

* instalado após baixar e extrair de um único arquivo, sem necessidade de configuração do sistema
* compilado estaticamente para que não haja dependências de tempo de execução
* utiliza a infra-estrutura madura e bem suportada da LLVM que permite uma profunda otimização e suporte para a maioria das principais plataformas
* out of the box cross-compilation to most major platforms
* vincula código fonte com libc que será compilado dinamicamente quando necessário para qualquer plataforma suportada
* inclui sistema de compilação com caching
* compila o código C com o suporte da libc
