---
title: Primeros pasos
mobile_menu_title: "Primeros pasos"
toc: true
---

## Lanzamientos etiquetados o compilación nightly?
Zig no ha alcanzado la versión 1.0 aún y el ciclo de lanzamiento actual depende de la liberación de LLVM, lo cual ocurre cada ~6 meses.
En términos prácticos, **los lanzamientos de Zig tienden a ser muy separados entre si y ocasionalmente llegan a perder vigencia debido a la velocidad en el desarrollo del lenguaje.**.

No hay problema con evaluar Zig utilizando alguna de las versiones etiquetadas, pero si decides que quieres continuar programando con Zig mas a fondo, **te recomendamos actualizar a las compilaciones nightly**, ya que de esa manera será más fácil obtener ayuda: la mayoría de los miembros de la comunidad y sitios como [ziglearn.org](https://ziglearn.org) siguen la rama "master" del repositorio por las razones expuestas arriba.

La buena noticia es que es muy fácil de moverse de una versión de Zig a otra, o incluso tener múltiples versiones presentes en el sistema al mismo tiempo: las versiones de Zig son un simple directorio con todo lo necesario, el cual puede ser colocado en cualquier ubicación del sistema.

## Instalación de Zig
### Descarga directa
Esta es la manera mas simple de obtener Zig: descarga un paquete de Zig correspondiente a tu plataforma desde la [página de descargas](/es/download), extrae el contenido en el directorio de tu elección y añade la ruta al `PATH` para poder ejecutar `zig` desde cualquier ubicación.

#### Configuración de la variable de entorno PATH en Windows
Para configurar la ruta de Zig en el `PATH` the Windows ejecuta **uno** de los siguientes fragmentos de código en una terminal Powershell. Elige si quieres aplicar el cambio para todos los usuarios del sistema (lo cual requiere ejecutar Powershell con derechos de administrador) o solo para el usuario actual, y **asegúrate de ajustar el fragmento de código para que apunte a la ubicación de tu copia de Zig**. El `;` antes de `C:` no es un error.

Para todos los usuarios (Powershell ejecutado como **administrador**):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\tu-ruta\zig-windows-x86_64-tu-versión",
   "Machine"
)
```

Para el usuario actual (Powershell):
```
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\tu-ruta\zig-windows-x86_64-tu-versión",
   "User"
)
```
Después de esto, reinicia la terminal de Powershell.

#### Configuración de la variable de entorno PATH Linux, macOS, BSD
Añade la ubicación del ejecutable zig a la variable de ambiente PATH.

Generalmente, esto se hace agregando una linea de 'export' a tu script de inicio del shell (`.profile`, `.zshrc`, ...)
```bash
export PATH=$PATH:~/ruta/a/zig
```
Después de esto, reinicia tu shell o actualiza con el comando `source`




### Manejadores de paquetes
#### Windows
Zig está disponible en [Chocolatey](https://chocolatey.org/packages/zig).
```
choco install zig
```

#### macOS

**Homebrew**  
Último lanzamiento etiquetado:
```
brew install zig
```

**MacPorts**
```
port install zig
```
#### Linux
Zig también se encuentra en muchos manejadores de paquetes para Linux. [Aquí](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
puedes encontrar una lista actualizada pero ten en cuenta que algunos paquetes pueden incluir versiones no actualizadas de Zig.

### Compilar desde los fuentes
[Aquí](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source) 
puedes encontrar mas información sobre como compilar Zig desde el código fuente para Linux, macOS y Windows.

## Herramientas recomendadas
### Marcado de sintaxis y LSP (Language Server Protocol)
Los principales editores de texto orientados a programación incluyen marcado de sintaxis para Zig. En algunos casos se incluye en forma integrada y en otros casos se requiere la instalación de plugins.

Si te interesa una integración mas profunda entre Zig y tu editor, 
dale un vistazo a [zigtools/zls](https://github.com/zigtools/zls).

Para mas opciones disponibles, revisa la sección de [Herramientas](../tools/).

## Ejecuta Hello World
Si completaste la instalación correctamente, deberás poder invocar el compilador de Zig desde tu terminal de comandos. Probemos creando un primer programa Zig!

Navega a tu directorio de proyectos y ejecuta:
```bash
mkdir hello-world
cd hello-world
zig init-exe
```

Esto deberá arrojar:
```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

Al ejecutar `zig build run` se compilará y ejecutará el programa, resultando en:
```
info: All your codebase are belong to us.
```

Felicidades, ahora tienes una instalación de Zig funcional!

## Siguientes pasos
**Revisa otros recursos presentes en la sección [Aprender](../)**, asegurate de encontrar la documentación para tu versión de Zig (nota: los compilados nightly corresponden a la documentación `master`) y considera leer [ziglearn.org](https://ziglearn.org).

Zig es un proyecto joven y desafortunadamente aún no tenemos la capacidad para producir documentación y materiales extensivos para todas sus características, así que considera [unirte a alguna de las comunidades existentes de Zig](https://github.com/ziglang/zig/wiki/Community) para obtener ayuda. También da un vistazo a [Zig SHOWTIME](https://zig.show).

Finalmente, si disfrutas Zig y quieres ayudar a acelerar su desarrollo, [considera donar a la Zig Software Foundation](../../zsf)
<img src="/heart.svg" style="vertical-align:middle; margin-right: 5px">.
