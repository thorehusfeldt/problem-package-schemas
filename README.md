# Problem Package Format Schemas

A collection of schemas to validate YAML files for the Kattis [Problem Package format](https://www.kattis.com/problem-package-format/spec/2023-07-draft.html) and [Generators framework](https://github.com/RagnarGrootKoerkamp/BAPCtools/blob/master/doc/generators.md) of [BAPCTools](https://github.com/RagnarGrootKoerkamp/BAPCtools).

The schemas are expressed in [CUE](cuelang.org) and can be used to validate the following files in a problem package:

| Description | File name | Schema name |
| ---|---|---|
| Problem metadata | `problem.yaml` | `#Problem` |
| Submission information | `submissions.yaml` | `#Submission` |
| Test Case Configuration | `<testcase>.yaml` | `#CaseConfiguration` |
| Test Data Group Configuration | `testdata.yaml` | `#DataConfiguration` |

For instance, to validate `problem.yaml`, you can run (from the `cue` directory),

```bash
cue vet problem.yaml *.cue  --schema "#Problem"
```

To validate all `testdata.yaml` in `<path>`, run

```bash
cue vet <path>/**/testdata.yaml *.cue  --schema "#DataConfiguration"
```

## Versions

* Problem Package Format attempts to be consistent with the `2023-07-draft` version.
* The Generators framework attempts to be consistent with the current implementation of BAPCtools’ `bt generate`, currently `2024-12`.
