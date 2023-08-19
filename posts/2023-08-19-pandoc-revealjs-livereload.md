---
title: Live-reloading Pandoc + Reveal.js
date: 2023-08-19
last-edited: 2023-08-19
---

I've been using markdown + [pandoc][pandoc] + [reveal.js][revealjs] to create presentations at work.

Pandoc doesn't have a live-reload feature so I wrote a small script that watches
for changes in the markdown file and recompiles the presentation.

## fswatch

I decided to use [fswatch][fswatch] to listen for changes in the markdown file.

```bash
fswatch -0 presentation.md | xargs -0 -I {} sh -c "pandoc --to revealjs -s --output presentation.html {}"
```

- `fswatch -0` watches for changes in the markdown file and outputs
the name of the file that changed followed by the null character.
- `xargs -0` reads null-terminated lines from stdin.
- `xargs -I {}` replaces `{}` in the following command with the input.
- `pandoc --to revealjs -s --output presentation.html {}` compiles the markdown file
to reveal.js.

This gets us compile-on-save, but we still need to refresh the browser to see
the changes.

## Websockets

We can extend the script to start a websocket server that sends a message to the
browser when the markdown file changes.

I used [websocat][websocat] to start the websocket server from the command line.

```bash
fswatch -0 presentation.md | xargs -0 -I {} sh -c "pandoc --to revealjs -s --output presentation.html {} && echo reload" | websocat -s 56789
```

- `echo reload` is sent to stdout after the markdown file is compiled.
- `websocat -s 56789` starts a websocket server on port 56789.

The echo message is piped to websocat.

### Browser

Pandoc supports YAML frontmatter in markdown files. The `header-includes` field
can be used to include arbitrary HTML in the `<head>` tag of the generated HTML.

```yaml
---
title: My presentation
header-includes: |
  <script>
    function connect() {
      const ws = new WebSocket("ws://localhost:56789");
      ws.onopen = () => setTimeout(() => ws.send("keepalive"), 30000);
      ws.onclose = () => setTimeout(connect, 1000);
      ws.onmessage = () => location.reload();
    }
    connect();
  </script>
---
```

This script connects to the websocket server and reloads the page when it receives
any message. A keepalive message is sent every 30 seconds to keep the connection
alive. When the connection is closed, the script tries to reconnect every second.

This is a *really* cursed hack but it got me up and running with the tools
I already had.


[fswatch]: https://emcrisostomo.github.io/fswatch/
[pandoc]: https://pandoc.org/
[revealjs]: https://revealjs.com/
[websocat]: https://github.com/vi/websocat