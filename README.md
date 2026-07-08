# [ldgrp.me](https://ldgrp.me)

[![Deploy Hakyll with GitHub Pages](https://github.com/ldgrp/ldgrp.github.io/actions/workflows/pages.yml/badge.svg)](https://github.com/ldgrp/ldgrp.github.io/actions/workflows/pages.yml)

My personal website built with [Hakyll][hakyll] + [Pandoc][pandoc] and [TailwindCSS][tailwind].
Hosted on [Github Pages][github-pages].

## Requirements

Tooling (GHC, Cabal, and the standalone Tailwind CLI) is managed by
[mise](https://mise.jdx.dev/).

```bash
mise install
```

## Build

```bash
cabal clean
cabal update
# Build the site package
cabal build
# Run the Hakyll site build
cabal exec site build 
# Alternatively use watch to automatically rebuild on change
# cabal exec site watch
```

```bash
# Build CSS with the Tailwind CLI
tailwindcss -i css/input.css -o css/style.css
# Alternatively use watch to automatically rebuild on change
# tailwindcss -i css/input.css -o css/style.css --watch
```

### Windows: withFile: invalid argument (invalid character)

Fix: Change PowerShell's default encoding to UTF-8
```powershell
$outputencoding=[console]::outputencoding=[console]::inputencoding=[text.encoding]::utf8
```
[hakyll]: https://jaspervdj.be/hakyll
[pandoc]: https://pandoc.org/
[tailwind]: https://tailwindcss.com/
[github-pages]: https://pages.github.com/
