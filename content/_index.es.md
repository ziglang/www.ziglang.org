---
title: Inicio
mobile_menu_title: "Inicio"
---
{{< slogan get_started="PRIMEROS PASOS" docs="Documentación" notes="Cambios" lang="es" >}}
Zig es un lenguaje de programación de propósito general y una cadena de herramientas para mantener software **robusto**, **óptimo** y **reusable**.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Un Lenguaje Simple
Enfócate en depurar tu aplicación en vez de depurar tu conocimiento del lenguaje

- Sin control de flujo oculto.
- Sin asignaciones de memoria ocultas
- Sin preprocesador, sin macros.

# ⚡ Comptime
Un enfoque fresco hacia la meta-programación basada en ejecución de código en tiempo de compilación y evaluación tardía (lazy evaluation). 

- Llama cualquier función en tiempo de compilación.
- Manipula tipos como si fuesen valores sin penalizar el tiempo de ejecución.
- Comptime emula la arquitectura objetivo.

# ⚡ Desempeño y Seguridad
Escribe código claro y rápido capaz de manejar todas las condiciones de error.

- Zig guía en forma eficaz tu lógica de tratamiento de errores.
- Los chequeos configurables de tiempo de ejecución te ayudan a alcanzar un balance entre desempeño y garantías de seguridad.
- Aprovecha las ventajas de los tipos vector para expresar instrucciones SIMD en forma portable.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">Revisión a fondo</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">Más ejemplos de código</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Comunidad" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# La comunidad Zig es descentralizada
Todos son libres para mantener su propio lugar de reunión para la comunidad.
No existe el concepto de "oficial" o "no oficial", no obstante, cada lugar de reunión tiene sus propias reglas y moderadores.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Ver todas las comunidades</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Desarrollo principal
El repositorio de Zig se encuentra en [https://github.com/ziglang/zig](https://github.com/ziglang/zig), donde también damos seguimiento a errores y discusiones de propuestas.
Los contribuyentes deberán seguir el [Código de conducta de Zig](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md).
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## La ZSF es una corporación sin fines de lucro 501(c)(3).

La Zig Software Foundation es una corporación sin fines de lucro fundada en 2020 por Andrew Kelly, el creador de Zig, con el fin de sostener el desarrollo del lenguaje. Actualmente, la ZSF es capaz de ofrecer empleo con remuneración competitiva a un pequeño número de contribuyentes. Esperamos ser capaces de extender esta oferta a más contribuyentes en el futuro. 

La Zig Software Foundation se mantiene con donaciones.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Saber Más</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Patrocinadores" %}}
# Patrocinadores Corporativos
Las siguientes compañías proveen apoyo económico directo a la Zig Software Foundation.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# Patrocinadores en GitHub
Gracias a la [gente que patrocina Zig](zsf/), el proyecto se debe a la comunidad open source y no a entes corporativos. En particular, estos queridos amigos patrocinan a Zig por un monto de $200 USD mensuales o más:

{{< ghsponsors >}}

Esta sección se actualiza al inicio de cada mes.
{{% /div %}}
{{< /div >}}
