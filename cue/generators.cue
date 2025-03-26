package problempackage

// Use cue version 0.11 or later

// To validate generators.yaml agains the schema:
// > cue vet generators.yaml *.cue -d "#Generators"

import "struct"

import "strings"

// A command invokes a generator or visualiser,
// e.g., "tree --n 5" or "/visualisers/viz/run".
// The regex restricts occurrences of curly-bracketed expressions
// to things like "tree --random --seed {seed:5} {name} {count}"
// - {seed} can occur at most once
// - {name} and {count} can occur any number of times
#command_args: =~"^([^{}]|\\{(name|count|seed(:[0-9]+)?)\\})*$"
#command:      C={
	!~"\\{seed.*\\{seed" // don't use seed twice
	_parts: strings.Fields(C)
	_parts: [string, ...#command_args]

	// TODO: should be [#path, ...#command_args] but something in cue is broken
}
#generator_command: #command & !~"^/"

// Test cases and test groups allow configuration of solution, visualiser, and random salt.
#config: {
	// Path to solution starts with slash, such as "/submissions/accepted/foo.py"
	solution?: #filepath & =~"^/"
	// Visualiser can be omitted to disable visualisation, may not use {count}
	visualizer?:  #command & =~"^/" & !~"\\{count" | null
	random_salt?: string
}

#testgroup_config: {
	#config
	"testdata.yaml"?: #Group
}

#testcase: {
	generate?: #generator_command
	count?:    int & >=1 & <=100
	// The "copy" key uses a path relative to "/generators/" ending in a testcase name,
	// such as "manual/samples/3".
	copy?: #dirpath

	["in" | "desc" | "hint"]: string

	// The hidden field `_dir` contains the name of the root-level (sample, secret, etc.)
	_dir: string
	if _dir != "invalid_input" {
		// A valid answer to this testcase
		ans?: string
	}

	// Sample testcases <tc> may provide additional files
	if _dir == "sample" {
		*{
			// <tc>.in.statement and <tc>.out are shown in the task description.
			// if <tc>.out is absent, <tc>ans.statement is shown instead, the latter
			// need not pass output validation.
			"in.statement"?: string
			{out?: string} | *{"ans.statement"?: string}
		} | {
			// Interactive problem instead provide sample interaction
			interaction?: =~"^([<>][^\\n]*\\n)+$"
		}

		// <tc>.{in, ans}.download are provided to the solver for download.
		// If absent, <tc>.{in, ans},statement or <tc>{in, ans} are provided instead.
		["in.download" | "ans.download"]: string
	}

	// Testcases in (in)valid_output must contain <tc>.out, which fail
	// or pass output validation, respectively.
	if _dir == "valid_output" || _dir == "invalid_output" {out?: string}
	#config
} & struct.MinFields(1)

#testgroup: {
	D=_dir: string
	// `data` contains either a map or a list
	data?: {{
		// A `data` map associates test data names with test groups or cases
		[#dataname]: ((#testgroup | #testcase) & {_dir: D}) | #generator_command
	}} | {
		// A `data` list consists of singleton test groups or testcases, 
		// which will receive automatic numbering
		[...(
		{
			// A list entry can have a name, which will be appended to the automatic number
			[#dataname | ""]: ((#testgroup | #testcase) & {_dir: D}) | #generator_command
		} & struct.MinFields(1) & struct.MaxFields(1) )
	]}
	include?: [...#dirpath]
	#testgroup_config
}

#Generators: {
	// Generators are named like files or testcases, like "tree.py" or "a".
	// Each consists of a nonempty list of paths relative to "/generators/",
	// such as ["tree_generator/tree.py", "lib.py"].
	generators?: [#dataname]: [...(#path & !~"^/")] & [_, ...]

	// At root level, six testgroup directories may be present
	data: [D="sample" | "secret" | "invalid_output" | "invalid_input" | "invalid_answer" | "valid_output"]: #testgroup & {_dir: D}
	// Secret and sample are mandatory  
	data: {secret!: _, sample!: _}

	#testgroup_config

	version: =~"^[0-9]{4}-[0-9]{2}$" | *"2025-03"

	... // Do allow unknown_key at top level for tooling
}
