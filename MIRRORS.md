> [!NOTE]
> Are you trying to download Zig from a mirror? If so, you're in the wrong place! This documentation is for anyone who wants to *host* a community mirror.
> For instructions on *using* the mirrors, check out the [Community Mirrors](https://ziglang.org/download/community-mirrors/) page on the Zig website.

# Community Mirrors

The Zig mirrors in this repository are all community-maintained and unaffiliated with the ZSF. Anyone is welcome to host their own mirror and add it to the
list. Because Zig's tarballs are cryptographically signed, no mirror need be trusted. Of course, if a mirror is found to be malicious, it will be removed from
the list.

The following rules define how a mirror works and the requirements it is expected to fulfil.

* A mirror provides a single base URL, which we will call `X`.
* `X` **may** include a path component, but is not required to. For instance, `https://foo.bar/zig/` is okay,
  as is `https://zig.baz.qux/`.
* The mirror **must** support HTTPS with a valid signed certificate. `X` **must** start with `https://`.
* The mirror **must** cache tarballs locally. For instance, it may not simply forward all requests to another mirror.
* The mirror **may** routinely evict its local tarball caches based on any reasonable factor, such as age, access frequency, or the existence of newer versions. This does not affect whether the mirror may respond with 404 Not Found for requests to these files (see below).
* The mirror **must** download tarballs from `https://ziglang.org/` or a valid mirror of it.
  * Typically, it is best to download only from `https://ziglang.org/`. One possible exception is when a pre-release is requested which is more likely to be available from an alternative mirror.
* When a mirror receives a GET request for `X/<filename>`, the behavior depends on `<filename>`.
  * Parse the file name to extract the Zig version string. More details on this are [below](#parsing-versions).
  * Determine whether this is a "normal" or "pre-release" [Semantic Version](https://semver.org/).
  * If this is a "normal" version, respond with 200 OK and the file found at `https://ziglang.org/download/<version>/<filename>`.
    * If the release version is "0.5.0" or older (according to Semantic Versioning), the mirror **may** respond with 404 Not Found, but is not required to.
    * Otherwise, the mirror **must** return the tarball.
    * These requirements apply equally to source tarballs (e.g. `zig-0.14.1.tar.xz`), bootstrap source tarballs (e.g. `zig-bootstrap-0.14.1.tar.xz`), and binary tarballs (e.g. `zig-x86_64-linux-0.14.1.tar.xz`).
  * Otherwise (i.e. if this is a "pre-release" version), respond with 200 OK and the file found at `https://ziglang.org/builds/<filename>`.
    * If the version is older than the latest "release" version (according to Semantic Versioning), the mirror **may** respond with 404 Not Found, but is not required to.
    * Otherwise, the mirror **must** return the tarball.
    * These requirements apply equally to source tarballs (e.g. `zig-0.15.0-dev.671+c907866d5.tar.xz`), bootstrap source tarballs (e.g. `zig-bootstrap-0.15.0-dev.671+c907866d5.tar.xz`), and binary tarballs (e.g. `zig-x86_64-linux-0.15.0-dev.671+c907866d5.tar.xz`).
  * Invalid accesses, for instance to malformed filenames, **may** cause a 404 Not Found response.
  * Accesses to file names which do not end with ".zip", ".tar.xz", ".zip.minisig", or ".tar.xz.minisig", **may** cause a 404 Not Found response.
* Files provided by the mirror **must** be bit-for-bit identical to their `https://ziglang.org/` counterparts.
* If a mirror is required to serve a tarball which is has not yet cached locally, it **must** immediately download it from its source at `https://ziglang.org`, and respond with that downloaded file.
* The mirror **may** rate-limit accesses. If an access failed due to rate-limiting, the mirror **should** respond with 429 Too Many Requests.
* The mirror **may** undergo maintenance, upgrades, and other scheduled downtime. If an access fails for this reason, where possible, the mirror **should** respond with 503 Unavailable. The mirror **should** try to minimize such downtime.
* The mirror **may** undergo occasional unintended and unscheduled downtime. The mirror **must** go to all efforts to minimize such outages, and **must** resolve such outages within a reasonable time upon being notified of them.
* The mirror **may** observe the query parameter named `source` to learn about the origin of its traffic.
  * Clients are encouraged, but not required, to provide this query parameter to indicate what service triggered the request. For instance, the `mlugg/setup-zig` GitHub Action passes this query parameter as `?source=github-mlugg-setup-zig`.

## Parsing Versions

Mirrors are required to parse tarball file names to extract the Zig version from them. Unfortunately,
this is complicated a little by two factors: the existence of "source" tarballs, and the fact that
Zig's tarball naming schema changed with the 0.14.1 release.

If you have access to Regular Expressions, a simple strategy is to search the tarball name for
`/\d+\.\d+\.\d+(-dev\.\d+\+[0-9a-f]+)?/`. This is probably inefficient, but that is unlikely to
matter in practice.

An alternative strategy which is simpler but requires slightly more code is as follows:
* Strip a supported extension (`.zip`, `.tar.xz`, `.zip.minisig`, `.tar.xz.minisig`) from the end of the file name.
* Find the last occurrence of "-" in the file name. If that byte is followed by the string "dev", find the previous occurence of "-" instead.
* The string after that "-" byte is the Zig version.

It is strongly discouraged for checks to rely on specific architecture or OS names, since the set of targets for which tarballs are provided could be extended at any time.

## Adding A Mirror

Once a mirror complies with the requirements listed above, you can add it to the list of mirrors on ziglang.org by modifying the list in
`assets/community-mirrors.ziggy` and opening a pull request with your changes. The diff should just add a single entry to the end of the list:

```diff
 [
     {
         .url = "https://a.com",
         .username = "a",
         .email = "a@a.com",
     },
     {
         .url = "https://b.com/zig",
         .username = "b",
         .email = "b@b.com",
     },
+    {
+        .url = "https://mymirror.net",
+        .username = "my-github-username",
+        .email = "my@email.com",
+    },
 ]
```

Note that the Zig core team always reserves the right to exclude mirrors from this list for any (or no) reason.

## Community-Written Solutions

Some members of the Zig community have written software for hosting Zig mirrors, making it easier to comply with the requirements listed above. If you have an open-source repository or guide that would fit here, feel free to open a pull request adding it below.

> [!WARNING]
> The Zig Software Foundation has not written or audited this code. As such, no guarantees can be made regarding its correctness, and it should **not** be
> implicitly trusted. You are strongly encouraged to audit this software before using it, particularly if it will not be run in an isolated environment.

* [hexops/wrench](https://github.com/hexops/wrench?tab=readme-ov-file#run-your-own-ziglangorgdownload-mirror)
* [silversquirl/bunny-cdn-instructions](https://gist.github.com/silversquirl/5c8d734ce8e5712eff8126295847e99f)
