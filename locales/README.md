# Language packs

The words the PDX workspace shows, per language.

> **Draft — not in use yet.** PDX is English only today. No release reads these files, no language can be selected,
> no check exists as a command, and the message files do not exist yet. `ko` and `ja` are listed as drafts; they are
> not supported languages.
>
> This page has two parts. [The file format](#the-file-format) is what these files are. [Planned
> behaviour](#planned-behaviour) is what PDX is required to do with them before any language ships — requirements,
> not something a release does today.

## Layout

```
locales/
├── README.md              this file
├── index.json             which locales and namespaces take part
├── schemas/               the JSON Schemas of every file here
├── en/                    the source locale — generated from PDX's source; not edited here
│   ├── meta.json
│   ├── ui.json            (not published yet)
│   ├── modules.json       (not published yet)
│   └── terms.json         (not published yet)
├── ko/                    a translation
│   ├── meta.json
│   ├── ui.json            (not started)
│   ├── modules.json       (not started)
│   ├── terms.json         (not started)
│   └── reviews.json       (maintainers; appears with the first approval)
└── ja/
    └── …
```

| file | holds | who writes it |
| --- | --- | --- |
| `index.json` | the source locale, the message format, the namespaces, the locale directories | maintainers |
| `<tag>/meta.json` | the language's name, direction, status and fallback | maintainers |
| `en/<namespace>.json` | the source messages: text, arguments, context for translators | generated; a pull request that edits it is declined |
| `<tag>/<namespace>.json` | the translations | translators, by pull request |
| `<tag>/reviews.json` | approvals of the messages a person decides on | maintainers only |

What is **not** here: translated documents go to `docs/<tag>/`; translations of the licence are separate and are
never the governing text. A file whose name contains `.local` belongs to one computer and is never committed here
([Where a pack lives](#where-a-pack-lives)).

## The file format

Every file has a `schema` number and a JSON Schema under `schemas/`.

### Locale tags

A directory's name is a [BCP 47](https://www.rfc-editor.org/info/bcp47) tag of this subset: a language, then
optionally a script, then optionally a region — `ko`, `en`, `ja`, `zh-Hant`, `pt-BR`, `es-419`, `zh-Hant-TW`.
Variants and extensions are not supported. The tag is the canonical one of the IANA registry (`he`, not `iw`), and
carries a script or a region only when the text really differs: `ko`, not `ko-KR`.

A locale other than the source names its `fallback` in `meta.json`. The fallback is chosen explicitly — nothing is
derived by cutting a tag short. Every chain ends at the source locale and has no cycle.

### Message files

One file per namespace. A namespace is a part of the product (`ui`, `modules`) or the glossary (`terms`, below).
The names `meta` and `reviews` are reserved for the files of those names.

The source, `en/modules.json`:

```json
{
  "schema": 1,
  "locale": "en",
  "namespace": "modules",
  "messages": {
    "home.compact.rowCounts": {
      "value": "{reports, plural, one {# report} other {# reports}} · {waiting, number} waiting on you",
      "args": { "reports": "integer", "waiting": "integer" },
      "context": "Compact work card: number of reports, number of items waiting on the person."
    }
  }
}
```

A translation, `ko/modules.json`:

```json
{
  "schema": 1,
  "locale": "ko",
  "namespace": "modules",
  "messages": {
    "home.compact.rowCounts": {
      "value": "보고 {reports, number}건 · 내 확인 대기 {waiting, number}건",
      "sourceHash": "574d212b392b99b90b0740e20bfc0198f4b1fca6e25c1ad0d7f056ab8dd385f8"
    }
  }
}
```

The arguments, their types, the context and the review marks belong to the source. A translation holds only its
text and the hash of the source message it was written against. Keys are sorted; files carry no timestamps.

### Message ids

An id names what a message **means** (`home.compact.rowCounts`), inside its namespace. It is not a path into PDX's
source code and does not change when that code is reorganized.

- An id is never reused for a different meaning.
- When a meaning changes, a new id is added and the old one is marked `deprecated` in the source, with `replacedBy`
  when it has a successor.
- A deprecated id is removed in a later catalog.

### The glossary — `terms`

PDX has words of its own — *Work Contract*, *Evidence*, *Gate*. Whether such a word is translated or kept in
English is decided once per language, not message by message. The namespace `terms` holds them: each term is a
message whose `value` is the English term and whose `context` explains it.

A language's `terms.json` has the shape of any translation. Each entry supplies the term's rendering. A value
equal to the English term preserves that spelling; schema 1 does not distinguish keeping English from a translation
with identical spelling. Ordinary messages use the effective glossary rendering.

### Message syntax — `icu-mf1-text-v1`

> The profile is a draft until the first source catalog is published, and is frozen from that publication. After
> that it is not redefined: a change is a new `format` name.

Messages are [ICU MessageFormat](https://unicode-org.github.io/icu/userguide/format_parse/messages/) version 1,
restricted to plain text.

| construct | form | notes |
| --- | --- | --- |
| argument | `{name}` | |
| number | `{n, number}` · `{n, number, integer}` | no other style, no skeleton |
| date, time | `{d, date, short}` — `short` · `medium` · `long`; the same for `time` | the style is required |
| plural | `{n, plural, one {# item} other {# items}}` | the categories of **the translation's own language**; exact matches (`=0`) allowed; `offset:` is not |
| select | `{mode, select, month {…} week {…} other {…}}` | only over the values the source declares for that argument |

- **Not in the profile:** `selectordinal`, custom formatters, and markup of any kind — a `<` is a `<`.
- **Apostrophes** follow ICU's `DOUBLE_OPTIONAL` rule: U+0027 starts quoting before `{` or `}`, or before `#` only
  in a message immediately inside a `plural`. A doubled U+0027 produces one literal apostrophe, including within
  quoted text. Quoting ends at the next undoubled U+0027, or at the end of the pattern. Anywhere else an apostrophe
  is literal.
- **Depth:** a `plural` or `select` may hold one further `plural` or `select`, not more.
- Every `plural` and `select` has an `other` branch. An empty branch (`other {}`) is allowed.
- A translation may reorder arguments and may use plural categories the source does not. It may not use an argument
  the source does not declare.
- A list of names is formatted in the resolved message's locale and supplied as one argument of type `list`. Plural
  rules and `#` also use that resolved locale.

### `sourceHash`

`sourceHash` is the SHA-256, in lowercase hexadecimal, of the UTF-8 bytes of the
[JSON Canonicalization Scheme (RFC 8785)](https://www.rfc-editor.org/rfc/rfc8785) form of exactly this object,
built from the source message:

```json
{ "value": value, "args": args or {}, "context": context or "", "review": review or "", "group": group or "" }
```

No Unicode normalization is applied; there is no byte order mark and no trailing newline; an `enum` array keeps its
order. For the source message shown above the canonical form begins `{"args":{"reports":"integer",` and the hash is
the one in the Korean example.

When the English text, its arguments, its context or its review marks change, the hash changes, and every
translation of that message is **stale** until a translator looks at it again and updates the hash.

A namespace's **catalog digest** is the SHA-256 of the RFC 8785 form of the whole source file.

### Approvals — `reviews.json`

A source message marked `"review": "security"` is one a person decides on: a consent, a security prompt, an
authorization of an external effect. A syntax check cannot tell that a translation inverted its meaning; a person
who reads both languages can. Such an approval is recorded by a maintainer in `<tag>/reviews.json`, keyed
`<namespace>:<id>`, with the `sourceHash` and the SHA-256 of the translated text. It is void as soon as either no
longer matches. Translators do not edit this file.

### Extending the format

- More source text is more message ids, not a second text field on a message.
- A new field on a message or in a metadata file is a new `schema` number with a new schema file; whether the field
  takes part in `sourceHash` is said when it is added.
- The old shape stays readable at the tags that used it.

## Planned behaviour

Requirements on PDX and on the check that will accept translations. **None of this is implemented.**

### Where a pack lives

Repository message files use the schemas published here. Local data is stored separately, in one `pack.local.json`
per language; its storage format is not published here. Within each locale, PDX will choose the first valid,
appropriately approved entry from local, downloaded, then included data, before following the fallback chain to the
release's English source:

| layer | where | written by |
| --- | --- | --- |
| **local** | on the person's computer, in one file per language named `pack.local.json` | that computer only: the person's own wording, and translations their AI made for the screens they opened |
| **downloaded** | on the person's computer | a download from this repository — only when the person has turned downloads on |
| **included** | built into the release | the release, from this directory at a pinned commit |
| **source** | the release's own English catalog | PDX's source |

The local layer is the main one: within a locale selected by the resolution and group rules, a valid local entry
with any required approval takes precedence over downloaded and included entries. A download replaces the downloaded
layer as a whole and never touches a `.local` file.

A person will be able to export valid local entries that are new or different from the included and downloaded
layers, together with their term translations, as ordinary per-namespace translation files containing `value` and
`sourceHash`. The person opens the pull request; maintainer approvals are not exported. PDX uploads nothing.

### Resolution and fallback

A message falls back only when no layer of the locale supplies a valid entry with any required approval. Each
member of a `group` (a prompt and its buttons) resolves local → downloaded → included within one locale; if any
member remains unresolved, the whole group tries the next fallback locale — never half-translated. Plural rules use
the resolved locale.

### Whose approval counts

A maintainer's approval in `reviews.json` counts only where PDX can tell the file is the repository's: in the
included layer, and in a downloaded file whose bytes match what PDX recorded when it fetched it. A copied file with
an approval beside it is not trusted. A translation made on the person's own computer — by them or by their AI — of
a message marked `"review": "security"` is shown only after that person has accepted it.

**Coverage** is not written by hand anywhere. It is counted from the messages that are present, valid, not stale
and, where review is required, approved.

**The check** refuses:

- a file that does not match its schema; a duplicate key at any level (found before parsing); an id the source does
  not have;
- a locale directory that `index.json` does not list or the reverse; a `tag` that differs from its directory; a tag
  that is not canonical; a fallback that is missing, unknown or cyclic;
- an `index.json` whose `source` is not among its `locales`, or any locale other than exactly that one with the
  status `source`; a message or review file whose `locale` differs from its directory; a message file whose
  `namespace` differs from its file name or is not in `index.json`;
- a message outside the `icu-mf1-text-v1` profile; an argument the source does not declare, or one used against its
  declared type; a required argument dropped from a branch where the source shows it;
- any control character other than a line feed; the bidirectional controls U+061C, U+200E, U+200F, U+202A–U+202E and
  U+2066–U+2069;
- a file whose name contains `.local`;
- anything over the initial budgets: a file of 4 MiB; 20,000 messages in a file; a translated `value` of 4,000
  characters, or of four times the English plus 40; a formatted result of 8,000 characters; 16 MiB for all the files
  of one language.

**Rendering.** A message is rendered as text only and is never interpreted as markup or code — no `eval`, no
callbacks. Pack data embedded in an HTML file is escaped for that serialization context. A substituted value is opaque data; names and paths are placed in direction-isolated containers by the
renderer, not by the translation. Layouts are tested with long strings and with a right-to-left language before one
ships.

**Releases.** The packs a release includes are built into it from this directory at a pinned commit, and the
release names the locales it includes, each catalog digest, and the interpreter and locale-data versions it was
built with. Binding these to a release's signed record is part of the release work and is not claimed here.

**Downloads.** Off unless a person turns them on. When enabled, PDX will fetch `index.json`, the language's
`meta.json`, its namespace files, and `reviews.json` when present, on the person's request or when they change the
display language. PDX will upload no local translations or approvals.

Every downloaded file will be checked, and each entry will be evaluated against the reading release's catalog. An
entry is stale when its `sourceHash` differs from that release's hash for the message; a different catalog alone
does not make it stale. Unusable entries are skipped according to the layer and group resolution rules. Matching
hashes do not replace validation or required approval. This is what lets the repository move ahead of, or lag
behind, an installed release.

## Changing things later

| to | do |
| --- | --- |
| add a language | add `<tag>/meta.json` with `"status": "draft"` and its `fallback`; add the tag to `index.json` |
| add a namespace | add its name to `index.json`; the source file arrives generated |
| translate | edit `<tag>/<namespace>.json`: one entry per id, `value` and `sourceHash` — by hand, or from PDX's export of local work |
| decide a term | add an entry in `<tag>/terms.json` with the desired rendering, including the English spelling when appropriate |
| change an English text | not here — it changes in PDX's source and arrives generated |
| change a file's shape | a new `schema` number and a new file under `schemas/` |
| change the message syntax | a new `format` name in `index.json` |

## Not decided yet

- When the English source catalog is first published, and with it the check as a command you can run.
- Which languages the first localized release offers.
- Whether a source message publishes the list of glossary terms it uses (a new `schema` number, by the rule above).
- Localized command-line messages (`pdx --help`, refusals): later, in a namespace of their own.
