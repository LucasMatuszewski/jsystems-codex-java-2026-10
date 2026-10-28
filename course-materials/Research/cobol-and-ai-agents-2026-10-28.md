# COBOL and AI coding agents: models, practices and a safe practice lab (research, 2026-10-28)

## 1. TL;DR

- Start with source-backed explanation, dependency discovery and test design before requesting edits.
- Supply resolved copybooks, compiler options and file bindings; a program fragment is incomplete context.
- Compile with the real target compiler and compare behavior after every change.
- Treat model benchmarks as task-specific evidence. Vendor-reported results are not independent validation.
- Practice with public source and synthetic data. The lab below has not been executed end-to-end.

## 2. Which models

For a Codex evaluation, GPT-6.1 Sol is a reasonable starting candidate for analysis and small changes. Official documentation identifies it as a coding model and supports `high` reasoning effort. This establishes product capabilities, not superiority on COBOL. Compare GPT-6 Astra on difficult cases rather than assuming a larger model fixes missing context. [1], [2]

**Vendor-reported, not independently verified:** press coverage of the GPT-6.1 Sol release cites OpenAI's own COBOL migration evaluation at 86.6% with low reasoning effort and 97.9% with high effort. [15], [16] We did not locate the evaluation itself, and no independent COBOL-specific results for current models are established here, so no ranking is given. A vendor-reported migration result, even when documented, does not establish maintenance quality across dialects. Likewise, a general terminal benchmark cannot rank COBOL semantic fidelity.

COBOLEval provides an executable code-generation benchmark. COBOLAssist studies compilation-guided repair; COBOL-Coder studies domain adaptation and COBOL/Java translation. These are research results under particular harnesses, not demonstrations of whole-system equivalence or a universal current-model winner. [3], [4], [5]

Evaluate models on the same approved, non-production corpus: explain one program, locate a field's dependencies, draft tests and implement one bounded change. Freeze source revision, copybooks, prompt, compiler options and expectations. Record model, effort, compilation outcome, behavioral differences, unsupported claims and human correction effort. Compare explanation accuracy separately from executable correctness. Include empty input, decimal boundaries and malformed records where behavior is specified.

## 3. Practices that make agents useful on COBOL

**Resolve definitions first.** Provide source plus every nested copybook, including `COPY ... REPLACING` effects. Keep originals alongside expanded compiler output so explanations remain traceable. For GnuCOBOL, `cobc -E -I copybooks program.cbl` preprocesses source. Never let the agent infer a field's layout from its name. Include calling conventions and the invoking script or JCL. [6]

**Close the compiler loop.** Put the repository's actual build/check command in `AGENTS.md`. After edits, compile, run controlled fixtures, inspect diagnostics and compare results. A GnuCOBOL syntax pass cannot replace validation with IBM COBOL for Linux, Rocket Visual COBOL or another target compiler. Research supports investigating compiler feedback, without justifying a universal percentage improvement. [4], [5]

**Make source format explicit.** Traditional fixed format uses columns 1-6 for sequence information, 7 for indicators, 8-11 for Area A and 12-72 for Area B. Identification columns 73-80 are outside the conventional program-text area. Check configured margins, continuations, tabs, periods and line endings mechanically; do not assume every dialect uses identical restrictions. [7]

**Preserve representation.** `COMP-3` is packed decimal, not ordinary text. Document `PIC`, scale, signs, rounding, truncation, overflow and intermediate results. For Java mappings, use `BigDecimal` or an explicitly bounded exact representation, never casual floating-point substitution. Derive rounding behavior from statements and compiler settings rather than one blanket rule. Treat `REDEFINES` as shared storage and investigate variable `OCCURS` layouts. [6], [8]

**Characterize before changing.** Freeze reviewed original outputs, return codes and relevant effects for synthetic inputs. Add independent field assertions: a golden master can faithfully preserve a defect. Specify changed expectations before implementing a change. Never regenerate goldens from changed code merely to pass tests.

