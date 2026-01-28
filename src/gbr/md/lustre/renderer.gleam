////
//// Lustre renderer from markdown content
////

import gleam/list
import gleam/option.{None, Some}

import lustre/attribute as a
import lustre/element as e
import lustre/element/html as h

import mork
import mork/document

/// Render markdown content into lustre element represetation.
///
/// - markdown: Markdown file content.
///
pub fn render(markdown: String) -> e.Element(a) {
  let doc = mork.parse(markdown)
  let attrs = [
    a.class("prose prose-stone dark:prose-invert max-w-none"),
  ]
  let inner =
    doc.blocks
    |> list.map(render_block(_, doc))

  h.div(attrs, inner)
}

// PRIVATE
//

fn render_block(block: document.Block, doc: document.Document) -> e.Element(a) {
  case block {
    document.Heading(level, _, _, inlines) -> {
      let content = list.map(inlines, render_inline)
      case level {
        1 -> h.h1([], content)
        2 -> h.h2([], content)
        3 -> h.h3([], content)
        4 -> h.h4([], content)
        5 -> h.h5([], content)
        _ -> h.h6([], content)
      }
    }

    document.Paragraph(_, inlines) -> {
      h.p([], list.map(inlines, render_inline))
    }

    document.Code(lang_opt, content) -> {
      let lang_class = case lang_opt {
        Some(l) -> "language-" <> l
        None -> "language-text"
      }
      h.pre([a.class(lang_class)], [
        h.code([], [e.text(content)]),
      ])
    }

    document.BlockQuote(blocks) -> {
      h.blockquote([], list.map(blocks, render_block(_, doc)))
    }

    document.BulletList(_, items) -> {
      h.ul([], list.map(items, render_list_item(_, doc)))
    }

    document.OrderedList(_, items, _) -> {
      h.ol([], list.map(items, render_list_item(_, doc)))
    }

    document.ThematicBreak -> h.hr([])

    // Fallback for not yet implemented blocks
    _ -> e.none()
  }
}

fn render_list_item(
  item: document.ListItem,
  doc: document.Document,
) -> e.Element(msg) {
  let document.ListItem(blocks, _, _) = item
  h.li([], list.map(blocks, render_block(_, doc)))
}

fn render_inline(inline: document.Inline) -> e.Element(msg) {
  case inline {
    document.Text(text) -> e.text(text)
    document.Strong(inlines) -> h.strong([], list.map(inlines, render_inline))
    document.Emphasis(inlines) -> h.em([], list.map(inlines, render_inline))
    document.CodeSpan(text) -> h.code([], [e.text(text)])

    document.FullLink(text, data) -> {
      let href = case data.dest {
        document.Absolute(uri) -> uri
        document.Relative(uri) -> uri
        document.Anchor(uri) -> "#" <> uri
      }
      h.a([a.href(href), a.target("_blank")], list.map(text, render_inline))
    }

    // Fallback
    _ -> e.none()
  }
}
