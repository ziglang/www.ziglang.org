---
title: Главная
mobile_menu_title: "Главная"
---
{{< slogan get_started="НАЧАЛО РАБОТЫ" docs="Документация" notes="Список изменений" lang="ru" >}}
Zig — это язык программирования общего назначения и инструмент для создания **надёжного**, **оптимального** и **переиспользуемого** ПО.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Простой язык
Сфокусируйтесь на отладке вашего приложения, а не на отладке вашего знания языка программирования.

- Без скрытых потоков управления.
- Без скрытых выделений памяти.
- Без препроцессора и макросов.

# ⚡ Comptime
Свежий подход к метапрограммированию, основанный на выполнении кода во время компиляции и "ленивых" (отложенных) вычислениях.

- Вызывайте любую функцию во время компиляции.
- Используйте типы как значения, без накладных расходов во время выполнения.
- Comptime эмулирует целевую архитектуру.

# ⚡ Сопровождайте с Zig
Постепенно улучшайте вашу кодовую базу на C/C++/Zig.

- Используйте Zig как готовый C/C++ компилятор без зависимостей, который поддерживает кросс–компиляцию "из коробки".
- Используйте `zig build` для создания консистентной среды разработки на всех платформах.
- Добавляйте частички Zig в C/C++ проекты. Меж–языковая "оптимизация во время связывания" (LTO) включена по умолчанию.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">Подробный обзор</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">Больше примеров кода</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Сообщество" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# Сообщество Zig децентрализованно
Любой может свободно свободно создать и поддерживать своё собственное пространство для коллективного общения.
Здесь не существует понятий "официальный" или "неофициальный", однако у таких пространств есть свои модераторы и правила.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Просмотреть все сообщества</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Основная разработка
Репозиторий Zig находится по адресу [https://github.com/ziglang/zig](https://github.com/ziglang/zig), где мы также содержим систему отслеживания задач и обсуждаем предложения.
От участников ожидается соблюдение [Кодекса поведения](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md) Zig.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## ZSF — это некоммерческая 501(c)(3) корпорация.

Zig Software Foundation — это некоммерческая корпорация, основанная в 2020 Эндрю Келли (Andrew Kelley), создателем Zig, чтобы поддерживать развитие языка. В настоящее время, ZSF может оплачивать труд малого количества основных разработчиков по конкурентной зарплате. Мы надеемся расширить это предложение на большее количество людей в будущем.

Zig Software Foundation поддерживается за счет пожертвований.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Узнать больше</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Спонсоры" %}}
# Корпоративные спонсоры
Данные компании оказывают прямую финансовую поддержку Zig Software Foundation.

{{% sponsor-logos "monetary" %}}
 <a href="https://pex.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/pex-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/pex-dark.svg">
   </picture>
 </a> 
 <a href="https://coil.com" rel="noopener nofollow" target="_blank"><picture>
   <picture>
     <source srcset="/coil-logo-white.svg" media="(prefers-color-scheme: dark)">
     <img src="/coil-logo-black.svg">
   </picture>
 </a>
{{% /sponsor-logos %}}

# Спонсоры с GitHub
Благодаря людям, которые [спонсируют Zig](zsf/), проект подотчётен сообществу открытого кода, а не корпоративным акционерам. В частности, эти замечательные люди спонсируют Zig по 200 долларов в месяц или более:

{{< ghsponsors >}}

Этот раздел обновляется в начале каждого месяца.
{{% /div %}}
{{< /div >}}
