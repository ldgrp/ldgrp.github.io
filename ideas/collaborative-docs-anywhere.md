---
title: Make any text input collaborative
last-edited: 2022-11-12
date: 2022-09-09
status: TODO
tags: chrome-extension, collaborative
---

This is a common workflow for collaboratively writing task/story descriptions in JIRA
  
- The team wants to fill in the details
- Person A starts sharing their screen
- Group discussion begins
- As details are ironed out, someone, let's call them Person B, will want Person A to write down what they're saying
- Person C comes up with a refinement. They will now ask Person A to change the wording
- Ad infinitum

There are many parallel streams of thought that are being aggregated by a single collector.
This slows everyone down unnecessarily because the collector can only deal with a single stream of thought at
any given time.

One solution is to ask Atlassian to make the JIRA description field support real-time collaboration,
but that will likely never happen. Another solution is to Do It Yourself.

- Given any text input on a page, a user can click on a Chrome extension to make it collaborative
- The extension will get the current value of the text input and open a new window
- The window has a real-time collaborative editor where the user can invite other people
- After everything is done, the original user can "send" the edited document back to the text input.

### Notes
- Yes, you _can_ just use Google Docs but where's the fun in that?
- It is extremely likely that we are using the wrong tool for the job.
- There are many ways to do rich text editing so it is unlikely to be supported
- There are some really cool plug-and-play solutions for real-time collaborative editing
    - [Tiptap][tiptap]
    - [Yjs][yjs] has bindings for [CodeMirror][yjs-codemirror], [ProseMirror][yjs-prosemirror], and [more][yjs-more]

[tiptap]: https://tiptap.dev/
[yjs]: https://yjs.dev/
[yjs-prosemirror]: https://github.com/yjs/y-prosemirror
[yjs-codemirror]: http://github.com/yjs/y-codemirror
[yjs-more]: https://github.com/yjs/yjs#bindings