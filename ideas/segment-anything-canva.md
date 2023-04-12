---
title: Segment Anything as a Canva App
last-edited: 2023-04-08
date: 2023-04-06
status: todo
tags: design
---

Canva is quite proud of their background removal feature.

Meta has recently come out with [Segment Anything Model][segment-anything] which
allows you to "cut out any object, in any image, with a single click".

Their demo is quite impressive and allows for a similar UX to Apple's
[lift a subject from the photo background][apple-ux] feature. (Note that this is just one
example of what the model can do.)

I think it would be interesting to see if we can make a Canva app that is a
_better_ version of Canva's background removal feature using the Segment Anything model.
Although I'm not sure if this is currently possible with their [developer API][developer-api].

Some features it could have

- Offer all segmentation options (not just foreground/background). This would
  allow users to choose from all discovered regions in the image.
- Allow users to input a prompt and have the model generate a segmentation
  based on the prompt.

[apple-ux]: https://support.apple.com/en-au/guide/iphone/iphfe4809658/ios
[segment-anything]: https://segment-anything.com
[developer-api]: https://canva.dev