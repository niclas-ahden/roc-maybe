## A library for working with optional values in Roc. The `Maybe` type represents a value that might or might not exist.
##
## Note that Roc has a great type system and using descriptive [tag unions](https://www.roc-lang.org/tutorial#tag-union-types), [tags with payloads](https://www.roc-lang.org/tutorial#tags-with-payloads), and/or `Result` is usually preferable to `Maybe`. If you're new to Roc I encourage you to explore those options first. If you still want a `Maybe`: enjoy!
##
## ## JSON encoding/decoding
## Want to JSON encode/decode your `Maybe`? Use `Maybe.to_option` to get an `Option` from [`roc-json`](https://github.com/lukewilliamboswell/roc-json/) and you're set. `Option` is an [opaque type](https://roc-lang.org/tutorial#opaque-types) which makes it slightly less ergonomic to use, so I tend to work with `Maybe` until I get to a point where I need JSON encoding/decoding and convert to/from at that boundary.
module [
    Maybe,
    and_then!,
    and_then,
    combine,
    filter!,
    filter,
    from_option,
    from_result,
    is_just,
    is_nothing,
    join,
    keep_justs,
    map!,
    map,
    map2!,
    map2,
    map3!,
    map3,
    map4!,
    map4,
    map_try!,
    map_try,
    or_else,
    to_option,
    to_result,
    traverse!,
    traverse,
    with_default,
]

import json.Option exposing [Option]

## Represents an optional value of a given type. A `Maybe Fruit` can be `Just Apple`, `Just Orange`, or `Nothing` for example. Also known as `Option`.
Maybe a : [
    Nothing,
    Just a,
]

## Transform the value inside a `Just`, or do nothing if `Nothing`.
map : Maybe a, (a -> b) -> Maybe b
map = |m, f|
    when m is
        Just(a) -> Just(f(a))
        Nothing -> Nothing

## Like `map`, but with an effectful function.
map! : Maybe a, (a => b) => Maybe b
map! = |m, f!|
    when m is
        Just(a) -> Just(f!(a))
        Nothing -> Nothing

## Flatten nested `Maybe`s.
join : Maybe (Maybe a) -> Maybe a
join = |m|
    when m is
        Just(a) -> a
        Nothing -> Nothing

## Chain together `Maybe`-returning functions.
## If the `Maybe` is `Just`, applies the function to the value.
## If the `Maybe` is `Nothing`, returns `Nothing` without calling the function.
## This is equivalent to `map` followed by `join`, but more efficient.
## Also known as "flatMap" or "bind" in other languages.
and_then : Maybe a, (a -> Maybe b) -> Maybe b
and_then = |m, f|
    when m is
        Just(a) -> f(a)
        Nothing -> Nothing

## Like `and_then`, but with an effectful function.
## Also known as "flatMap" or "bind" in other languages.
and_then! : Maybe a, (a => Maybe b) => Maybe b
and_then! = |m, f!|
    when m is
        Just(a) -> f!(a)
        Nothing -> Nothing

## Like `map_try`, but with an effectful function.
## See also: `traverse` for lists, `map_try` for the pure version.
map_try! : Maybe a, (a => Result b e) => Result (Maybe b) e
map_try! = |m, f!|
    when m is
        Just(a) -> Ok(Just(f!(a)?))
        Nothing -> Ok(Nothing)

## Transform the value inside a `Just` using a fallible function, preserving the `Maybe` context.
## See also: `traverse` for lists, `map_try!` for the effectful version.
map_try : Maybe a, (a -> Result b e) -> Result (Maybe b) e
map_try = |m, f|
    when m is
        Just(a) -> Ok(Just(f(a)?))
        Nothing -> Ok(Nothing)

## Extract the value from a `Maybe`, or use the provided default if `Nothing`.
with_default : Maybe a, a -> a
with_default = |m, default|
    when m is
        Just(a) -> a
        Nothing -> default

