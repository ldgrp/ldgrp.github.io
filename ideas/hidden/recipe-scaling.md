---
title: Dynamic scaling of ingredients
date: 2022-11-11
last-edited: 2022-11-12
status: todo
tags: recipe
---

Baking often requires precise measurements when it comes to ingredients.
I find myself doing arithmetic in these scenarios:

- unit conversions (temperature and mass <--> volume)
- scaling recipes by a constant factor
- scaling recipes by an ingredient
  * Example: I have a recipe for bread that requires 2500g of flour, but I only have 2000g.

I want to dynamically create some rules that capture data via regex. For example,

```js
text = "2500g of flour"
weightRegex = /(\d+)\s?(g)/

```

and parse the captured data `[value: 2000, unit: g]` into a table. Then, some [Airtable-like UI][airtable] should exist
allowing me to arbitrarily transform the captured data. I should be able to
replace the text in the ingredients list and the recipe text.

| value | unit | scaledValue |
|-------|------|-------------|
| 2500  | g    | 1000        |

[airtable]: https://support.airtable.com/docs/writing-formulas-in-excel-vs-airtable#airtable