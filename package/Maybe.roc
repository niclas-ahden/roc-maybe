## A library for working with optional values in Roc. The `Maybe` type represents a value that might or might not exist.
##
## Note that Roc has a great type system and using descriptive [tag unions](https://www.roc-lang.org/tutorial#tag-union-types), [tags with payloads](https://www.roc-lang.org/tutorial#tags-with-payloads), and/or `Try` is usually preferable to `Maybe`. If you're new to Roc I encourage you to explore those options first. If you still want a `Maybe`: enjoy!

## Represents an optional value of a given type. A `Maybe(Fruit)` can be `Just(Apple)`, `Just(Orange)`, or `Nothing` for example. Also known as `Option`.
Maybe(a) := [
	Nothing,
	Just(a),
].{

	## Transform the value inside a `Just`, or do nothing if `Nothing`.
	map : Maybe(a), (a -> b) -> Maybe(b)
	map = |m, f|
		match m {
			Just(a) => Just(f(a))
			Nothing => Nothing
		}

	## Like `map`, but with an effectful function.
	map! : Maybe(a), (a => b) => Maybe(b)
	map! = |m, f!|
		match m {
			Just(a) => Just(f!(a))
			Nothing => Nothing
		}

	## Flatten nested `Maybe`s.
	join : Maybe(Maybe(a)) -> Maybe(a)
	join = |m|
		match m {
			Just(a) => a
			Nothing => Nothing
		}

	## Chain together `Maybe`-returning functions.
	## If the `Maybe` is `Just`, applies the function to the value.
	## If the `Maybe` is `Nothing`, returns `Nothing` without calling the function.
	## This is equivalent to `map` followed by `join`, but more efficient.
	## Also known as "flatMap" or "bind" in other languages.
	and_then : Maybe(a), (a -> Maybe(b)) -> Maybe(b)
	and_then = |m, f|
		match m {
			Just(a) => f(a)
			Nothing => Nothing
		}

	## Like `and_then`, but with an effectful function.
	## Also known as "flatMap" or "bind" in other languages.
	and_then! : Maybe(a), (a => Maybe(b)) => Maybe(b)
	and_then! = |m, f!|
		match m {
			Just(a) => f!(a)
			Nothing => Nothing
		}

	## Transform the value inside a `Just` using a fallible function, preserving the `Maybe` context.
	## See also: `traverse` for lists, `map_try!` for the effectful version.
	map_try : Maybe(a), (a -> Try(b, e)) -> Try(Maybe(b), e)
	map_try = |m, f|
		match m {
			Just(a) => Ok(Just(f(a)?))
			Nothing => Ok(Nothing)
		}

	## Like `map_try`, but with an effectful function.
	## See also: `traverse` for lists, `map_try` for the pure version.
	map_try! : Maybe(a), (a => Try(b, e)) => Try(Maybe(b), e)
	map_try! = |m, f!|
		match m {
			Just(a) => Ok(Just(f!(a)?))
			Nothing => Ok(Nothing)
		}

	## Extract the value from a `Maybe`, or use the provided default if `Nothing`.
	with_default : Maybe(a), a -> a
	with_default = |m, default|
		match m {
			Just(a) => a
			Nothing => default
		}

	## Convert a `Maybe` to a `Try`, using the provided error value for `Nothing`.
	to_result : Maybe(a), e -> Try(a, e)
	to_result = |m, e|
		match m {
			Just(a) => Ok(a)
			Nothing => Err(e)
		}

	## Convert a `Try` to a `Maybe`, discarding any error information.
	from_result : Try(a, b) -> Maybe(a)
	from_result = |result|
		match result {
			Ok(v) => Just(v)
			Err(_) => Nothing
		}

	## Extract all `Just` values from a list, discarding `Nothing` values.
	## Also known as "catMaybes" or "flatten" in other languages.
	## See also: `combine` for all-or-nothing extraction.
	keep_justs : List(Maybe(a)) -> List(a)
	keep_justs = |ls|
		ls.fold(
			[],
			|acc, maybe|
				match maybe {
					Just(a) => acc.append(a)
					Nothing => acc
				},
		)

	## Return the first `Maybe` if it's `Just`, otherwise return the second `Maybe`.
	or_else : Maybe(a), Maybe(a) -> Maybe(a)
	or_else = |first, second|
		match first {
			Just(_) => first
			Nothing => second
		}

	is_just : Maybe(a) -> Bool
	is_just = |maybe|
		match maybe {
			Just(_) => Bool.True
			Nothing => Bool.False
		}

	is_nothing : Maybe(a) -> Bool
	is_nothing = |maybe|
		match maybe {
			Just(_) => Bool.False
			Nothing => Bool.True
		}

	## Keep the `Just` value only if it satisfies the predicate, otherwise return `Nothing`.
	filter : Maybe(a), (a -> Bool) -> Maybe(a)
	filter = |maybe, predicate|
		match maybe {
			Just(a) if predicate(a) => Just(a)
			_ => Nothing
		}

	## Like `filter`, but with an effectful predicate.
	## Most predicates don't need effects - see `filter` for the common case.
	filter! : Maybe(a), (a => Bool) => Maybe(a)
	filter! = |maybe, predicate!|
		match maybe {
			Just(a) if predicate!(a) => Just(a)
			_ => Nothing
		}

	## Combine two `Maybe` values using a binary function.
	## Returns `Just` with the result if both inputs are `Just`, otherwise returns `Nothing`.
	map2 : Maybe(a), Maybe(b), (a, b -> c) -> Maybe(c)
	map2 = |ma, mb, f|
		match (ma, mb) {
			(Just(a), Just(b)) => Just(f(a, b))
			_ => Nothing
		}

	## Like `map2`, but with an effectful function.
	map2! : Maybe(a), Maybe(b), (a, b => c) => Maybe(c)
	map2! = |ma, mb, f!|
		match (ma, mb) {
			(Just(a), Just(b)) => Just(f!(a, b))
			_ => Nothing
		}

	## Combine three `Maybe` values with a function.
	## Returns `Just` with the result if all three inputs are `Just`, otherwise returns `Nothing`.
	map3 : Maybe(a), Maybe(b), Maybe(c), (a, b, c -> d) -> Maybe(d)
	map3 = |ma, mb, mc, f|
		match (ma, mb, mc) {
			(Just(a), Just(b), Just(c)) => Just(f(a, b, c))
			_ => Nothing
		}

	## Like `map3`, but with an effectful function.
	map3! : Maybe(a), Maybe(b), Maybe(c), (a, b, c => d) => Maybe(d)
	map3! = |ma, mb, mc, f!|
		match (ma, mb, mc) {
			(Just(a), Just(b), Just(c)) => Just(f!(a, b, c))
			_ => Nothing
		}

	## Combine four `Maybe` values with a function.
	## Returns `Just` with the result if all four inputs are `Just`, otherwise returns `Nothing`.
	map4 : Maybe(a), Maybe(b), Maybe(c), Maybe(d), (a, b, c, d -> e) -> Maybe(e)
	map4 = |ma, mb, mc, md, f|
		match (ma, mb, mc, md) {
			(Just(a), Just(b), Just(c), Just(d)) => Just(f(a, b, c, d))
			_ => Nothing
		}

	## Like `map4`, but with an effectful function.
	map4! : Maybe(a), Maybe(b), Maybe(c), Maybe(d), (a, b, c, d => e) => Maybe(e)
	map4! = |ma, mb, mc, md, f!|
		match (ma, mb, mc, md) {
			(Just(a), Just(b), Just(c), Just(d)) => Just(f!(a, b, c, d))
			_ => Nothing
		}

	## Convert a list of `Maybe` values to a `Maybe` of a list.
	## Returns `Just` with all values if all elements are `Just`, otherwise returns `Nothing`.
	## See also: `keep_justs` for partial extraction, `traverse` for mapping with Maybe, and `map_try` for Maybe-Try traverse.
	combine : List(Maybe(a)) -> Maybe(List(a))
	combine = |maybes|
		maybes.fold(
			Just([]),
			|acc, m|
				match (acc, m) {
					(Just(xs), Just(x)) => Just(xs.append(x))
					_ => Nothing
				},
		)

	## Map a function over a list, then combine the resulting list.
	## Returns `Just` with the transformed list if all applications succeed, otherwise returns `Nothing`.
	## Equivalent to mapping then combining: `traverse(list, f) == combine(List.map(list, f))`.
	## See also: `combine` for just unwrapping or `map_try` for the Maybe-Try traverse.
	traverse : List(a), (a -> Maybe(b)) -> Maybe(List(b))
	traverse = |list, f|
		list.fold(
			Just([]),
			|acc, elem|
				match (acc, f(elem)) {
					(Just(xs), Just(x)) => Just(xs.append(x))
					_ => Nothing
				},
		)

	## Like `traverse`, but with an effectful function.
	traverse! : List(a), (a => Maybe(b)) => Maybe(List(b))
	traverse! = |list, f!| {
		var $acc = Just([])

		for elem in list {
			$acc = match ($acc, f!(elem)) {
				(Just(xs), Just(x)) => Just(xs.append(x))
				_ => Nothing
			}
		}

		$acc
	}
}

