# [ldgrp.me](https://ldgrp.me)

[![Deploy Hakyll with GitHub Pages](https://github.com/ldgrp/ldgrp.github.io/actions/workflows/pages.yml/badge.svg)](https://github.com/ldgrp/ldgrp.github.io/actions/workflows/pages.yml)

My personal website built with [Hakyll][hakyll] + [Pandoc][pandoc] and [TailwindCSS][tailwind].
Hosted on [Github Pages][github-pages].

## Requirements
- GHC 9.2.4
- Cabal 3.6.2.0
- npm 8.10.0

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
# Build CSS with Tailwind CLI
npm run build 
# Alternatively use watch to automatically rebuild on change
# npm run watch
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
