package problempackage

// Directory names, as well as names of testcases and generators are
// alphanumerical with internal underscores and hyphens; such as
// "huge", "make_tree", "3", "a", or "connected_graph-01";
// but not "huge_" or "-2" or "bapc.24" or ".." or "".
let dirname = "[A-Za-z0-9]([A-Za-z0-9_-]{0,253}[A-Za-z0-9])?"
#dataname: =~"^\(dirname)$"

// Directory paths are separated by / and do not start with a slash
#dirpath: =~"^(\(dirname)/)*\(dirname)$"

// Filenames are names, but have length at least 2 and can also
// contain '.' such as "good-solution_02.py" or "1.in"
let filename = "[A-Za-z0-9][A-Za-z0-9_.-]{0,253}[A-Za-z0-9]"

#filepath: =~"^/?(\(dirname)/)*\(filename)$"

// Paths can both refer to objects like the testgroup "data/secret/huge" or
// a program file like "/submissions/accepted/x.cpp"

#path: #dirpath | #filepath

// Test data can be configure both on the case and directory level

#Config: {
	output_validator_args?: [...string]

	// input validator arguments can be passed to invidual validators using a map
	input_validator_args?: [...string] | {[string]: [...string]}

	full_feedback?:           bool
	["hint" | "description"]: string
}

#Case: {
	// Indvidual test cases can pass arguments to the submission
	args?: [...string]
	#Config
}

#requiredpath: #dirpath & (=~"^sample" | =~"^secret")

#Group: {
	scoring?: {
		score?:       int & >=0 | "unbounded"
		aggregation?: "pass-fail" | "sum" | "min"
		require_pass?: #requiredpath | [...#requiredpath]
	}
	static_validation?: *false | true | {
		args?: [...string]
		score?: float
	}
	#Config
}
