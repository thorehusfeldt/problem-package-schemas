package problempackage

import "list"

#verdict: "AC" | "WA" | "RTE" | "TLE"

let globbed_dirname = "[A-Za-z0-9*]([A-Za-z0-9_*-]{0,253}[A-Za-z0-9*])?"
#globbed_dirpath: =~"^(\(globbed_dirname)/)*\(globbed_dirname)$" & !~"\\*\\*"
let globbed_filename = "([A-Za-z0-9*][A-Za-z0-9_.*-]{0,253}[A-Za-z0-9*]|\\*)"

#globbed_submissionpath: =~"^(\(globbed_dirname)/)*\(globbed_filename)$" & !~"\\*\\*"
#Submissions: {
	[#globbed_submissionpath]: #submission
}

#submission: {
	language?:   #ProgrammingLanguage
	entrypoint?: string
	author?: #Person | [...#Person]
	#expectation
	[=~"^(sample|secret|\\*)" & #globbed_dirpath]: #expectation
}

#expectation: {
	permitted?: [#verdict, ...#verdict] // only these verdicts may appear
	required?: [#verdict, ...#verdict] // at least one of these verdicts must appear
	score?: number | [number, number] & list.IsSorted(list.Ascending)
	use_for_timelmit?: false | "lower" | "upper"
}