# Tests

## map tests
expect Maybe.map(Just(5), |x| x + 1) == Just(6)
expect Maybe.map(Nothing, |x| x + 1) == Nothing
# Identity
expect Maybe.map(Just(5), |x| x) == Just(5)
expect Maybe.map(Nothing, |x| x) == Nothing
# Composition
expect {
	f = |x| x * 2
	g = |x| x + 1
	composed = |x| g(f(x))
	Maybe.map(Maybe.map(Just(3), f), g) == Maybe.map(Just(3), composed)
}

## and_then tests
expect Maybe.and_then(Just(5), |x| Just(x * 2)) == Just(10)
expect Maybe.and_then(Just(5), |_| Nothing) == Nothing
expect Maybe.and_then(Nothing, |x| Just(x * 2)) == Nothing
# Left identity
expect {
	f = |x| Just(x * 2)
	Maybe.and_then(Just(5), f) == f(5)
}
# Right identity
expect Maybe.and_then(Just(5), |x| Just(x)) == Just(5)
expect Maybe.and_then(Nothing, |x| Just(x)) == Nothing
# Associativity
expect {
	m = Just(5)
	f = |x| Just(x * 2)
	g = |x| Just(x + 3)
	Maybe.and_then(Maybe.and_then(m, f), g) == Maybe.and_then(m, |x| Maybe.and_then(f(x), g))
}

