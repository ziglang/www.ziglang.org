# ziglang.org

Website for [Zig](https://github.com/ziglang/zig)

## How to run locally

### Requirements

- A build of [kristoff-it/hugo](https://github.com/kristoff-it/hugo)
- A build of [kristoff-it/zig-doctest](https://github.com/kristoff-it/zig-doctest)
- Latest Zig (the website tracks master branch)

Hugo needs to be built with CSS support:

```
CGO_ENABLED=1 go build --tags extended
```

Finally, Hugo expects to find both `zig` and `doctest` in `$PATH`.

### Running the development server

Run `hugo serve`. On first launch it will use doctest to run all code snippets present in the website. Any error at this stage will either be about missing doctest, Zig being outdated (thus erroneously failing correct tests), or a code snippet failing a test for legitimate reasons.

After Hugo is launched you can use it to preview in realtime changes to the content. Right now Hugo has a limitation where changing a code snippet will not cause a re-render unless the page that lists it changes too (or you restart Hugo).

Tests are cached so don't worry about having to sit through the entire testing routine after restarting Hugo.

## Writing a translation

Translations rely on three main Hugo-specific conventions:

1. The presence of the corresponding language in `config.toml`
2. The `themes/ziglang-original/i18n` directory, which contains translations for menu elements, the download page and a few other miscelanneous strings.
3. In `content/`, the presence of markdown files for the specific language you're translating to.

Let's say that you're working on a Japanese translation.
The [two-letter ISO code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) for Japanese is `ja`.

Start by adding the new translation to `config.toml`:

```
DefaultContentLanguage = "en"
[languages]
  [languages.en]
    languageName = "English"
    weight = 1
  [languages.it]
    languageName = "Italiano"
    weight = 2
  [languages.pt]
    languageName = "Português"
    weight = 2
```

Then copy `content/_index.en.md` to `content/_index.ja.md` and apply a small change to be able to distinguish the two versions.

Start `hugo serve` (or reload it); at this point you can go in your browser to `localhost:PORT/ja/` to preview your translation.

Translate all files in `content/` that have a `.en.md` extension, and translate `themes/ziglang-original/i18n/en.toml` to translate some menu items, the downloads page, and a few other miscelanneous strings.

Finally, add your translation to `translations/index.md`.

### Getting help

Crafting a translation is not a straight-forward proceess. You have to think about adaptation, spatial constraints (in the front page especially), and other Hugo-specific issues that might not be immediately obvious.

If you don't mind instant messaging, please consider joining one of the Zig Discord communities, where you will be able to communicate with other contributors and share some knowledge.

If you prefer asynchronous communication, feel free to open a draft PR, we will make sure to engage with you pronto.

Keep in mind that it's possible that the current setup doesn't allow you correctly implement a translation without making ulterior changes to Hugo's configuration or how the content is organized. Don't hesitate to reach out for help to avoid getting stuck in a problem that can't be solved without larger-scale changes.

## Legacy workflows

### How to update documentation

The docs here are actually generated using a
tool written in zig. Here's where the source files are:

- [docs](https://github.com/zig-lang/zig/blob/master/doc/langref.html.in)

### How to update release notes

Edit files in src/.

To upload:

```
export ZIG_DOCGEN=/home/andy/dev/zig/zig-out/docgen
./build
```

Both the source and the output are committed to this repo because docgen is
likely to change in the future. The `build` script will only build the
release notes for the latest release.
