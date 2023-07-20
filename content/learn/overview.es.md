---
title: "Revisión a fondo"
mobile_menu_title: "Revisión"
toc: true
---
# Características
## Lenguaje simple y compacto

Concéntrate en depurar tu aplicación y no tus conocimientos del lenguaje.

La sintaxis completa de Zig se encuentra especificada en un [archivo de 500 lineas de gramática PEG](https://ziglang.org/documentation/master/#Grammar).

En Zig, no hay **control de flujo oculto**, ni asignaciones de memoria ocultas, ni preprocesador, ni macros. Si un fragmento de código Zig no parece estar saltando a hacer una llamada a una función, es por que no lo está haciendo. Esto significa que podemos estar seguros de que el siguiente código llama solo a `foo()` y después a `bar()` y esto esta garantizado sin tener que conocer tipo de dato alguno:

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

## Rendimiento y Seguridad: Elije dos

Zig tiene cuatro [modos de compilación](https://ziglang.org/documentation/master/#Build-Mode), los cuales pueden ser usados en forma individual o combinada en un [alcance granular](https://ziglang.org/documentation/master/#setRuntimeSafety).

| Parámetro | [Debug](/documentation/master/#Debug) | [ReleaseSafe](/documentation/master/#ReleaseSafe) | [ReleaseFast](/documentation/master/#ReleaseFast) | [ReleaseSmall](/documentation/master/#ReleaseSmall) |
|-----------|-------|-------------|-------------|--------------|
Optimizaciones - ejecutable rápido, depuración lenta, compilación lenta | | -O3 | -O3| -Os |
Chequeo de seguridad - ejecutable lento, ejecutable grande, finaliza en vez de 'undefined behavior' | On | On | | |

Así es como se ve el [desbordamiento de entero](https://ziglang.org/documentation/master/#Integer-Overflow) en tiempo de compilación, sin importar el modo de compilación:

{{< zigdoctest "assets/zig-code/features/1-integer-overflow.zig" >}}

Así es como se ve en tiempo de ejecución con chequeos de seguridad:

{{< zigdoctest "assets/zig-code/features/2-integer-overflow-runtime.zig" >}}


Estos ['stack traces' funcionan en todos los 'targets'](#stack-traces-on-all-targets), incluyendo [freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html).

Con Zig podemos confiar en un modo de compilación seguro y podemos deshabilitar selectivamente esos chequeos de seguridad cuando sea necesario exprimir al máximo el rendimiento. Por ejemplo, el fragmento de código anterior podría ser modificado así:
{{< zigdoctest "assets/zig-code/features/3-undefined-behavior.zig" >}}

Zig utiliza ['undefined behavior'](https://ziglang.org/documentation/master/#Undefined-Behavior) como una herramienta para prevención de bugs y mejoras de desempeño.

Hablando de desempeño, Zig es mas rápido que C.

- La implementación de referencia usa LLVM como backend para optimizaciones avanzadas.
- Zig hace automáticamente lo que otros proyectos llaman "Link Time Optimization"
- Zig tiene habilitadas algunas características avanzadas para 'targets' nativos (-march=native), gracias al hecho de que el ['cross-compiling' es un caso de uso de primera clase](#cross-compiling-is-a-first-class-use-case).
- Cuidadosamente seleccionado 'undefined behavior'. En Zig, tipos enteros con o sin signo (signed/unsigned) presentan comportamiento indefinido (undefined behavior) al momento de desborde (overflow), en contraste a C que solo presenta esta característica en enteros con signo. Esto [facilita optimizaciones que no están disponibles en C](https://godbolt.org/z/n_nLEU).
- Zig expone directamente un [tipo vector SIMD](https://ziglang.org/documentation/master/#Vectors), haciendo mas simple escribir código portable con vectores.

Toma en cuenta que Zig no es un lenguaje completamente seguro. Si estas interesado en seguir la historia relacionada con la seguridad de Zig, suscríbete a los siguientes issues:

- [Enumeración de todos los tipos de 'undefined behavior', incluyendo aquellos que no pueden ser verificados por los chequeos de seguridad](https://github.com/ziglang/zig/issues/1966)
- [Hacer los modos Debug y ReleaseSafe modos completamente seguros](https://github.com/ziglang/zig/issues/2301)

## Zig compite con C en vez de depender de el

La biblioteca estándar de Zig se integra con libc, pero no depende de ella. Aquí está un Hello World:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Al compilar con `-O ReleaseSmall`, lo cual remueve símbolos de depuración y es un modo single-threaded, se produce un ejecutable estático de 9.8 KiB para la arquitectura x86_64-linux:
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded
$ wc -c hello
9944 hello
$ ldd hello
  not a dynamic executable
```

En Windows se produce una compilación aún mas pequeña, llegando a 4096 bytes:
```
$ zig build-exe hello.zig -O ReleaseSmall -fstrip -fsingle-threaded -target x86_64-windows
$ wc -c hello.exe
4096 hello.exe
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Declaraciones de nivel superior independientes de orden

Las declaraciones de de nivel superior, como son las variables globales, son independientes de orden y analizadas en forma tardía. La inicialización de valores de variables globales es [evaluada en tiempo de compilación](#compile-time-reflection-and-compile-time-code-execution).

{{< zigdoctest "assets/zig-code/features/5-global-variables.zig" >}}

## Tipo de dato Optional en vez de punteros a null

En otros lenguajes de programación, las referencias a null son una fuente excepciones en tiempo de ejecución, incluso son acusadas de ser [el peor error en la ciencia de la computación](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/).

Los punteros Zig (sin adornos) no pueden ser null:

{{< zigdoctest "assets/zig-code/features/6-null-to-ptr.zig" >}}

No obstante, cualquier tipo pude ser un [tipo opcional](https://ziglang.org/documentation/master/#Optionals) utilizando el prefijo '?':

{{< zigdoctest "assets/zig-code/features/7-optional-syntax.zig" >}}

Para resolver un valor opcional, se puede usar `orelse` para proveer un valor por defecto:

{{< zigdoctest "assets/zig-code/features/8-optional-orelse.zig" >}}

Otra opción es usar if:

{{< zigdoctest "assets/zig-code/features/9-optional-if.zig" >}}

La misma sintaxis funciona con [while](https://ziglang.org/documentation/master/#while):

{{< zigdoctest "assets/zig-code/features/10-optional-while.zig" >}}

## Manejo manual de memoria

Una biblioteca escrita en Zig es elegible para ser usada en cualquier lugar:

- [Aplicaciones de escritorio](https://github.com/TM35-Metronome/)
- Servidores de baja latencia
- [Kernels de sistemas operativos](https://github.com/AndreaOrru/zen)
- [Dispositivos embebidos](https://github.com/skyfex/zig-nrf-demo/)
- Software en tiempo real, ejemplos: actuaciones en vivo, aviones, marcapasos
- [En web browsers o plugins con WebAssembly](https://shritesh.github.io/zigfmt-web/)
- Desde otros lenguajes de programación, usando el ABI de C

Para lograr esto, los programadores de Zig deben hacer un manejo de memoria manual y deben poder resolver fallas de asignación de memoria.

Esto también aplica para la biblioteca estándar de Zig. Cualquier función que requiera asignaciones de memoria acepta un parámetro 'allocator' (asignador de memoria). Como resultado, la biblioteca estándar de Zig pude ser usada para cualquier arquitectura objetivo.

Adicionalmente de lo dicho en [Una visión fresca sobre manejo de errores](#a-fresh-take-on-error-handling), Zig provee [defer](https://ziglang.org/documentation/master/#defer) y [errdefer](https://ziglang.org/documentation/master/#errdefer) para lograr que todo manejo de recursos, no solo de memoria, sea simple y fácilmente verificable.

Como ejemplo de `defer`, ve [Integración con bibliotecas de C sin FFI/bindings](#integration-with-c-libraries-without-ffibindings). Este es un ejemplo del uso de `errdefer`:
{{< zigdoctest "assets/zig-code/features/11-errdefer.zig" >}}


## Una visión fresca sobre manejo de errores

Los errores son valores y no deben ser ignorados:

{{< zigdoctest "assets/zig-code/features/12-errors-as-values.zig" >}}

Los errores pueden ser manejados con [catch](https://ziglang.org/documentation/master/#catch):

{{< zigdoctest "assets/zig-code/features/13-errors-catch.zig" >}}

La palabra reservada [try](https://ziglang.org/documentation/master/#try) es un atajo para `catch |err| return err`:

{{< zigdoctest "assets/zig-code/features/14-errors-try.zig" >}}

Notese que se trata de una traza de error: [Error Return Trace](https://ziglang.org/documentation/master/#Error-Return-Traces), y no de una traza de pila: [stack trace](#stack-traces-on-all-targets). Este código no incurrió en el costo de deshilar el stack (pila) para arrojar esa traza.

La plabra reservada [switch](https://ziglang.org/documentation/master/#switch), usada para evaluar un error asegura que todos los posibles errores sean manejados.

{{< zigdoctest "assets/zig-code/features/15-errors-switch.zig" >}}

La palabra reservada [unreachable](https://ziglang.org/documentation/master/#unreachable) es usada para asumir que no ocurrirán errores:

{{< zigdoctest "assets/zig-code/features/16-unreachable.zig" >}}

Esto invoca [undefined behavior](#performance-and-safety-choose-two) (comportamiento indefinido) en modos de compilación no segura, asegúrate de solo utilizarla cuando esté garantizado que no habrá errores.

### Stack traces (trazas de pila) en todas las arquitecturas objetivo

Las stack traces (trazas de pila) y las [error return traces](https://ziglang.org/documentation/master/#Error-Return-Traces) (trazas de error) mostradas en esta página funcionan para targets (arquitecturas objetivo) de [Soporte nivel 1](#tier-1-support-soporte-nivel-1) y algunas de [Soporte nivel 2](#tier-2-support-soporte-nivel-2). [Incluso freestanding](https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html)!

Adicionalmente, la biblioteca estándar es capaz de capturar trazas de pila en cualquier punto para posteriormente arrojarlas a la salida de error estándar:

{{< zigdoctest "assets/zig-code/features/17-stack-traces.zig" >}}

Puedes ver como es empleada esta técnica en el [proyecto GeneralPurposeDebugAllocator](https://github.com/andrewrk/zig-general-purpose-allocator/#current-status).

## Estructuras genéricas de datos y funciones

Los tipos de datos son valores y esto debe ser conocido en tiempo de compilacion:

{{< zigdoctest "assets/zig-code/features/18-types.zig" >}}

Una estructura genérica de datos es simplemente una función que retorna un `tipo`:

{{< zigdoctest "assets/zig-code/features/19-generics.zig" >}}

## Introspección y ejecución de código en tiempo de compilación

La función [@typeInfo](https://ziglang.org/documentation/master/#typeInfo) provee introspección (reflection):

{{< zigdoctest "assets/zig-code/features/20-reflection.zig" >}}

La biblioteca estándar de Zig utiliza esta técnica para implementar salida formateada.
No obstante de ser un [lenguaje compacto y simple](#small-simple-language), el formateo de salida de Zig está implementado completamente con el mismo lenguaje Zig. Mientras tanto en C, los errores de compilación para `printf` están codificados manualmente dentro del compilador. De forma similar, en Rust, el macro para salida formateada esta codificado dentro del compilador.

Zig es capaz de evaluar funciones y bloques de código en tiempo de compilación. En algunos contextos tales como inicialización de variables globales, la expresión es evaluada implícitamente en tiempo de compilación. Además de esto, es posible evaluar código en tiempo de compilación con la palabra reservada [comptime](https://ziglang.org/documentation/master/#comptime). Esta característica, combinada con 'assertions' de pruebas aporta gran poder:

{{< zigdoctest "assets/zig-code/features/21-comptime.zig" >}}

## Integración con bibliotecas de C sin FFI/bindings

[@cImport](https://ziglang.org/documentation/master/#cImport) importa directamente tipos, variables, funciones y macros simples para ser usados en Zig. Incluso traduce funciones 'inline' de C a Zig.

Este es un ejemplo de como emitir una onda sinusoidal usando [libsoundio](http://libsound.io/):

<u>sine.zig</u>
{{< zigdoctest "assets/zig-code/features/22-sine-wave.zig" >}}

```
$ zig build-exe sine.zig -lsoundio -lc
$ ./sine
Output device: Built-in Audio Analog Stereo
^C
```

[Este código Zig es significativamente mas simple que su equivalente en C](https://gist.github.com/andrewrk/d285c8f912169329e5e28c3d0a63c1d8), además de contar con mayores protecciones de seguridad y todo esto se logra importando directamente archivos de encabezado de C y no 'bindings' de API.

*Zig es mejor usando bibliotecas de C que el mismo C.*

### Zig es también un compilador de C

Este es un ejemplo de Zig compilado algo de código C:

<u>hello.c</u>
```c
#include <stdio.h>

int main(int argc, char **argv) {
    printf("Hello world\n");
    return 0;
}
```

```
$ zig build-exe hello.c --library c
$ ./hello
Hello world
```

Puedes usar la opción `--verbose-cc` para ver que comando del compilador de C fue ejecutado:
```
$ zig build-exe hello.c --library c --verbose-cc
zig cc -MD -MV -MF zig-cache/tmp/42zL6fBH8fSo-hello.o.d -nostdinc -fno-spell-checking -isystem /home/andy/dev/zig/build/lib/zig/include -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-gnu -isystem /home/andy/dev/zig/build/lib/zig/libc/include/generic-glibc -isystem /home/andy/dev/zig/build/lib/zig/libc/include/x86_64-linux-any -isystem /home/andy/dev/zig/build/lib/zig/libc/include/any-linux-any -march=native -g -fstack-protector-strong --param ssp-buffer-size=4 -fno-omit-frame-pointer -o zig-cache/tmp/42zL6fBH8fSo-hello.o -c hello.c -fPIC
```

Observa que si se ejecuta el comando de nuevo, no habrá salida y el comando termina al instante:
```
$ time zig build-exe hello.c --library c --verbose-cc

real	0m0.027s
user	0m0.018s
sys	0m0.009s
```
Esto ocurre gracias a [Build Artifact Caching](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching). Zig, automaticamente interpreta el archivo .d utilizando un robusto sistema de cache para evitar duplicar el trabajo.

Existe un buen motivo para usar Zig como compilador de C: [Zig ships with libc](#zig-ships-with-libc).

### Funciones, variables y tipos de exportación como dependencias de código C

Uno de los principales casos de uso de Zig es exportar una biblioteca con el ABI de C para ser llamada desde otros lenguajes de programación. La palabra reservada `export` antes del nombre de una función, variable o definición de tipo, hace que dichos elementos sean parte de la API de la biblioteca:

<u>mathtest.zig</u>
{{< zigdoctest "assets/zig-code/features/23-math-test.zig" >}}

Para crear una biblioteca estática:
```
$ zig build-lib mathtest.zig
```

Para crear una biblioteca compartida:
```
$ zig build-lib mathtest.zig -dynamic
```

Este es un ejemplo con el [Zig Build System](#zig-build-system) (sistema de compilación de Zig):

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

## Cross-compiling (compilación para arquitectura objetivo distinta) es un caso de uso de primera clase

Zig puede compilar para cualquiera de los objetivos en [Support Table](#support-table) con [Tier 3 Support](#tier-3-support-soporte-nivel-3) (nivel 3 de soporte) o mayor. No se necesitan herramientas adicionales. Este es un ejemplo nativo de Hello World:

{{< zigdoctest "assets/zig-code/features/4-hello.zig" >}}

Para compilar este ejemplo específicamente para arquitecturas x86_64-windows, x86_64-macos, y aarch64-linux:
```
$ zig build-exe hello.zig -target x86_64-windows
$ file hello.exe
hello.exe: PE32+ executable (console) x86-64, for MS Windows
$ zig build-exe hello.zig -target x86_64-macos
$ file hello
hello: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|PIE>
$ zig build-exe hello.zig -target aarch64-linux
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, with debug_info, not stripped
```

Esto aplica en cualquier objetivo [Tier 3](#tier-3-support-soporte-nivel-3)+, para cualquier objetivo [Tier 3](#tier-3-support-soporte-nivel-3)+.

### libc viene incluida en Zig

Puedes encontrar las arquitecturas objetivo libc con `zig targets`:
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

Esto significa que `--library c` para estos objetivos *no depende de ningun archivo del sistema*!

Demos de nuevo un vistazo al [ejemplo de hello world en C](#zig-is-also-a-c-compiler):
```
$ zig build-exe hello.c --library c
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

[glibc](https://www.gnu.org/software/libc/) no soporta compilar en forma estática, pero [musl](https://www.musl-libc.org/) si:
```
$ zig build-exe hello.c --library c -target x86_64-linux-musl
$ ./hello
Hello world
$ ldd hello
  not a dynamic executable
```
En este ejemplo, Zig compiló musl libc desde los fuentes para luego proceder a hacer el 'link'. La compilación de musl libc para x86_64-linux se mantiene disponible gracias al [sistema de cache](https://ziglang.org/download/0.4.0/release-notes.html#Build-Artifact-Caching), de manera que esta libc estará disponible cuando sea necesaria.

Esta funcionalidad está disponible en cualquier plataforma. Los usuarios de Windows y macOs pueden compilar código Zig y C y efectuar link con libc para cualquiera de los objetivos listados arriba. De igual forma, el código puede ser compilado entre otras arquitecturas:
```
$ zig build-exe hello.c --library c -target aarch64-linux-gnu
$ file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 2.0.0, with debug_info, not stripped
```
De alguna forma, Zig es un mejor compilador de C que el mismo C!

Esta funcionalidad es mas que construir una cadena de herramientas de inter-compilación con Zig. Por ejemplo, el tamaño total los encabezados de libc que vienen con Zig es de 22 MiB sin comprimir. Mientras tanto, los encabezados de musl libc + encabezados de linux en solamente x86_64 son 8 MiB y para glibc 3.1 MiB (glibc no incluye los encabezados de linux), aun así, Zig se distribuye con 40 diferentes libc. Con una compilación típica, esto resultaría en 444 MiB. Grácias al [process_headers tool](https://github.com/ziglang/zig/blob/0.4.0/libc/process_headers.zig) que desarrollé y un poco de [trabajo manual](https://github.com/ziglang/zig/wiki/Updating-libc), Los tarballs (archivos tar comprimidos) de binarios de Zig se mantienen en aproximadamente 30 MiB en total a pesar de soportar libc para todos estas arquitecturas y soportar compiler-rt, libunwind y libcxx y a pesar de ser un compilador compatible con C. Como comparación, el binario de Windows para clang 8.0.0 de llvm.org es de 132 MiB.

Toma en cuenta que solo las arquitecturas de [Tire 1 Support](#tier-1-support-soporte-nivel-1) han sido probadas exhaustivamente. Hay planes para [añadir más libcs](https://github.com/ziglang/zig/issues/514) (incluyendo Windows) y para [añadir cobertura de pruebas para compilar hacia todas las libc](https://github.com/ziglang/zig/issues/2058).

Está planeado [tener un manejador de paquetes para Zig](https://github.com/ziglang/zig/issues/943), pero aun no esta listo. Una de las cosas que serán posibles es la capacidad de crear un paquete para bibliotecas de C. Esto hará el [sistema de compilación de Zig](#zig-build-system) atractivo tanto para programadores de Zig como de C.

## El sistema de compilación de Zig

Zig viene con un sistema de compilación, de tal forma que no necesitas make, cmake o nada parecido. 
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

Veamos el menú `--help`.
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
Podemos ver que uno de los pasos es 'run'.
```
$ zig build run
All your base are belong to us.
```

Aquí, algunos ejemplos de scripts de compilación:

- [Build script of OpenGL Tetris game](https://github.com/andrewrk/tetris/blob/master/build.zig)
- [Build script of bare metal Raspberry Pi 3 arcade game](https://github.com/andrewrk/clashos/blob/master/build.zig)
- [Build script of self-hosted Zig compiler](https://github.com/ziglang/zig/blob/master/build.zig)

## Concurrencia vía funciones asíncronas

Zig 0.5.0 [introdujo funciones asincronas](https://ziglang.org/download/0.5.0/release-notes.html#Async-Functions). Esta característica no tiene dependencia con un sistema operativo o memoria asignada. Las funciones asíncronas están disponibles independientemente de la arquitectura.

Zig puede inferir si una función es asíncrona o no y permite `async/await` en funciones no asíncronas, lo que significa que **las bibliotecas de Zig son agnósticas con respecto a I/O (entrada/salida) blocking vs. async**. [Zig avoids function colors](http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).

La biblioteca estándar de Zig implementa un loop de evento que multiplexa funciones 'async' en un pool de hilos para concurrencia M:N. Seguridad multi-hilo y detección de 'race conditions' son áreas en continua investigación.

## Amplia gama de arquitecturas soportadas

Zig utilíza un sistema de "support tier" (nivel de soporte) para comunicar el nivel de soporte de diferentes arquitecturas. Toma en cuenta que los requerimientos para [Tier 1 Support](#tier-1-support-soporte-nivel-1) son altos pero [Tier 2 Support](#tier-2-support-soporte-nivel-2) es bastante usable.

### Tabla de soporte

| | free standing | Linux 3.16+ | macOS 10.13+ | Windows 8.1+ | FreeBSD 12.0+ | NetBSD 8.0+ | DragonFlyBSD 5.8+ | UEFI |
|-|---------------|-------------|--------------|--------------|---------------|-------------|-------------------|------|
| x86_64 | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) |
| arm64 | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) |
| arm32 | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 2](#tier-2-support-soporte-nivel-2) | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) |
| mips32 LE | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 2](#tier-2-support-soporte-nivel-2) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| i386 | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | [Tier 2](#tier-2-support-soporte-nivel-2) |
| riscv64 | [Tier 1](#tier-1-support-soporte-nivel-1) | [Tier 2](#tier-2-support-soporte-nivel-2) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) |
| powerpc32 | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| powerpc64 | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| mips32 BE | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| mips64 | [Tier 2](#tier-2-support-soporte-nivel-2) | [Tier 2](#tier-2-support-soporte-nivel-2) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| bpf | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| hexagon | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| amdgcn | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| sparc | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| s390x | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| lanai | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A | [Tier 3](#tier-3-support-soporte-nivel-3) | [Tier 3](#tier-3-support-soporte-nivel-3) | N/A | N/A |
| avr | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| riscv32 | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) |
| xcore | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| nvptx | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| msp430 | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| r600 | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| arc | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| tce | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| le | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| amdil | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| hsail | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| spir | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| kalimba | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| shave | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |
| renderscript | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A | [Tier 4](#tier-4-support-soporte-nivel-4) | [Tier 4](#tier-4-support-soporte-nivel-4) | N/A | N/A |


### Tabla de soporte para WebAssembly

|        | free standing | emscripten | WASI   |
|--------|---------------|------------|--------|
| wasm32 | [Tier 1](#tier-1-support-soporte-nivel-1)        | [Tier 3](#tier-3-support-soporte-nivel-3)     | [Tier 1](#tier-1-support-soporte-nivel-1) |
| wasm64 | [Tier 4](#tier-4-support-soporte-nivel-4)        | [Tier 4](#tier-4-support-soporte-nivel-4)     | [Tier 4](#tier-4-support-soporte-nivel-4) |


### Tier System (sistema de niveles de soporte)

#### Tier 1 Support (soporte nivel 1)
- Para estas arquitecturas Zig puede generar código maquina además de contar con implementación de abstracciones de la standard library.
- El servidor de CI efectúa pruebas automáticamente en estas arquitecturas en cada commit a la rama master del repositorio oficial y se actualiza la [página de descarga]({{< ref "/download/" >}}) con links a los binarios precompilados.
- Estas arquitecturas tienen capacidades de información de depuración, de tal manera que producen [stack traces](#stack-traces-on-all-targets) (trazas de pila) en los tests fallidos.
- [libc esta disponible para estas arquitecturas incluso cuando se realizan compilaciones entre plataformas](#zig-ships-with-libc).
- Todas las pruebas de comportamiento y pruebas de la standard library pasan para estas arquitecturas. Todas las características del lenguaje trabajan de forma correcta.

#### Tier 2 Support (soporte nivel 2)
- La standard library (biblioteca estándar) soporta estas arquitecturas pero es posible que algunas APIs arrojen un error de "Unsupported OS". Se puede hacer link con libc u otras bibliotecas para llenar el hueco en la standard library.
- Se sabe que estas arquitecturas funcionan pero pueden no estar probadas automáticamente, así que hay regresiones ocasionales.
- Algnas pruebas pueden estar deshabilitadas para estas arquitecturas mientras trabajamos para llevarlas a [Tier 1 Support](#tier-1-support-soporte-nivel-1).

#### Tier 3 Support (soporte nivel 3)

- La standard library tiene poco (o nada) de conocimiento de la existencia de esta arquitectura.
- Debido a que Zig esta basado en LLVM, existe la capacidad de compilar para estas arquitecturas y LLVM la arquitectura habilitada por defecto.
- Estas arquitecturas no son probadas con frecuencia; muy probablemente tendrías que contribuir al desarrollo de Zig para ser capaz de compilar para estas arquitecturas.
- El compilador de Zig puede necesitar ser actualizado con información adicional como:
  - tamaño de los tipos enteros de C
  - convenciones de llamadas al ABI de C para esta arquitectura
  - código de arranque y manejo de 'panic' por defecto
- Se garantiza que la tabla de arquitecturas soportadas de Zig incluirá esta arquitectura

#### Tier 4 Support (soporte nivel 4)

- El soporte para estas arquitecturas es completamente experimental
- Es posible que LLVM tenga esta arquitectura etiquetada como experimental, lo que significa que necesitarás usar binarios ofrecidos por Zig para que esta arquitectura esté disponible, o bien, compilar LLVM desde fuentes con opciones de configuración especiales.
- Estas arquitecturas pueden haber expirado, por ejemplo [macos/i386](https://support.apple.com/en-us/HT208436), en cuyo caso quedará perpetuamente en nivel de soporte 4.
- Es posible que estas arquitecturas solo soporten `--emit` asm y no puedan emitir archivos.

## Amigable con los desarrolladores de paquetes

El compilador estándar de Zig no está completamente auto-contenido aún, no obstante [permanecerá a exactamente 3 pasos](https://github.com/ziglang/zig/issues/853) de ser un compilador de C++ a ser un compilador totalmente autocontenido para cualquier plataforma. Como lo menciona Maya Rashish [portar Zig a otras plataformas es divertido y rápido](http://coypu.sdf.org/porting-zig.html).

[Los modos de compilación sin depuración](https://ziglang.org/documentation/master/#Build-Mode) son reproducibles y deterministicos.

Existe una [versión JSON de la página de descargas](/download/index.json).

Muchos miembros del equipo de Zig tienen experiencia manteniendo paquetes.

- [Daurnimator](https://github.com/daurnimator) mantiene el [paquete para Arch Linux](https://archlinux.org/packages/extra/x86_64/zig/)
- [Marc Tiehuis](https://tiehuis.github.io/) mantiene el paquete de Visual Studio Code.
- [Andrew Kelley](https://andrewkelley.me/) trabajo por un año desarrollando [paquetes para Debian y Ubuntu](https://qa.debian.org/developer.php?login=superjoe30%40gmail.com&comaint=yes), y ocasionalmente contribuye con [nixpkgs](https://github.com/NixOS/nixpkgs/).
- [Jeff Fowler](https://blog.jfo.click/) mantiene el paquete Homebrew e inició el [paquete Sublime](https://github.com/ziglang/sublime-zig-language) (hoy mantenido por [emekoi](https://github.com/emekoi)).