## Convert a `Maybe` to a `Result`, using the provided error value for `Nothing`.
to_result : Maybe a, e -> Result a e
to_result = |m, e|
    when m is
        Just(a) -> Ok(a)
        Nothing -> Err(e)

## Convert a `Result` to a `Maybe`, discarding any error information.
from_result : Result a b -> Maybe a
from_result = |result|
    when result is
        Ok(v) -> Just(v)
        Err(_) -> Nothing

## Convert a `Maybe` to an `Option` from `roc-json` to be able to JSON encode it.
to_option : Maybe a -> Option a
to_option = |maybe|
    when maybe is
        Just(v) -> Option.some(v)
        Nothing -> Option.none({})

## Convert a `roc-json` `Option` to a `Maybe`.
from_option : Option a -> Maybe a
from_option = |option|
    when Option.get(option) is
        Some(v) -> Just(v)
        None -> Nothing

## Extract all `Just` values from a list, discarding `Nothing` values.
## Also known as "catMaybes" or "flatten" in other languages.
## See also: `combine` for all-or-nothing extraction.
keep_justs : List (Maybe a) -> List a
keep_justs = |ls|
    List.join_map(
        ls,
        |maybe|
            when maybe is
                Just(a) -> [a]
                Nothing -> [],
    )

## Return the first `Maybe` if it's `Just`, otherwise return the second `Maybe`.
or_else : Maybe a, Maybe a -> Maybe a
or_else = |first, second|
    when first is
        Just(_) -> first
        Nothing -> second

is_just : Maybe a -> Bool
is_just = |maybe|
    when maybe is
        Just(_) -> Bool.true
        Nothing -> Bool.false

is_nothing : Maybe a -> Bool
is_nothing = |maybe|
    when maybe is
        Just(_) -> Bool.false
        Nothing -> Bool.true

## Keep the `Just` value only if it satisfies the predicate, otherwise return `Nothing`.
filter : Maybe a, (a -> Bool) -> Maybe a
filter = |maybe, predicate|
    when maybe is
        Just(a) if predicate(a) -> Just(a)
        _ -> Nothing

## Like `filter`, but with an effectful predicate.
## Most predicates don't need effects - see `filter` for the common case.
filter! : Maybe a, (a => Bool) => Maybe a
filter! = |maybe, predicate!|
    when maybe is
        Just(a) if predicate!(a) -> Just(a)
        _ -> Nothing

## Combine two `Maybe` values using a binary function.
## Returns `Just` with the result if both inputs are `Just`, otherwise returns `Nothing`.
map2 : Maybe a, Maybe b, (a, b -> c) -> Maybe c
map2 = |ma, mb, f|
    when (ma, mb) is
        (Just(a), Just(b)) -> Just(f(a, b))
        _ -> Nothing

## Like `map2`, but with an effectful function.
map2! : Maybe a, Maybe b, (a, b => c) => Maybe c
map2! = |ma, mb, f!|
    when (ma, mb) is
        (Just(a), Just(b)) -> Just(f!(a, b))
        _ -> Nothing

## Combine three `Maybe` values with a function.
## Returns `Just` with the result if all three inputs are `Just`, otherwise returns `Nothing`.
map3 : Maybe a, Maybe b, Maybe c, (a, b, c -> d) -> Maybe d
map3 = |ma, mb, mc, f|
    when (ma, mb, mc) is
        (Just(a), Just(b), Just(c)) -> Just(f(a, b, c))
        _ -> Nothing

## Like `map3`, but with an effectful function.
map3! : Maybe a, Maybe b, Maybe c, (a, b, c => d) => Maybe d
map3! = |ma, mb, mc, f!|
    when (ma, mb, mc) is
        (Just(a), Just(b), Just(c)) -> Just(f!(a, b, c))
        _ -> Nothing