**Write a concrete agent contract.** A COBOL `AGENTS.md` should name compiler/version, dialect, source format, encoding, copybook paths and build/test commands. Require evidence for field layouts, `PERFORM THRU`, paragraph fall-through, EOF and external calls. Protect fixtures and goldens; require a minimal diff and actual command exit statuses. Missing context should produce a question, not an invented business rule.

**Run tools beside the source.** Use VS Code Remote-SSH with verified remote Codex execution, or the Codex app's SSH remote project. The latter starts a remote Codex app server and requires remote installation/authentication. Prove location with `pwd`, OS and compiler checks. SSH does not prevent selected context reaching the configured AI service. Work only in an approved development checkout, never on production data. [9], [10]

## 4. Ten concrete ways to use Codex with COBOL without lab setup

These tasks need approved source or synthetic examples, not a new VM. Execution claims still require an existing build environment.

1. **Explain a program and its data flow.** Prompt: "Read this program and its copybooks; explain inputs, paragraph flow, outputs and EOF with file:line evidence." Risk: plausible intent invented from names; distinguish observed behavior from assumptions.

2. **Build a copybook field map.** Prompt: "List level, name, PIC, USAGE, byte length, one-based offset and overlays; flag compiler-dependent sizes." Risk: wrong offsets from packed fields, alignment or variable-length records.

3. **Draft repository instructions.** Prompt: "Draft COBOL AGENTS.md from these verified build commands, format rules and fixture policy; mark unknowns." Risk: invented compiler options becoming mandatory instructions.

4. **Plan characterization tests.** Prompt: "Propose synthetic cases for empty, single, multiple, boundary and invalid records; state each expected observation." Risk: treating current behavior as proof of business correctness.

5. **Generate synthetic fixed-width data.** Prompt: "From this approved layout, draft a deterministic generator and independent length assertions; explain encoding and packed signs." Risk: confusing display widths with binary storage or adding newline bytes.

6. **Review a diff.** Prompt: "Review this patch for column overflow, continuation, periods, PIC/USAGE changes and decimal semantics; cite concrete findings." Risk: missing a shared-copybook impact or reporting speculative defects.

7. **Document JCL steps.** Prompt: "Explain JOB, EXEC and DD relationships from these sanitized files; mark unresolved procedures and substitutions." Risk: inventing scheduler, catalog or restart behavior absent from the supplied material.

8. **Map a record to Java.** Prompt: "Draft a Java record/value class and a separate codec contract; preserve padding, decimals and overlays explicitly." Risk: an attractive Java type silently losing byte-level representation or aliasing.

9. **Trace field impact.** Prompt: "Find this field's definitions, reads, writes and copybook consumers; distinguish search evidence from dynamic-call uncertainty." Risk: text search missing generated names, external consumers or runtime dispatch.

10. **Scope a migration spike.** Prompt: "Select one pure routine, draft its Java equivalent and an equivalence-test plan covering signs, scale and overflow." Risk: declaring equivalence from a small passing corpus; without both runtimes, this remains a proposal.

## 5. Practice lab recipe

**Status: not yet executed end-to-end.** Installation, remote agent execution, COBOL compilation and baseline/masked test outcomes remain **UNCONFIRMED by execution**.

Prepare a disposable AlmaLinux 9 x86-64 VM with GnuCOBOL 3.2 from EPEL 9. Fedora lists `gnucobol-3.2-1.el9`; this is an older compiler release, not a 2026 release. An administrator enables CRB/EPEL and installs the compiler and basic build tools beforehand. Record installed versions and rehearse; do not silently substitute a different package. [11], [12]

Connect through VS Code Remote-SSH and verify commands execute remotely. Use the Open Mainframe Project's `CBL0001.cobol`, pinned to revision `780b1c9624e066b9d784a738896e493282c5fbf4`. Retain CC-BY-4.0 notices and identify adaptations. The course targets z/OS; this recipe adapts one small batch example to Linux. Extract its existing input definition into a copybook and compare the adapted build with the untouched original. [9], [13], [14]

