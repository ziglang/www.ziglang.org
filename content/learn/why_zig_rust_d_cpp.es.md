---
title: "¿Por que Zig cuando ya existen C++, D y Rust?"
mobile_menu_title: "¿Por que Zig?"
toc: true
---


## Sin control de flujo oculto

Si un fragmento de código Zig no parece estar saltando a hacer una llamada a una función, es por que no lo está haciendo. Esto significa que podemos estar seguros de que el siguiente código llama solo a `foo()` y después a `bar()` y esto esta garantizado sin tener que conocer tipo de dato alguno:

```zig
var a = b + c.d;
foo();
bar();
```
Ejemplos de control de flujo oculto:

- D tiene funciones `@property`, las cuales son métodos que puedes llamar con algo que se percibe como acceso a propiedades (con notación de punto), de tal forma que el ejemplo de código anterior en el lenguaje D, `c.d`, podría estar llamando a una función.
- C++, D y Rust tienen sobrecarga de operadores, de tal forma que el operador `+` podría llamar a una función.
- C++, D y Go tienen manejo de excepciones con throw/catch, de tal manera que `foo()` podría arrojar una excepción y prevenir que `bar()` sea llamada.

Zig promueve la facilidad de mantenimiento y legibilidad haciendo que todo control de flujo sea manejado exclusivamente con palabras reservadas del lenguaje y con llamadas a funciones.

## Sin asignaciones de memoria ocultas

Zig tiene un enfoque de no intervención cuando se trata de asignaciones de memoria. No existe palabra reservada `new` u otra característica que haga uso de asignaciones de memoria (como operadores de concatenación de strings[1]). Todo el concepto de 'heap' esta manejado por bibliotecas o el código de cada aplicación y no por el lenguaje.

Ejemplos de asignaciones ocultas:

* En Go, la palabra reservada `defer` asigna memoria en un stack (pila) local de funciones. Además de ser algo poco intuitivo, puede ocasionar fallas de falta de memoria si esto se utiliza dentro de bucles.
* C++ asigna memoria en el 'heap' para poder llamar una corrutina.
* En Go, una llamada a función puede provocar asignación de memoria en el 'heap' ya que las gorutines asignan pequeñas pilas que cambian de tamaño cuando la cantidad de llamadas aumenta considerablemente.
* Las APIs de la biblioteca estándar de Rust, arrojan panic en condiciones de falta de memoria y las APIs alternativas que admiten parámetros de 'allocator' son una idea secundaria (véase [rust-lang/rust#29802](https://github.com/rust-lang/rust/issues/29802)).

Casi todos los lenguajes con 'garbage collection' incurren en asignaciones de memoria ocultas.

El principal problema con con las asignaciones de memoria ocultas es que previene la *reusabilidad* del código limitando el número de ambientes en los que dicho código podría funcionar. Dicho de una forma simple, existen casos de uso en los cuales es necesario no tener el efecto colateral de las asignaciones de memoria ocultas, por esto, un lenguaje solo puede servir a estos casos de uso si aporta tal garantía.

En Zig, existen características de la biblioteca estándar que proveen y admiten 'heap allocators' (asignadores de memoria en el heap), pero estas son características opcionales de la biblioteca estándar y no construcciones internas del propio lenguaje. Si nunca inicializas un heap allocator, puedes tener la certeza de que tu programa no hará asignaciones de memoria en el heap.

Cada funcionalidad de la biblioteca estándar que requiere asignación de memoria acepta un parámetro `Allocator` para poder operar. Esto quiere decir que la biblioteca estándar de Zig soporta arquitecturas no especificas. Por ejemplo, `std.ArrayList` y `std.AutoHashMap` pueden ser usadas para programación de bajo nivel en procesadores/microcontroladores.

Los allocators (asignadores de memoria) personalizados hacen que el manejo manual de memoria sea muy sencillo. Zig ofrece un allocator que mantiene la seguridad de memoria para bugs de tipo doble liberación de objetos y uso después de liberación de objetos. Detecta automáticamente fugas de memoria e imprime un stack trace (traza de pila). Otro allocator disponible es un arena allocator que permite asignar un numero de espacios de memoria y da la facilidad de liberarlos todos al mismo tiempo en vez de tener que manejar las liberaciones de cada asignación individualmente. También hay disponibles allocators de propósito especial que pueden ser usados para mejoras de desempeño en casos particulares.

[1]: De hecho existe un operador de concatenación de strings (es generalmente un operador de concatenación de arrays), pero solo funciona en tiempo de compilación y por ello, no incurre en asignaciones de memoria en heap en tiempo de ejecución.

## Soporte de primera clase para biblioteca no estándar

Como se sugiere arriba, Zig incluye una biblioteca estándar opcional. Cada API de la standard library se compila solamente si es usada en el programa. Zig soporta igualmente efectuar linking opcional hacia libc. Zig es amigable para desarrollo de proyectos de muy bajo nivel y proyectos orientados a alto rendimiento.

Es lo mejor de dos mundos; por ejemplo, en Zig, los programas de WebAssembly pueden usar las características de la standard library y aún así generar binarios muy pequeños en comparación con los generados por otros lenguajes que soportan compilar a WebAssembly.

## Un lenguaje portable para bibliotecas

Uno de los santos griales de la programación es reusabilidad de código. Desafortunadamente, en la práctica, nos encontramos con frecuencia reinventando la rueda. Algunas veces es justificable.

* Si una aplicación incluye requerimientos de cómputo en tiempo real, debemos descartar cualquier biblioteca que haga uso de garbage collection (limpieza de memoria manejada).
* Si un lenguaje hace muy fácil ignorar errores y por ello vuelve difícil verificar que una biblioteca maneje errores correctamente, puede ser tentador ignorar una biblioteca y reimplementarla, sabiendo que que hemos manejado correctamente todos los errores relevantes. 
* Es cierto que actualmente C es el lenguaje mas versátil y portable. Cualquier lenguaje que carezca de la habilidad de interactuar con código C esta en riesgo de quedar en la oscuridad. Zig intenta convertirse en el nuevo lenguaje portable para bibliotecas, haciendo fácil la compatibilidad con el ABI de C para funciones externas y al mismo tiempo incorporando seguridad y un diseño de lenguaje que previene errores comunes entre implementaciones.

## Un manejador de paquetes y sistema de compilación para proyectos existentes

Zig es un lenguaje de programación que incluye un sistema de compilación y un manejador de paquetes diseñados para ser útiles incluso en el contexto de proyectos C/C++ tradicionales.

No solo puedes escribir código Zig en lugar de código C o C++, sino también usar Zig como un reemplazo para autotools, cmake, make, scons, ninja, etc. Además de esto, proveerá un manejador de paquetes para dependencias nativas. Este sistema de compilación está diseñado para ser útil aún cuando la totalidad del código de un proyecto esta escrito en C o C++.

Los manejadores de paquetes como apt, pacman, homebrew y otros, son instrumentales en la experiencia de usuario final, pero pueden ser insuficientes para las necesidades de un desarrollador de software. Un manejador de paquetes específico para un lenguaje puede ser la diferencia entre tener muchos o ningún contribuyente. Para proyectos de C/C++ tener dependencias puede ser fatal, especialmente en Windows, donde no hay manejadores de paquetes para dichos lenguajes. Incluso para compilar el lenguaje y herramientas Zig, la mayoría de contribuyentes potenciales encuentran difícil la dependencia con LLVM. Zig ofrece un mecanismo con el cual los proyectos dependerán de bibliotecas nativas directamente - sin importar si el usuario tiene o no una versión correcta en su manejador de paquetes del sistema y esto es una garantía de que el proyecto compilara en el primer intento sin importar que plataforma se esté utilizando.

Zig ofrece reemplazar un sistema de compilación con un lenguaje razonable que aporta un API para compilar proyectos y que al mismo tiempo aporta un manejador de paquetes y, por ende, la habilidad de depender de otras bibliotecas de C. La habilidad de tener dependencias permite llegar a niveles de abstracción mas altos y la proliferación de código reusable de alto nivel.

## Simplicidad

C++, Rust y D tienen una cantidad tan grande de características que pueden ser un distractor del verdadero significado de la aplicación que se está desarrollando. Es fácil verse depurando el propio conocimiento del lenguaje en lugar de estar depurando la aplicación en si.

Zig carece de macros y meta-programación, no obstante es suficientemente poderoso como para expresar programas complejos en una forma clara y no repetitiva. Incluso Rust, que cuenta con casos especiales de macros `format!`, implementado dentro del mismo compilador. Mientras tanto en Zig, la función equivalente esta implementada en la biblioteca estándar sin casos especiales de código en el compilador.

## Herramientas

Zig puede ser descargado desde [la sección de descargas](/download/). Zig provee binarios para Linux, Windows, MacOs y FreeBSD. En seguida se describe que obtienes con cada uno de estos archivos:

* se instala simplemente descargando el archivo y extrayendo el contenido, sin configuración adicional.
* compilado estáticamente y por ello, sin dependencias en tiempo de ejecución
* utiliza una infraestructura LLVM madura y bien soportada que permite gran optimización y soporte para la mayoría de plataformas
* listo desde el inicio para compilación entre las principales plataformas
* viene con código fuente para libc, el cual será compilado en forma dinámica cuando sea necesario para cualquier plataforma soportada
* incluye un sistema de compilación con mecanismo de cache
* compila C y C++ con soporte de libc