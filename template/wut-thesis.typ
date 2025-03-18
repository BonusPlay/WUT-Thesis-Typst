#let abstract_page(
  abstract,
  title: block,
  keywords: str,
  lang: str,
) = {
  set par(first-line-indent: 0em)
  set text(lang: lang)
  align(center, text(size: 14pt, strong(title)))

  let a = if lang == "pl" [Streszczenie] else [Abstract]
  let k = if lang == "pl" [Słowa kluczowe] else [Keywords]

  v(0.5cm)
  [*#a*. #abstract]
  v(0.5cm)
  [*#k:* #keywords]
}

#let title_page(
  title: str,
  author: str,
  supervisor: str,
  institute: str,
  field: str,
  album: str,
  lang: str,
) = {
  // this should be Arial, but typst.app doesn't have it
  // it has Helvetica, but sometimes we should use Helvetica-Light
  set text(font: "Helvetica")

  image("eiti-" + lang + ".svg", width: 100%)

  v(3em)
  {
    set align(center)
    set text(12pt)
    [
      #let desc = if lang == "pl" [Instytut] else [Institute of]
      #desc #institute
    ]

    v(4em)
    image("mgr-" + lang + ".svg")
    v(2em)

    [
      #let desc = if lang == "pl" [na kierunku] else [in the field of]
      #desc #field
    ]

    v(4em)
    text(size: 14pt, #title)
    v(4em)

    text(size: 21pt, #author)
    linebreak()

    [
      #let desc = if lang == "pl" [Numer albumu] else [student record book number]
      #desc #album
    ]

    v(4em)
    [
      #let desc = if lang == "pl" [promotor] else [thesis supervisor]
      #desc\ #supervisor
    ]
    v(1fr)

    [WARSZAWA #datetime.today().year()]
  }
}

#let pw(
  lang: "pl",
  short_references: false,
  title,
  title_en,
  author: "",
  supervisor: "",
  institute: "",
  field: "",
  album: "133337",
  abstract,
  keywords: "",
  abstract_en,
  keywords_en: "",
  acronyms: (),
  doc
) = {
  set page(
      paper: "a4",
      margin: (
        y: 25mm,
        inside: 30mm,
        outside: 20mm,
      ),
  )
  set text(12pt, lang: lang)
  let line_spacing = 0.8em
  set par(justify: true, first-line-indent: 0.5cm, leading: line_spacing, spacing: line_spacing)
  let list_indent = 0.5cm
  set list(indent: list_indent)
  set enum(indent: list_indent)

  title_page(
    title: if lang == "pl" { title } else { title_en },
    author: author,
    supervisor: supervisor,
    institute: institute,
    field: field,
    album: album,
    lang: lang,
  )

  pagebreak(to: "odd")

  set page(numbering: "1")
  // Align number inner and outer
  set page(footer: context {
    let (n,) = counter(page).get()
    set align(if calc.even(here().page()) { left } else { right })
    counter(page).display(page.numbering)
  })

  set heading(numbering: "1.")
  // Header chapter display
  set page(header: context {
    let selector = heading.where(level: 1).before(here())
    let headings = query(selector)

    let heading_here = query(heading.where(level: 1)).find(it => it.location().page() == here().page())
    if not heading_here == none or headings.len() == 0 {
      return
    }

    let hing = headings.last()

    counter(selector).display(heading.numbering)
    h(1em)
    hing.body
    v(-0.1em)
    line(length: 100%)
  })

  // Caption above table
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  // Padding above and below image
  show figure: it => {v(1em); it; v(1em)}

  // Short abriviations
  show figure.where(kind: raw): set figure(supplement: [Listing])
    show ref.where(
      form: "normal"
    ): set ref(supplement: it => {
      if short_references {
          if it.kind == image {
            if lang == "pl" [Rys.] else [Fig.]
          } else if it.kind == table {
            "Tab."
          } else {
            it.supplement
          }
      } else {
        it.supplement
      }
    })

  abstract_page(
    abstract,
    title: title,
    keywords: keywords,
    lang: if lang == "pl" { "pl" } else { "en" }
  )
  pagebreak()

  abstract_page(
    abstract_en,
    title: title_en,
    keywords: keywords_en,
    lang: if lang == "pl" { "en" } else { "pl" },
  )
  pagebreak()

  {
    // Include in context to prevent pagebreaks after doc
    show heading.where(level: 1): it => {pagebreak(weak: false); text(14pt)[#it] ; par[]}
    show heading.where(level: 2): it => {v(0.5cm); text(13pt)[#it]; par[]}
    show heading.where(level: 3): it => {text(12pt)[#it]; par[]}
    show outline.entry.where(level: 1): it => [*#it*]
    outline(depth: 3)

    doc
    pagebreak()
  }

  if acronyms.len() > 0 {
    let h = if lang == "pl" [Wykaz symboli i skrótów] else [List of Symbols and Abbreviations]
    heading(h, numbering: none)
    acronyms.sorted().map(it => [*#it.at(0)* - #it.at(1)]).join(linebreak())
  }
  context if query(selector(figure.where(kind: image))).len() > 0 {
    let h = if lang == "pl" [Spis rysunków] else [List of Symbols and Abbreviations]
    outline(target: figure.where(kind: image), title: [List of Figures])
  }
  context if query(selector(figure.where(kind: table))).len() > 0 {
    let h = if lang == "pl" [Spis tabel] else [List of Tables]
    outline(target: figure.where(kind: table), title: h)
  }
  context if query(selector(figure.where(kind: raw))).len() > 0 {
    let h = if lang == "pl" [Spis listingów] else [Listings]
    outline(target: figure.where(kind: raw), title: h)
  }
}
