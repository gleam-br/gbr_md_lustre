////
//// Unit tests to markdown converter to lustre elements
////

import gleam/list
import gleam/option.{Some}
import gleeunit
import gleeunit/should

import gbr/md
import gbr/md/metadata/frontmatter

/// Run gleeunit
///
pub fn main() -> Nil {
  gleeunit.main()
}

// 1. Test extract frontmatter
pub fn extract_frontmatter_test() {
  let content =
    "---
title: Meu Post
date: 2026-01-23
---
Corpo do post"

  frontmatter.extract(content)
  |> should.be_ok
  |> should.equal(#("title: Meu Post\ndate: 2026-01-23", "Corpo do post"))
}

// 2. Test validate required fields
pub fn missing_title_test() {
  let yaml = "date: 2026-01-23\nslug: post-erro"

  frontmatter.parse_yaml(yaml)
  |> should.be_error
  |> should.equal(frontmatter.MissingRequiredField("title"))
}

pub fn missing_date_test() {
  let yaml = "title: Post Sem Data\nslug: post-sem-data"

  frontmatter.parse_yaml(yaml)
  |> should.be_error
  |> should.equal(frontmatter.MissingRequiredField("date"))
}

// 3. Test integrate (complete flow)
pub fn full_parse_test() {
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
