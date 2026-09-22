app [main!] {
	pf: platform "https://github.com/niclas-ahden/basic-cli/releases/download/0.26.0/EuuihZ91yAY1ANck1QytRBcW2jexEfH6yVmxcPCHEHDz.tar.zst",
	maybe: "../package/main.roc",
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
