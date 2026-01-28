////
//// Frontmatter is parser formatter to markdown metadata with:
////
//// > You can use this to dev personal blog posts.
////
//// - title: Title of markdown document.
//// - description: Description of markdown document.
//// - slug: Html slug representation,e.g., "gleam-first-programming".
//// - tags: List tags of markdown document.
////   - Handles format like "[tag1, tag2]" or "tag1, tag2"
//// - date: Created at.
////

import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

/// Frontmatter metadata type
///
/// - title: Title of markdown document.
/// - description: Description of markdown document.
/// - slug: Html slug representation,e.g., "gleam-first-programming".
/// - tags: List tags of markdown document.
///   - Handles format like "[tag1, tag2]" or "tag1, tag2"
/// - date: Created at.
///
pub type Frontmatter {
  Frontmatter(
    title: String,
    date: String,
    slug: String,
    tags: List(String),
    description: Option(String),
  )
}

/// Frontmatter error
///
pub type FrontmatterError {
  NoFoundMetadata
  MissingRequiredField(String)
}

/// Extract metadata and body from markdown content
///
/// - markdown: Markdown content
///
/// Result:
///
/// - let #(metadata, body) = result
///
pub fn extract(markdown: String) -> Result(#(String, String), FrontmatterError) {
  let content = string.replace(markdown, "\r\n", "\n")
  case string.split(content, "---") {
    ["", yaml, ..rest] -> {
      let body = string.join(rest, "---")
      Ok(#(string.trim(yaml), string.trim(body)))
    }
    _ -> Error(NoFoundMetadata)
  }
}

/// Extract frontmatter and body from markdown content
///
/// - markdown: Markdown content
///
/// Result:
///
/// - let #(frontmatter, body) = result
///
pub fn parse(
  markdown: String,
) -> Result(#(Frontmatter, String), FrontmatterError) {
  use #(yaml, body) <- result.try(extract(markdown))
  use fm <- result.try(parse_yaml(yaml))

  Ok(#(fm, body))
}

/// Parse yaml key/value frontmatter format.
///
/// - yaml: Frontmatter content.
///
pub fn parse_yaml(yaml: String) -> Result(Frontmatter, FrontmatterError) {
  let lines = string.split(yaml, "\n")
  let key_values = list.filter_map(lines, parse_line)

  // Lucid Systems: Explicit validation for required fields
  use title <- result.try(
    list.key_find(key_values, "title")
    |> result.replace_error(MissingRequiredField("title")),
  )

  use date <- result.try(
    list.key_find(key_values, "date")
    |> result.replace_error(MissingRequiredField("date")),
  )

  use slug <- result.try(
    list.key_find(key_values, "slug")
    |> result.replace_error(MissingRequiredField("slug")),
  )

  let tags = case list.key_find(key_values, "tags") {
    Ok(tags_str) -> parse_tags(tags_str)
    Error(_) -> []
  }

  let description =
    list.key_find(key_values, "description")
    |> option.from_result

  Ok(Frontmatter(title, date, slug, tags, description))
}

/// Convert frontmatter type to markdown generic metadata.
///
/// - in: Frontmatter type
///
pub fn metadata(in: Frontmatter) -> List(#(String, String)) {
  let Frontmatter(title:, date:, slug:, tags:, description:) = in

  [
    #("title", title),
    #("date", date),
    #("slug", slug),
    #("tags", string.join(tags, ",")),
  ]
  |> list.append(
    description
    |> option.map(fn(d) { [#("description", d)] })
    |> option.unwrap([]),
  )
}

// PRIVATE
//

fn parse_line(line: String) -> Result(#(String, String), Nil) {
  // Simple key: value parser
  case string.split_once(line, ":") {
    Ok(#(key, value)) -> Ok(#(string.trim(key), string.trim(value)))
    Error(_) -> Error(Nil)
  }
}

fn parse_tags(tags_str: String) -> List(String) {
  // Handles format like "[tag1, tag2]" or "tag1, tag2"
  tags_str
  |> string.replace("[", "")
  |> string.replace("]", "")
  |> string.replace("\"", "")
  // Remove quotes if present
  |> string.split(",")
  |> list.map(string.trim)
  |> list.filter(fn(t) { t != "" })
}
