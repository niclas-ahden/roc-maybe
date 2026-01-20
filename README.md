# Maybe

A package for working ergonomically with optional values in Roc. The `Maybe` type represents a value that may or may not exist.

Note that Roc has a great type system and using descriptive [tag unions](https://www.roc-lang.org/tutorial#tag-union-types), [tags with payloads](https://www.roc-lang.org/tutorial#tags-with-payloads), and/or `Result` is usually preferable to `Maybe`. If you're new to Roc I encourage you to explore those options first. If you still want a `Maybe`: enjoy!

## Example usage

```roc
app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    maybe: "https://github.com/niclas-ahden/roc-maybe/releases/download/0.1.0/9_PIjOoSLU-EjE8tpApdDXIk1zlSwEqBewRuxJ0FIx8.tar.br",
}

import pf.Stdout
import maybe.Maybe exposing [Maybe]

Person : {
    name : Str,
    hobby : Maybe Str,
}

search_your_soul : Person -> Str
search_your_soul = |person|
    actual_hobby =
        person.hobby
        |> Maybe.map(|hobby| "${hobby} and Diablo II")
        |> Maybe.with_default("Diablo II")

    "${person.name} enjoys ${actual_hobby}"

main! = |_|
    people = [
        { name: "Alice", hobby: Just("Red wine") },
        { name: "Bob", hobby: Just("Charcuterie") },
        { name: "Charlie", hobby: Nothing },
    ]

    people
    |> List.map(search_your_soul)
    |> List.for_each_try!(Stdout.line!)
```

This example demonstrates a combination of `Maybe` and exceptional taste. Run it like so `roc dev examples/basic.roc`.

## JSON encoding/decoding

Want to JSON encode/decode your `Maybe`? Use `Maybe.to_option` to get an `Option` from [`roc-json`](https://github.com/lukewilliamboswell/roc-json/) and you're set. `Option` is an [opaque type](https://roc-lang.org/tutorial#opaque-types) which makes it slightly less ergonomic to use, so I tend to work with `Maybe` until I get to a point where I need JSON encoding/decoding and convert to/from at that boundary.

## Documentation

View the full API documentation at [https://niclas-ahden.github.io/roc-maybe/](https://niclas-ahden.github.io/roc-maybe/).

### Generating documentation locally

To generate documentation for a specific version:

```bash
./docs.sh 0.1.0
```

This will:
1. Generate HTML documentation from the Roc module.
2. Place it in `www/0.1.0/`.
3. You can then open `www/0.1.0/index.html` in your browser.

### Publishing documentation

Documentation is automatically deployed to GitHub Pages when triggered manually:

1. Generate the docs locally using `./docs.sh VERSION`.
2. Commit and push the changes to `www/`.
3. Go to the GitHub Actions tab in the repository.
4. Run the "Deploy static content to Pages" workflow manually.
5. Your docs will be published at `https://niclas-ahden.github.io/roc-maybe/VERSION/`.
