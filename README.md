# Maybe

A library for working with optional values in Roc. The `Maybe` type represents a value that might or might not exist.

Note that Roc has a great type system and using descriptive tag unions or `Result` is usually preferable over `Maybe`. This library is specifically for those situations when a value simply is or isn't there, and there's no additional context or circumstance.

## JSON encoding/decoding

Want to JSON encode/decode your `Maybe`? Use `Maybe.to_option` to get an `Option` from [`roc-json`](https://github.com/lukewilliamboswell/roc-json/) and you're set. `Option` is an [opaque type](https://roc-lang.org/tutorial#opaque-types) which makes it slightly less ergonomic to use, so I tend to work with `Maybe` until I get to a point where I need JSON encoding/decoding and convert to/from at that boundary.

## Example usage

```roc
import maybe.Maybe exposing [Maybe]

# Transform values inside a Maybe
user_id : Maybe U64
user_id = Just(42)

display_id = Maybe.map(user_id, Num.to_str)
# Result: Just("42")

# Provide a default for missing values
name = Maybe.with_default(user_name, "Guest")

# Chain operations that might fail
lookup_user : U64 -> Maybe User
fetch_email : User -> Maybe Str

user_email =
    user_id
    |> Maybe.and_then(lookup_user)
    |> Maybe.and_then(fetch_email)
```

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