## Combine four `Maybe` values with a function.
## Returns `Just` with the result if all four inputs are `Just`, otherwise returns `Nothing`.
map4 : Maybe a, Maybe b, Maybe c, Maybe d, (a, b, c, d -> e) -> Maybe e
map4 = |ma, mb, mc, md, f|
    when (ma, mb, mc, md) is
        (Just(a), Just(b), Just(c), Just(d)) -> Just(f(a, b, c, d))
        _ -> Nothing

## Like `map4`, but with an effectful function.
map4! : Maybe a, Maybe b, Maybe c, Maybe d, (a, b, c, d => e) => Maybe e
map4! = |ma, mb, mc, md, f!|
    when (ma, mb, mc, md) is
        (Just(a), Just(b), Just(c), Just(d)) -> Just(f!(a, b, c, d))
        _ -> Nothing

## Convert a list of `Maybe` values to a `Maybe` of a list.
## Returns `Just` with all values if all elements are `Just`, otherwise returns `Nothing`.
## See also: `keep_justs` for partial extraction, `traverse` for mapping with Maybe, and `map_try` for Maybe-Result traverse.
combine : List (Maybe a) -> Maybe (List a)
combine = |maybes|
    List.map_try(maybes, |m| to_result(m, {}))
    |> from_result

## Map a function over a list, then combine the resulting list.
## Returns `Just` with the transformed list if all applications succeed, otherwise returns `Nothing`.
## Equivalent to mapping then combining: `traverse(list, f) == combine(List.map(list, f))`.
## See also: `combine` for just unwrapping or `map_try` for the Maybe-Result traverse.
traverse : List a, (a -> Maybe b) -> Maybe (List b)
traverse = |list, f|
    List.map_try(list, |elem| f(elem) |> to_result({}))
    |> from_result

## Like `traverse`, but with an effectful function.
traverse! : List a, (a => Maybe b) => Maybe (List b)
traverse! = |list, f!|
    List.map_try!(list, |elem| f!(elem) |> to_result({}))
    |> from_result

# Tests

## map tests
expect map(Just(5), |x| x + 1) == Just(6)
expect map(Nothing, |x| x + 1) == Nothing
# Identity
expect map(Just(5), |x| x) == Just(5)
expect map(Nothing, |x| x) == Nothing
# Composition
expect
    f = |x| x * 2
    g = |x| x + 1
    composed = |x| g(f(x))
    map(map(Just(3), f), g) == map(Just(3), composed)

## and_then tests
expect and_then(Just(5), |x| Just(x * 2)) == Just(10)
expect and_then(Just(5), |_| Nothing) == Nothing
expect and_then(Nothing, |x| Just(x * 2)) == Nothing
# Left identity
expect
    f = |x| Just(x * 2)
    and_then(Just(5), f) == f(5)
# Right identity
expect and_then(Just(5), Just) == Just(5)
expect and_then(Nothing, Just) == Nothing
# Associativity
expect
    m = Just(5)
    f = |x| Just(x * 2)
    g = |x| Just(x + 3)
    and_then(and_then(m, f), g) == and_then(m, |x| and_then(f(x), g))

## join tests
expect join(Just(Just(5))) == Just(5)
expect join(Just(Nothing)) == Nothing
expect join(Nothing) == Nothing
# join is equivalent to and_then with identity
expect join(Just(Just(5))) == and_then(Just(Just(5)), |x| x)

## with_default tests
expect with_default(Just(0), 5) == 0
expect with_default(Nothing, 5) == 5

## to_result tests
expect to_result(Just(5), "error") == Ok(5)
expect to_result(Nothing, "error") == Err("error")

## from_result tests
expect from_result(Ok(5)) == Just(5)
expect from_result(Err("error")) == Nothing

## to_option and from_option tests
expect
    maybe = Just(5)
    from_option(to_option(maybe)) == maybe
expect
    maybe = Nothing
    from_option(to_option(maybe)) == maybe

