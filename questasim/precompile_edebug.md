### How to generate a post pre-compile code?

The command is __optional__ & captures text processed by the Verilog parser after preprocessing has occurred, and copies that text to a debugging output file.

#### QuestaSim Flag

```
-Edebug <filename>
```

`<filename>` — Specifies a name for the debugging output file. You cannot use wildcards.

Generally, preprocessing consists of the following compiler directives: `ifdef, `else, `elsif, `endif, `ifndef, `define, `undef, `include. The file is a concatenation of source files with `include expanded. The file can be compiled and then used to find errors in the original source files. The `line directive attempts to preserve line numbers and file names in the output file. White space is usually preserved, but is sometimes deleted or added to the output file.

#### Example

```
vlog -l compile.log -f .svunit.f "+define+SVUNIT_VERSION=unreleased" "+define+RUN_SVUNIT_WITH_UVM" -Edebug preproc.sv
```