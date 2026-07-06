app [main!] {
	pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.9/8GdFEvQYS3TeAZxKvTzCLVdQiomweGtXcdZkXNDEeABq.tar.zst",
	maybe: "../package/main.roc",
}

import pf.Stdout
import maybe.Maybe

Person : {
	name : Str,
	hobby : Maybe.Maybe(Str),
}

search_your_soul : Person -> Str
search_your_soul = |person| {
	actual_hobby = 
		Maybe.with_default(
			Maybe.map(person.hobby, |hobby| "${hobby} and Diablo II"),
			"Diablo II",
		)

	"${person.name} enjoys ${actual_hobby}"
}

main! = |_args| {
	Stdout.line!("=== Maybe Package Demo ===")

	people : List(Person)
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
