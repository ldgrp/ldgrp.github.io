---
title: Dynamic timers in recipes for mobile
date: 2022-09-29
last-edited: 2022-11-12
status: todo
tags: recipe
---

Web push notifications are [coming to iOS 16][web-push]. Recipes often contain instructions like

- boil pasta for 10 minutes
- bake for 2 hours
- brew for 2 minutes 40 seconds

It would be nice to be able to dynamically detect these times, and show a button on hover allowing
the user to start a timer. When the timer is done, they should receive a push notification on their phone.

[web-push]: https://9to5mac.com/2022/06/06/ios-16-web-push-notifications-safari-update/