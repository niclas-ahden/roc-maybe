# Maybe

A package for working ergonomically with optional values in Roc. The `Maybe` type represents a value that may or may not exist.

Note that Roc has a great type system and using descriptive [tag unions](https://www.roc-lang.org/tutorial#tag-union-types), [tags with payloads](https://www.roc-lang.org/tutorial#tags-with-payloads), and/or `Try` is almost always preferable to `Maybe`. If you're new to Roc I encourage you to explore those options first, and please see this [FAQ entry which explains why Roc doesn't have a built-in `Maybe`](https://roc-lang.org/faq#option-type).

If you still want a `Maybe`: enjoy!

## Example usage

```roc
app [main!] {
    pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
    maybe: "package/main.roc",
}

import pf.Stdout
import maybe.Maybe exposing [Maybe]

Person : {
    name : Str,
    hobby : Maybe(Str),
}

search_your_soul : Person -> Str
search_your_soul = |person| {
    actual_hobby =
        person
            .hobby
            .map(|hobby| "${hobby} and Diablo II")
            .with_default("Diablo II")

    "${person.name} enjoys ${actual_hobby}"
}

main! = |_args| {
    people = [
        { name: "Alice", hobby: Just("Red wine") },
        { name: "Bob", hobby: Just("Charcuterie") },
        { name: "Charlie", hobby: Nothing },
    ]

    for person in people {
        Stdout.line!(search_your_soul(person))
    }

    Ok({})
}
```

This example demonstrates a combination of `Maybe` and exceptional taste. Run it like so `roc examples/main.roc`.

## Documentation

View the full API documentation at [https://niclas-ahden.github.io/roc-maybe/](https://niclas-ahden.github.io/roc-maybe/).
