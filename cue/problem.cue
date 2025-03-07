package problempackage

import "list"

import "time"

#ProgrammingLanguage: "ada" | "algol68" | "apl" | "bash" | "c" | "cgmp" | "cobol" | "cpp" | "cppgmp" | "crystal" | "csharp" | "d" | "dart" | "elixir" | "erlang" | "forth" | "fortran" | "fsharp" | "gerbil" | "go" | "haskell" | "java" | "javaalgs4" | "javascript" | "julia" | "kotlin" | "lisp" | "lua" | "modula2" | "nim" | "objectivec" | "ocaml" | "octave" | "odin" | "pascal" | "perl" | "php" | "prolog" | "python2" | "python3" | "python3numpy" | "racket" | "ruby" | "rust" | "scala" | "simula" | "smalltalk" | "snobol" | "swift" | "typescript" | "visualbasic" | "zig"

// Two- or three-letter language codes such as "en", "fil", or "po-BR"
#LanguageCode: =~"^[a-z]{2,3}(-.+)?$"

#Type: "pass-fail" | "scoring" | "multi-pass" | "interactive" | "submit-answer"

// A problem source is typically a contest or course, such as "NWERC 2023" or { name: "NWERC 2023", url: "2023.nwerc.eu" }
#Source: string | {
	name!: string
	url?:  string
}

#Person: string

// Persons are one or more people, such as "Ada Lovelace <ada@lovelace.com>" or ["Alice", "Bob"]
#Persons: #Person | [#Person, ...#Person]

#Problem: {
	// Problem package format used by this file, such as "2023-12-draft"
	problem_format_version!: =~"^[0-9]{4}-[0-9]{2}(-draft)?$" | "draft" | "legacy" | "legacy-icpc"

	// The type of this problem, such as "pass-fail" or ["scoring", "interactive", "multi-pass"]
	type?: *"pass-fail" | #Type | [#Type, ...#Type]
	if (type & [...]) != _|_ {
		_policy: true &
			!(list.Contains(type, "scoring") && list.Contains(type, "pass-fail")) &&
			!(list.Contains(type, "multi-pass") && list.Contains(type, "submit-answer")) &&
			!(list.Contains(type, "interactive") && list.Contains(type, "submit-answer"))
	}

	// The name of this problem, such as "Hello" or { en: "Hello", da: "Hej" }
	name!: string | {[#LanguageCode]: string}

	// A unique identifier for this problem, such as "8ee7605a-ab1a-8226-1d71-e346ab1e688d"
	uuid!: string

	// A version for this problem, such as "draft" or "1.1"
	version?: string

	// The people who created this problem. Can be a single person such as "Ada Lovelace".
	credits?: #Person | {
		// The people who conceptualised this problem.
		authors?: #Persons
		// The people who developed the problem package, such as the statement, validators, and test data.
		contributors?: #Persons
		// The people who tested the problem package, for example, by providing a solution and reviewing the statement.
		testers?: #Persons
		// The people who created the problem package out of an existing problem.
		packagers?: #Persons
		// Extra acknowledgements or special thanks in addition to the previously mentioned.
		acknowledgements?: #Persons
		// The people who translated the statement to other languages, mapped by language code.
		translators?: [#LanguageCode]: #Persons
	}

	// The source(s) of this problem, such as "NWERC 2024"
	source?: #Source | [#Source, ...#Source]

	// The license of this problem.
	*{license?: *"unknown" | "public domain"} | {
		license!: "cc0" | "cc by" | "cc by-sa" | "educational" | "permission"
		// Who owns the rights to this problem.
		rights_owner?: #Person
	}

	// Do not publish this problem until the embargo is lifted.
	embargo_until?: time.Format("2006-01-02") | time.Format("2006-01-02T15:04:05Z")

	// Time and size limits for this problem.
	limits: {
		// The time limit for submission, in seconds
		time_limit?: float & >0

		// Safety margins relative to the slowest accepted submission
		time_multipliers?: {
			ac_to_time_limit?:  float & >=1 | *2.0
			time_limit_to_tle?: float & >=1 | *1.5
		}

		// Resolution for determining the time_limit from the slowest accepted solution
		time_resolution?: float & >0 | *1.0

		// Time bounds in seconds
		["compilation_time" | "compilation_time"]: int & >0

		// Size bounds in MiB
		["memory" | "output" | "compilation_memory" | "validation_memory" | "validation_output"]: int & >0

		// Code length in kiB
		code?: int & >0

		// How many passes does validation entail?
		validation_passes?: int & >0 | *1
	}

	// A sequence of keywords describing the problem, such as ["brute force", "real-life"].
	keywords?: [...string]

	// If not "all", restrict the programming languages that this problem may be solved in.
	languages?: *"all" | [#ProgrammingLanguage, ...#ProgrammingLanguage]

	// Should submissions have access to creating, editing and deleting files in their working directory?
	allow_file_writing?: *false | true

	// Constants for templates in the rest of the package, such as { max_n: 2000, name: "Alice" }
	constants?: [=~"^[a-zA-Z_][a-zA-Z0-9_]*$"]: int | float | string
}
