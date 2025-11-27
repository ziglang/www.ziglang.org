# ziglang.org

Website for [Zig](https://ziglang.org/).

## How to Run Locally

We use [Zine](https://zine-ssg.io) for static site generation.

Zine, and the Zig website itself (when it comes to code samples), target the latest tagged release of Zig.

For a convenient way of juggling multiple versions of Zig, take a look at [zigup](https://github.com/marler8997/zigup).

Once you have the correct version of Zig setup, simply run:

```
zig build serve
```

### Get Editor Support

This step is optional but highly recommended.

Follow [the instructions](https://zine-ssg.io/docs/editors/) on the official Zine website.

Following this step will give you syntax highlighting and LSP support for the templating language.

### Get other dependencies
Some code examples present on the site require some basic system dependencies:
- tar
- zlib
- jq 

It should be possible to get them on all major OSs although on Windows it might be easier to just use WSL.
If you know how to get all dependencies on Windows please PR some instructions!

## Writing a Translation

See [the Zine documentation](https://zine-ssg.io/docs/) to learn more about content and templating syntax.

After you've familiarized yourself with the basics, take a look at [the i18n section](https://zine-ssg.io/docs/i18n/) of the docs.

To recap, a translation needs to:

- be listed in `build.zig` and have its corresponding content directory created
- have a corresponding Ziggy file under `i18n/`, containing the localized version of every phrase used throughout the site
- have all content files translated, with the exception of `news` and `devlog` that should not be translated

### Getting Help

Crafting a translation is not a straight-forward process. You have to think about adaptation, spatial constraints (in the front page especially), and other Zine-specific issues that might not be immediately obvious.

If you don't mind instant messaging, please consider joining one of the [Zig communities](https://ziglang.org/community/), where you will be able to communicate with other contributors and share some knowledge.

If you prefer asynchronous communication, feel free to open a draft PR, we will make sure to engage with you pronto.

Keep in mind that it's possible that the current setup doesn't allow you to correctly implement a translation without making ulterior changes to Zine's configuration or how the content is organized. Don't hesitate to reach out for help to avoid getting stuck in a problem that can't be solved without larger-scale changes.