Generate entirely synthetic binary fixtures: mixed records, empty input, one record and numeric boundaries. Inspect record lengths and signs independently. Bind input/output through the documented GnuCOBOL file-mapping mechanism and verify it during rehearsal. Do not transfer packed records through a text editor. A candidate build is: [6]

```bash
mkdir -p build
cobc -x -fixed -Wall -d -I copybooks \
  -o build/accounts src/CBL0001.cobol
```

**Exercise A: analysis plus instructions.** Run the baseline, then ask for a source-backed data dictionary, paragraph-flow diagram, external-call inventory and concise `AGENTS.md`. Verify EOF and one packed-field offset manually. The upstream program has no external `CALL`; the extracted copybook is a lab adaptation. [14]

**Exercise B: characterization plus one change.** Freeze reviewed baseline files and independent field checks. Specify masking report account characters 1-4 with `****`, preserving characters 5-8 and every other byte. Prove the changed expectation fails before editing. Patch only output formatting, then compile, run every fixture and compare bytes. Confirm a deliberately corrupted temporary output is rejected. Preserve both expectation sets and review the minimal diff.

## 6. Limits

A successful GnuCOBOL lab demonstrates a workflow on one synthetic batch program. It does not prove vendor-compiler compatibility, EBCDIC collation, binary endianness, all packed signs, `REDEFINES`, variable `OCCURS`, or record-format equivalence. Dialect flags and editor diagnostics do not reproduce another runtime. [6], [8]

It also leaves CICS, Db2, VSAM, IMS, JCL execution, locking, recovery and restart untested. Passing fixtures establish agreement only for those inputs and observations. Human review and target-environment regression evidence remain necessary.

## 7. Sources

1. [OpenAI: GPT-6.1 Sol model documentation][1].
2. [OpenAI: model catalog][2].
3. [COBOLEval repository][3].
4. [COBOLAssist research paper][4].
5. [COBOL-Coder research paper][5].
6. [GnuCOBOL manual][6].
7. [IBM: reference format][7].
8. [IBM: computational items][8].
9. [Microsoft: VS Code Remote-SSH][9].
10. [OpenAI: remote connections][10].
11. [Fedora: EPEL 9 GnuCOBOL package][11].
12. [AlmaLinux: extra repositories][12].
13. [Open Mainframe Project: COBOL Programming Course][13].
14. [Pinned CBL0001 source][14].
15. [Dataconomy: OpenAI GPT-6 COBOL coding and migration gains][15].
16. [Mixed: GPT-6.1 Sol COBOL migration][16].

[1]: https://developers.openai.com/api/docs/models/gpt-6.1-sol
[2]: https://developers.openai.com/api/docs/models
[3]: https://github.com/zorse-project/COBOLEval
[4]: https://arxiv.org/abs/2604.03978
[5]: https://arxiv.org/abs/2604.03986
[6]: https://gnucobol.sourceforge.io/doc/gnucobol.html
[7]: https://www.ibm.com/docs/en/cobol-zos/6.4.0?topic=structure-reference-format
[8]: https://www.ibm.com/docs/en/cobol-linux-x86/1.2.0?topic=clause-computational-items
[9]: https://code.visualstudio.com/docs/remote/ssh
[10]: https://learn.chatgpt.com/docs/remote-connections
[11]: https://packages.fedoraproject.org/pkgs/gnucobol/gnucobol/epel-9.html
[12]: https://wiki.almalinux.org/repos/Extras
[13]: https://github.com/openmainframeproject/cobol-programming-course
[14]: https://github.com/openmainframeproject/cobol-programming-course/blob/780b1c9624e066b9d784a738896e493282c5fbf4/COBOL%20Programming%20Course%20%232%20-%20Learning%20COBOL/Labs/cbl/CBL0001.cobol
[15]: https://dataconomy.com/2026/10/20/openai-gpt-6-cobol-coding-migration-gains/
[16]: https://mixed-news.com/en/openai-gpt-6-1-sol-cobol-migration-86-percent/