## join tests
expect Maybe.join(Just(Just(5))) == Just(5)
expect Maybe.join(Just(Nothing)) == Nothing
expect Maybe.join(Nothing) == Nothing
# join is equivalent to and_then with identity
expect Maybe.join(Just(Just(5))) == Maybe.and_then(Just(Just(5)), |x| x)

## with_default tests
expect Maybe.with_default(Just(0), 5) == 0
expect Maybe.with_default(Nothing, 5) == 5

## to_result tests
expect Maybe.to_result(Just(5), "error") == Ok(5)
expect Maybe.to_result(Nothing, "error") == Err("error")

## from_result tests
expect Maybe.from_result(Ok(5)) == Just(5)
expect Maybe.from_result(Err("error")) == Nothing

## keep_justs tests
expect Maybe.keep_justs([]) == []
expect Maybe.keep_justs([Nothing, Nothing]) == []
expect Maybe.keep_justs([Just(1), Just(2), Just(3)]) == [1, 2, 3]
expect Maybe.keep_justs([Just(1), Nothing, Just(3)]) == [1, 3]
# Order preservation
expect Maybe.keep_justs([Just(3), Just(1), Just(2)]) == [3, 1, 2]

## or_else tests
expect Maybe.or_else(Just(1), Just(2)) == Just(1)
expect Maybe.or_else(Just(1), Nothing) == Just(1)
expect Maybe.or_else(Nothing, Just(2)) == Just(2)
expect Maybe.or_else(Nothing, Nothing) == Nothing

