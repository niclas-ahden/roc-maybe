app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    # maybe: "https://github.com/niclas-ahden/roc-maybe/releases/download/0.1.0/QbjfB928rAw71_NyBagk498PX-_VkgaF8CW1W4CqiHI.tar.br",
    maybe: "../package/main.roc",
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
        { name: "Alice", hobby: Just("Reading") },
        { name: "Bob", hobby: Just("Charcuterie") },
        { name: "Charlie", hobby: Nothing },
    ]

    people
    |> List.map(search_your_soul)
    |> List.for_each_try!(Stdout.line!)

