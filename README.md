[![Package Version](https://img.shields.io/hexpm/v/gbr_md_lustre)](https://hex.pm/packages/gbr_md_lustre)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gbr_md_lustre/)

#️ Ⓜ️ Gleam library convert markdown to lustre elements

Convert markdown content into lustre elements.

This accecpt metadata into markdown, format:

```md
---
title: Gleam programming
description: Gleam first programming lines
date: 2025-09-15
slug: gleam-programming
tags: [gleam, programming, beginner]
---

# Header 01

Content **here**!

- List
  - [ ] List 1
  - [ ] List 2
  - [ ] List 3
```

## 🌄 Roadmap

- [ ] Unit tests
- [ ] More docs
- [ ] GH workflow
  - [ ] test & build
  - [ ] changelog & issue to doc
  - [ ] ~~auto publish~~ manual publish
    - [ ] `gleam publish`
    - [ ] `npm publish`
- [ ] Create id or class to each lustre element render.
- [ ] How make metada dynamic from user ( now is hardcode )
  - [ ] Parse metadata content like yaml or json
- [ ] How make stream parsing markdown contents
- [ ] Create metadata by json_schema

## Run

```sh
gleam add gbr_md_lustre@1
```

```gleam
import gbr/md

pub fn main() -> Nil {
  let raw =
    "---
title: Programação Deflacionária
date: 2025-09-15
slug: programming-deflation
tags: [ai, economy]
---
# Introdução
O código está ficando mais barato."

  let result =
    raw
    |> md.new()
    |> md.metadata(md.Frontmatter)

  result |> should.be_ok
  let assert Ok(md.Markdown(metadata:, ..)) = result

  metadata |> should.be_some
  let assert Some(metadata) = metadata

  let result = {
    use #(key, _) <- list.find(metadata)

    key == "title"
  }

  result |> should.be_ok
  let assert Ok(#(_, value)) = result
  value |> should.equal("Programação Deflacionária")

  let result = {
    use #(key, _) <- list.find(metadata)

    key == "slug"
  }

  result |> should.be_ok
  let assert Ok(#(_, value)) = result
  value |> should.equal("programming-deflation")
}
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
