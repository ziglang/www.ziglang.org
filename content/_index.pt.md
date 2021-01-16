---
title: Página Inicial
mobile_menu_title: "Inicial"
---
{{< slogan get_started="COMECE AGORA" docs="Documentação" notes="Mudanças" lang="pt">}}
Zig é uma linguagem de programação de propósito geral e um conjunto de ferramentas para manter o seu software **robusto**, **otimizado**, e **reutilizável**.  
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Uma linguagem simples
Concentre-se na depuração de sua aplicação em vez de depurar seus conhecimentos em uma linguagem de programação.

- Sem fluxos de controle ocultas.
- Sem alocações de memórias ocultas.
- Sem preprocessador, nem macros. 

# ⚡ Tempo de Compilação (Comptime)
Uma nova abordagem de metaprogramação baseada na execução do código em tempo de compilação e avaliação preguiçosa.

- Chame qualquer função em tempo de compilação.
- Manipular tipos como valores sem sobrecarga de tempo de execução.
- O Comptime emula a arquitetura de saida.

# ⚡ Desempenho que se enquadra na segurança
Escreva um código rápido e claro, capaz de lidar com todas as condições de erro.

- A linguagem guia graciosamente sua lógica de tratamento de erros.
- As verificações configuráveis de tempo de execução ajudam a encontrar um equilíbrio entre desempenho e garantias de segurança.
- Aproveite os tipos vetoriais para expressar as instruções SIMD de forma portátil.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="{{< ref path="learn/overview.md">}}" class="button" style="display: inline;">Visão Geral</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="{{< ref path="learn/samples.md">}}" class="button" style="display: inline;">Mais exemplos de código</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Comunidade" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="https://raw.githubusercontent.com/ziglang/logo/master/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# A comunidade Zig é descentralizada 
Qualquer pessoa é livre para começar e manter seu próprio espaço para que a comunidade se reúna.  
Não existe o conceito de "oficial" ou "não-oficial", entretanto, cada local de reunião tem seus próprios moderadores e regras.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Veja todas as comunidades</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Principal desenvolvimento
O repositório Zig pode ser encontrado em [https://github.com/ziglang/zig](https://github.com/ziglang/zig), onde também discutimos sobre os problemas e propostas.  
Espera-se que os contribuidores sigam o Zig [Código de Conduta](https://github.com/ziglang/zig/blob/master/CODE_OF_CONDUCT.md).
{{% /div %}}
{{% div style="width:40%" %}}
<img src="https://raw.githubusercontent.com/ziglang/logo/master/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## A ZSF é uma corporação 501(c)(3) sem fins lucrativos.

A Zig Software Foundation é uma corporação sem fins lucrativos fundada em 2020 por Andrew Kelley, o criador do Zig, com o objetivo de apoiar o desenvolvimento da linguagem. Atualmente, a ZSF é capaz de oferecer trabalho remunerado a taxas competitivas para um pequeno número de colaboradores principais. Esperamos ser capazes de estender esta oferta a mais colaboradores centrais no futuro.

A Zig Software Foundation é sustentada por doações.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Mais informações</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}
# Patrocinadores corporativos 
As seguintes empresas estão fornecendo suporte financeiro direto para a Zig Software Foundation.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# Patrocinadores GitHub
Graças a pessoas que [Patrocine Zig](zsf/), o projeto é responsável perante a comunidade de código aberto e não perante os acionistas corporativos. Em particular, essas pessoas de boa reputação patrocinam o Zig por US$ 200/mês ou mais:

- [Karrick McDermott](https://github.com/karrick)
- [Raph Levien](https://raphlinus.github.io/)
- [ryanworl](https://github.com/ryanworl)
- [Stevie Hryciw](https://www.hryx.net/)
- [Josh Wolfe](https://github.com/thejoshwolfe)
- [SkunkWerks, GmbH](https://skunkwerks.at/)
- [drfuchs](https://github.com/drfuchs)
- Eleanor Bartle

Esta seção é atualizada no início de cada mês.
{{% /div %}}
{{< /div >}}





