## keep_justs tests
expect keep_justs([]) == []
expect keep_justs([Nothing, Nothing]) == []
expect keep_justs([Just(1), Just(2), Just(3)]) == [1, 2, 3]
expect keep_justs([Just(1), Nothing, Just(3)]) == [1, 3]
# Order preservation
expect keep_justs([Just(3), Just(1), Just(2)]) == [3, 1, 2]

## or_else tests
expect or_else(Just(1), Just(2)) == Just(1)
expect or_else(Just(1), Nothing) == Just(1)
expect or_else(Nothing, Just(2)) == Just(2)
expect or_else(Nothing, Nothing) == Nothing

## is_just tests
expect is_just(Just(5)) == Bool.true
expect is_just(Nothing) == Bool.false

## is_nothing tests
expect is_nothing(Just(5)) == Bool.false
expect is_nothing(Nothing) == Bool.true

## map_try tests
expect map_try(Just(5), |x| Ok(x * 2)) == Ok(Just(10))
expect
    result : Result (Maybe U64) Str
    result = map_try(Just(5), |_| Err("error"))
    result == Err("error")
expect map_try(Nothing, |x| Ok(x * 2)) == Ok(Nothing)
expect
    result : Result (Maybe U64) Str
    result = map_try(Nothing, |_| Err("error"))
    result == Ok(Nothing)

## filter tests
expect filter(Just(5), |x| x > 3) == Just(5)
expect filter(Just(2), |x| x > 3) == Nothing
expect filter(Nothing, |x| x > 3) == Nothing

## map2 tests
expect map2(Just(3), Just(4), Num.add) == Just(7)
expect map2(Just(3), Nothing, Num.add) == Nothing
expect map2(Nothing, Just(4), Num.add) == Nothing
expect map2(Nothing, Nothing, Num.add) == Nothing

## map3 tests
expect map3(Just(1), Just(2), Just(3), |a, b, c| a + b + c) == Just(6)
expect map3(Just(1), Just(2), Nothing, |a, b, c| a + b + c) == Nothing
expect map3(Just(1), Nothing, Just(3), |a, b, c| a + b + c) == Nothing
expect map3(Nothing, Just(2), Just(3), |a, b, c| a + b + c) == Nothing
expect map3(Nothing, Nothing, Nothing, |a, b, c| a + b + c) == Nothing

## map4 tests
expect map4(Just(1), Just(2), Just(3), Just(4), |a, b, c, d| a + b + c + d) == Just(10)
expect map4(Nothing, Just(2), Just(3), Just(4), |a, b, c, d| a + b + c + d) == Nothing
expect map4(Just(1), Nothing, Just(3), Just(4), |a, b, c, d| a + b + c + d) == Nothing
expect map4(Just(1), Just(2), Nothing, Just(4), |a, b, c, d| a + b + c + d) == Nothing
expect map4(Just(1), Just(2), Just(3), Nothing, |a, b, c, d| a + b + c + d) == Nothing

## combine tests
expect combine([]) == Just([])
expect combine([Just(1), Just(2), Just(3)]) == Just([1, 2, 3])
expect combine([Just(1), Nothing, Just(3)]) == Nothing
expect combine([Nothing]) == Nothing
# Order preservation
expect combine([Just(3), Just(1), Just(2)]) == Just([3, 1, 2])

## traverse tests
expect traverse([], |x| Just(x * 2)) == Just([])
expect traverse([1, 2, 3], |x| Just(x * 2)) == Just([2, 4, 6])
expect traverse([1, 2, 3], |x| if x == 2 then Nothing else Just(x * 2)) == Nothing
# Equivalence: traverse(list, f) == combine(List.map(list, f))
expect
    list = [1, 2, 3]
    f = |x| Just(x * 2)
    traverse(list, f) == combine(List.map(list, f))
# Order preservation
expect traverse([3, 1, 2], |x| Just(x * 2)) == Just([6, 2, 4])
