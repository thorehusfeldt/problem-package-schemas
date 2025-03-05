package problempackage

import "list"
import "time"

#ProgrammingLanguage: "ada" | "algol68" | "apl" | "bash" | "c" | "cgmp" | "cobol" | "cpp" | "cppgmp" | "crystal" | "csharp" | "d" | "dart" | "elixir" | "erlang" | "forth" | "fortran" | "fsharp" | "gerbil" | "go" | "haskell" | "java" | "javaalgs4" | "javascript" | "julia" | "kotlin" | "lisp" | "lua" | "modula2" | "nim" | "objectivec" | "ocaml" | "octave" | "odin" | "pascal" | "perl" | "php" | "prolog" | "python2" | "python3" | "python3numpy" | "racket" | "ruby" | "rust" | "scala" | "simula" | "smalltalk" | "snobol" | "swift" | "typescript" | "visualbasic" | "zig"
#LanguageCode: =~ "^[a-z]{2,3}(-[A-Z]{2})?$"
#Type: "pass-fail" | "scoring" | "multi-pass" | "interactive" | "submit-answer"

#Source: string | {
	name!: string
	url?:  string
}

#Person: string
#Persons: #Person | [#Person, ...#Person]

#Problem: {
	problem_format_version!: =~"^[0-9]{4}-[0-9]{2}(-draft)?$" | "draft" | "legacy" | "legacy-icpc"

	type?: *"pass-fail" | #Type | [#Type, ...#Type]
	if (type & [...]) != _|_ {
		_policy: true &
			!(list.Contains(type, "scoring") && list.Contains(type, "pass-fail")) &&
			!(list.Contains(type, "multi-pass") && list.Contains(type, "submit-answer")) &&
			!(list.Contains(type, "interactive") && list.Contains(type, "submit-answer"))
	}

	name!: string | {[#LanguageCode]: string}

	uuid!:    string

	version?: string

	credits?: #Person | {
		authors!:                                                        #Persons
		["contributors" | "testers" | "packagers" | "acknowledgements"]: #Persons
		translators?: [#LanguageCode]: #Persons
	}

	source?: #Source | [#Source, ...#Source]
	license: *"unknown" | "public domain" | "cc0" | "cc by" | "cc by-sa" | "educational" | "permission"
	rights_owner?: _
	if license != "unknown" && license != "public domain" && credits.authors == _|_ && source == _|_ {rights_owner!: #Person}
	if license == "unknown" || license == "public domain" {rights_owner: null}


	embargo_until?: time.Format("2006-01-02") | time.Format("2006-01-02T15:04:05Z")

	limits?:        #Limits

	keywords?: [...string]

	languages?: *"all" | [#ProgrammingLanguage, ...#ProgrammingLanguage]

	allow_file_writing?: *false | true

	constants?: [=~"^[a-zA-Z_][a-zA-Z0-9_]*$"]: int | float | string
}

#TimeLimit: "time_limit" | "compilation_time" | "validation_time"
#SizeLimit: "memory" | "output" | "code" | "compilation_memory" | "validation_memory" | "validation_output"
#Limits: {
	time_multipliers?: {
		ac_to_time_limit?:  float | *2.0
		time_limit_to_tle?: float | *1.5
	}
	time_resolution?:   float & >0 | *1.0
	[#TimeLimit]:       float & >0
	[#SizeLimit]:       int & >0
	validation_passes?: int & >0 | *1
}