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

* D tem funções `@property`, que são métodos que você chama com o que parece ser acesso de campo, então no exemplo acima, `c.d` poderia chamar uma função.
* C++, D, e Rust têm sobrecarga do operador, portanto o operador `+` pode chamar uma função.
* C++, D, e Go têm exceções de `throw/catch`, portanto `foo()` pode lançar uma exceção, e impedir que `bar()` seja chamado. (Claro que, mesmo em Zig `foo()` poderia bloquear e impedir que `bar()` fosse chamado, mas isso pode acontecer em qualquer linguagem que seja Turing-Completude).

O objetivo desta decisão de projeto é melhorar a legibilidade.

## Sem alocações ocultas

Zig tem uma abordagem de trabalho manual quando se trata de alocação de memória. Não há uma palavra-chave `new`
ou qualquer outro recurso semelhante na linguagem que utilize um alocador de memória (por exemplo, operador de concatenação de strings[1]).
Todo o conceito da heap é gerenciado pela biblioteca e o código da aplicação, não pela linguagem.

Exemplo de alocações ocultas:

* Go utiliza `defer` para alocar memória a uma pilha de funções-local. Além de ser uma forma não intuitiva
  para este fluxo de controle funcionar, ele pode causar falhas como falta de memória se você usar `defer`
  dentro de um laço.
* Corrotinas em C++ aloca memória heap a fim de chamar uma corrotina.
* Em Go, uma chamada de função pode causar alocação de memória porque as goroutines alocam pequenas pilhas
  que são redimensionadas quando a pilha de chamadas fica muito cheia.
