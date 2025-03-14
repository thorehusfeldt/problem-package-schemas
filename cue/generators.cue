package problempackage

// Use cue version 0.11 or later

// To validate generators.yaml agains the schema:
// > cue vet generators.yaml *.cue -d "#Generators"

import "struct"

import "strings"

// A command invokes a generator, like "tree --n 5".
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

#testcase:
	#command & !~"^/" |
	{
		generate?: #command & !~"^/"
		count?:    int & >=1 & <=100
		// The "copy" key uses a path relative to "/generators/" ending in a testcase name,
		// such as "manual/samples/3".
		copy?:                                    #dirpath
		["in" | "ans" | "out" | "desc" | "hint"]: string
		interaction?:                             =~"^([<>][^\\n]*\\n)+$"
		#config
	} & struct.MinFields(1)

#data_list: {[#dataname | ""]: #testgroup | #testcase} & struct.MinFields(1) & struct.MaxFields(1)

#data_dict_production: {data?: {[#dataname]: #testgroup | #testcase}}

#data_list_production: {data?: [...#data_list]}

#testgroup: {
	#data_dict_production | #data_list_production
	include?: [...#dirpath]
	#testgroup_config
}

#Generators: {
	// Generators are named like files or testcases, like "tree.py" or "a".
	// Each consists of a nonempty list of paths relative to "/generators/",
	// such as ["tree_generator/tree.py", "lib.py"].
	generators?: [#dataname]: [...(#path & !~"^/")] & [_, ...]
	data: close({
		sample!:         #testgroup
		secret!:         #testgroup
		invalid_input?:  #testgroup
		invalid_answer?: #testgroup
		invalid_output?: #testgroup
		valid_output?:   #testgroup
	})
	#testgroup_config

	version: =~"^[0-9]{4}-[0-9]{2}$" | *"2024-12"

	... // Do allow unknown_key at top level for tooling
}
