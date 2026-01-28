////
//// Ⓜ️ Markdown to lustre elements
////

import gleam/option.{type Option, None, Some}

import lustre/element

import gbr/md/lustre/renderer
import gbr/md/metadata/frontmatter

/// Markdown type
///
/// - metadata: Metadata from markdown, if exists.
/// - body: Rest of markdown.
///
pub type Markdown {
  Markdown(metadata: Option(List(#(String, String))), body: String)
}

/// Metadata type to markdown
///
/// - Json
/// - Yaml
/// - Frontmatter
///
pub type Metadata {
  Json
  Yaml
  Frontmatter
}

/// Create new markdown type
///
/// - markdown: Markdown content.
///
pub fn new(markdown: String) -> Markdown {
  Markdown(metadata: None, body: markdown)
}

/// Parse metadata from markdown new type.
/// The body of markdown should has all content.
///
/// - in: Markdown type with all content in body.
/// - parser: Option parsert to metadata.
///
pub fn metadata(in: Markdown, parser: Metadata) -> Result(Markdown, String) {
  case parser {
    Frontmatter -> frontmatter(in.body)
    // todo
    _ -> Error("Not implemented yet.")
  }
}

// PRIVATE
//

/// Markdown content to markdown type with frontmatter metadata format.
///
/// - markdown: Markdown content.
///
fn frontmatter(markdown: String) {
  case frontmatter.parse(markdown) {
    Ok(#(metadata, body)) -> {
      let metadata =
        frontmatter.metadata(metadata)
        |> Some()

      Markdown(metadata:, body:)
      |> Ok()
    }
    Error(err) ->
      case err {
        frontmatter.NoFoundMetadata ->
          Markdown(metadata: None, body: markdown)
          |> Ok()
        frontmatter.MissingRequiredField(field) ->
          Error("Missing field: " <> field)
      }
  }
}

/// Convert markdown content into view with lustre element.
///
/// - in: Markdown type
///
pub fn view(in: Markdown) -> element.Element(a) {
  // todo how make this better
  renderer.render(in.body)
}