* As principais APIs da biblioteca padrão Rust entram em pânico em condições de falta de memória, e as APIs
  alternativas que aceitam parâmetros de alocação serão um problema a ser considerado mais tarde.
  (veja [rust-lang/rust#29802](https://github.com/rust-lang/rust/issues/29802)).

Quase todas as línguagens que possuem coletor de lixo têm alocações ocultas,
já que o coletor de lixo esconde as evidências no lado da liberação de memória.

O principal problema com alocações ocultas é que elas impedem a *reusabilidade* de um pedaço do código,
limitando desnecessariamente o número de ambientes aos quais o código seria apropriado para ser implantado.
Simplificando, existem casos de uso em que se deve ser capaz de confiar no fluxo de controle e chamadas de
função para não ter o efeito colateral da alocação de memória, portanto, uma linguagem de programação só pode
servir a estes casos de uso se ela puder fornecer esta garantia de forma realista.

Em Zig, há recursos da biblioteca padrão que fornecem e trabalham com alocadores de memória, mas esses são recursos
opcionais da biblioteca padrão, já que não são incorporados a linguagem.
Se você nunca inicializar um alocador de memória, você pode ter certeza de que seu programa não irá alocar memória.

Cada recurso da biblioteca padrão que precisa alocar memória aceita um parâmetro `Allocator` para fazer isso.
Isto significa que a biblioteca padrão do Zig suporta dispositivos freestanding. Por exemplo `std.ArrayList` e
`std.AutoHashMap` podem ser utilizadas para programação em bare metal!

Alocadores personalizados fazem gerenciamento manual de memória com facilidade. Zig tem um alocador de depuração
que mantém a segurança da memória em casos de ponteiro selvagem e liberação dupla. Ela automaticamente detecta e imprime vestígios
de vazamentos de memória na pilha. Há um alocador de arena para que você possa agrupar qualquer número de alocações em uma
e liberá-las todas de uma só vez, em vez de gerenciar cada alocação independentemente. Alocadores para fins especiais podem
ser usados para melhorar o desempenho ou uso de memória para qualquer necessidade específica de aplicação.

[1]: Na verdade, existe um operador de concatenação de strings (geralmente um operador de concatenação de matriz),
  mas ele só funciona em tempo de compilação, de modo que ainda não há alocação de pilha de tempo de execução com isso.

## Autonomia

Como sugerido acima, o Zig tem uma biblioteca padrão inteiramente opcional. Cada API biblioteca padrão só é compilada em seu programa
se você a utilizar. Zig faz o mesmo com a biblioteca C, ou seja, a vinculação dela também é opcional. O Zig é flexível ao
desenvolvimento de bare metal e computadores de alto desempenho.

É o melhor dos dois mundos; por exemplo, em Zig, os programas em WebAssembly podem tanto usar as características normais da biblioteca padrão,
como ainda resultar nos mais pequenos binários quando comparados com outras linguagens de programação que suportam a compilação para WebAssembly.

## Uma linguagem portátil para bibliotecas

Um dos santo graal da programação é a reutilização de código. Infelizmente, na prática, acabamos reinventando a roda várias vezes. Muitas vezes é justificado.

 * Se um aplicativo tem requisitos de tempo real, qualquer biblioteca que usa coleta de lixo ou qualquer outro comportamento não determinístico é desqualificada como dependência.
 * Se uma linguagem torna muito fácil ignorar erros e, portanto, verificar se uma biblioteca trata corretamente e gera bolhas de erros, pode ser tentador ignorar     a biblioteca e implementá-la novamente, sabendo que todos os erros relevantes foram tratados corretamente. O Zig é projetado de forma que a coisa mais preguiçosa que um programador pode fazer é lidar com os erros corretamente e, portanto, pode-se estar razoavelmente confiante de que uma biblioteca irá propagar erros.
 * Atualmente, é pragmaticamente verdade que C é a linguagem mais versátil e portátil. Qualquer linguagem que não tenha a capacidade de interagir com o código C corre o risco de ser obscurecida. O Zig está tentando se tornar a nova linguagem portátil para bibliotecas, tornando-o simultaneamente direto para a conformidade com a C ABI para funções externas e introduzindo segurança e design de linguagem que evita bugs comuns nas implementações.

## Um Gerenciador de Pacotes e um Sistema de Compilação para projetos existentes

Zig é uma linguagem de programação, mas também é enviada com um sistema de compilação e um gerenciador de pacotes que se destinam a ser úteis mesmo no contexto de um projeto C/C++ tradicional.

Você não só pode escrever o código Zig em vez do código C ou C++, mas também pode usar Zig como um substituto para ferramentas automáticas, fazer, fazer, scons, ninja, etc. E além disso, ele (irá) fornecer um gerenciador de pacotes para dependências nativas. Este sistema de compilação é destinado a ser apropriado mesmo que a base de código de um projeto esteja totalmente em C ou C++.

Gerentes de pacotes de sistema como apt-get, pacman, homebrew, e outros são fundamentais para a experiência do usuário final, mas eles podem ser insuficientes para as necessidades dos desenvolvedores. Um gerenciador de pacotes de idioma específico pode ser a diferença entre não ter contribuidores e ter dezenas. Para projetos de código aberto, a dificuldade de conseguir que o projeto seja construído é um enorme obstáculo para os potenciais contribuintes. Para projetos C/C++, ter dependências pode ser fatal, especialmente no Windows, onde não há um gerenciador de pacotes. Mesmo quando se trata apenas de construir o Zig, a maioria dos colaboradores em potencial tem dificuldades com a dependência da LLVM. O Zig está (estará) oferecendo uma forma de os projetos dependerem diretamente de bibliotecas nativas - sem depender do gerenciador de pacotes do sistema dos usuários para ter a versão correta disponível, e de uma forma que é praticamente garantida para construir projetos com sucesso na primeira tentativa, independentemente do sistema que está sendo usado e independente da plataforma que está sendo visada.

Zig está oferecendo a substituição do sistema de compilação de um projeto por uma linguagem razoável usando uma API declarativa para a compilação de projetos, que também fornece o gerenciamento de pacotes e, portanto, a capacidade de realmente depender de outras bibliotecas C. A capacidade de ter dependências permite abstrações de maior nível e, portanto, a proliferação de códigos reutilizáveis de alto nível.

## Simplicidade

C++, Rust, e D têm um grande número de características e podem distrair do significado real da aplicação em que você está trabalhando. A pessoa se vê depurando seu conhecimento da linguagem de programação ao invés de depurar a aplicação em si.

Zig não tem macros nem metaprogramação, mas ainda é poderoso o suficiente para expressar programas complexos de uma forma clara e não repetitiva. Mesmo Rust, que tem macros com casos especiais `format!`, implementando-o no próprio compilador. Enquanto isso, em Zig, a função equivalente é implementada na biblioteca padrão, sem código de caso especial no compilador.

## Ferramentas

Zig pode ser baixado na seção [Baixar](/downloads/). Zig fornece arquivos binários para Linux, Windows, MacOS e FreeBSD. Siga as descrições do que você obtém com este arquivo:

* instalado após baixar e extrair de um único arquivo, sem necessidade de configuração do sistema
* compilado estaticamente para que não haja dependências de tempo de execução
* utiliza a infra-estrutura madura e bem suportada da LLVM que permite uma profunda otimização e suporte para a maioria das principais plataformas
* compilação cruzada de qualquer plataforma para outras plataformas suportadas
* vincula o código fonte com a bibliocate C que será compilado dinamicamente quando necessário para qualquer plataforma suportada
* inclui sistema de compilação com caching
* compila código C e C++ com o suporte da biblioteca C