## is_just tests
expect Maybe.is_just(Just(5)) == Bool.True
expect Maybe.is_just(Nothing) == Bool.False

## is_nothing tests
expect Maybe.is_nothing(Just(5)) == Bool.False
expect Maybe.is_nothing(Nothing) == Bool.True

## map_try tests
expect Maybe.map_try(Just(5), |x| Ok(x * 2)) == Ok(Just(10))
expect {
	result : Try(Maybe(U64), Str)
	result = Maybe.map_try(Just(5), |_| Err("error"))
	result == Err("error")
}
expect Maybe.map_try(Nothing, |x| Ok(x * 2)) == Ok(Nothing)
expect {
	result : Try(Maybe(U64), Str)
	result = Maybe.map_try(Nothing, |_| Err("error"))
	result == Ok(Nothing)
}

## filter tests
expect Maybe.filter(Just(5), |x| x > 3) == Just(5)
expect Maybe.filter(Just(2), |x| x > 3) == Nothing
expect Maybe.filter(Nothing, |x| x > 3) == Nothing

## map2 tests
expect Maybe.map2(Just(3), Just(4), |a, b| a + b) == Just(7)
expect Maybe.map2(Just(3), Nothing, |a, b| a + b) == Nothing
expect Maybe.map2(Nothing, Just(4), |a, b| a + b) == Nothing
expect Maybe.map2(Nothing, Nothing, |a, b| a + b) == Nothing

## map3 tests
expect Maybe.map3(Just(1), Just(2), Just(3), |a, b, c| a + b + c) == Just(6)
expect Maybe.map3(Just(1), Just(2), Nothing, |a, b, c| a + b + c) == Nothing
expect Maybe.map3(Just(1), Nothing, Just(3), |a, b, c| a + b + c) == Nothing
expect Maybe.map3(Nothing, Just(2), Just(3), |a, b, c| a + b + c) == Nothing
expect Maybe.map3(Nothing, Nothing, Nothing, |a, b, c| a + b + c) == Nothing

## map4 tests
expect Maybe.map4(Just(1), Just(2), Just(3), Just(4), |a, b, c, d| a + b + c + d) == Just(10)
expect Maybe.map4(Nothing, Just(2), Just(3), Just(4), |a, b, c, d| a + b + c + d) == Nothing
expect Maybe.map4(Just(1), Nothing, Just(3), Just(4), |a, b, c, d| a + b + c + d) == Nothing
expect Maybe.map4(Just(1), Just(2), Nothing, Just(4), |a, b, c, d| a + b + c + d) == Nothing
expect Maybe.map4(Just(1), Just(2), Just(3), Nothing, |a, b, c, d| a + b + c + d) == Nothing

## combine tests
expect Maybe.combine([]) == Just([])
expect Maybe.combine([Just(1), Just(2), Just(3)]) == Just([1, 2, 3])
expect Maybe.combine([Just(1), Nothing, Just(3)]) == Nothing
expect Maybe.combine([Nothing]) == Nothing
# Order preservation
expect Maybe.combine([Just(3), Just(1), Just(2)]) == Just([3, 1, 2])

## traverse tests
expect Maybe.traverse([], |x| Just(x * 2)) == Just([])
expect Maybe.traverse([1, 2, 3], |x| Just(x * 2)) == Just([2, 4, 6])
expect Maybe.traverse(
	[1, 2, 3],
	|x| if x == 2 {
		Nothing
	} else {
		Just(x * 2)
	},
) == Nothing

# Equivalence: traverse(list, f) == combine(List.map(list, f))
expect {
	list = [1, 2, 3]
	f = |x| Just(x * 2)
	Maybe.traverse(list, f) == Maybe.combine(List.map(list, f))
}

# Order preservation
expect Maybe.traverse([3, 1, 2], |x| Just(x * 2)) == Just([6, 2, 4])
