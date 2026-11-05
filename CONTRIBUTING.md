# Contributing

How to add an exercise so that the code, the tests and the report stay consistent. [`statement.pdf`](statement.pdf) is the source of truth: §2 defines the problems, §3.1 what the report must contain, §3.3 the delivery and §3.4 the grading.

`scr/kakuro/` and `content/03_05-kakuro.tex` follow every convention below; copy from them.

## Adding an exercise

1. Read your problem in §2 of the statement. Some have their own requirements: 2.3 must enumerate every sequence for a given n and add two given redundant constraints, and 2.5 must accept the input format shown.
2. Create `scr/<folder>/` and the model with the names in the README's exercise table.
3. Write the model ([Models](#models)), its tests and its `run_tests.sh` ([Tests and results](#tests-and-results)).
4. Run the tests and commit `results/`.
5. Fill the exercise's report file ([Report](#report)).
6. Write the folder's `README.txt` in Spanish: its files and how to run them. Copy the shape of `scr/kakuro/README.txt`.
7. Update the owner and status in the README's exercise table.

## Models

- Start with the header comment of `kakuro.mzn`: workshop, exercise, authors, usage line, and the meaning of each `impl` and `strategy` value.
- Two experiment parameters are set from the command line with `-D`: `impl` chooses the implementation of the constraints and `strategy` the search annotation. Each `impl` adds one element to the previous one, so the report can measure the effect of each.
- Label constraints R1, R2… (the problem's constraints), RR1… (redundant) and RS1… (symmetry breaking). Use the same labels in the code comments and in the report.
- Make domains as tight as the data allows, and validate the data with `assert`.
- Define at least two search strategies besides the default (§3.4). Sudoku and Kakuro must also compare different implementations of the constraints (§2.1, §2.2).

## Tests and results

- Tests are `.dzn` files in `tests/`, named `<model>_NN.dzn`. Include the statement's example, instances whose solution is known, larger instances that force search and, where possible, infeasible ones.
- Copy `scr/kakuro/run_tests.sh` and change `MODELO`, `IMPLS` and `ESTRATEGIAS`.
- Use the same protocol in every exercise: Gecode, 60 s per run, and the goal of finding the first solution or proving there is none (`-a` to enumerate on small instances). The main metric is nodes, because it does not depend on the machine; also report failures, peak depth, solve time and compile time.
- Commit the CSVs. Every number in the report must come from them or from a run you describe.

## Report

- Written in Spanish, as an APA 7 student paper (`apa7` class in `stu` mode). `make` must finish with no errors.
- Each exercise file already has the headings §3.1 asks for; keep them and fill them in. `\subsection` is the exercise, `\subsubsection` a part, `\paragraph` a part of the model.
- APA headings are not numbered: refer to a section by its name ("ver Análisis de resultados"), never by a number.
- Tables: a `table` float with `\caption` and then `\label{tab:<exercise>-<what>}`, booktabs rules, and `tabularx` with the `L` column for text that wraps. Mention every table in the text as `Tabla~\ref{...}`.
- Images go in `assets/` and are included by file name. Search-tree screenshots come from Gecode Gist.
- Math goes inside `$...$` or `\[...\]`. Unicode symbols such as ∈, ≤, × or ᵢ make pdflatex fail.
- Numbers in Spanish format: `0,2~s`, `12\,058`. Code names in `\texttt{}`, with `\_` for underscores.
- Citations: add the entry to `bibliography.bib` and cite with `\parencite{key}` or `\textcite{key}`.
- `apa7` already loads graphicx, booktabs, longtable, caption, float and hyperref. Don't load them again; hyperref options go in `\hypersetup`.

## Grading (statement §3.4)

| Criterion | Points | What it asks for |
|---|---|---|
| Variables | 10 | Precise meaning and domain for each variable. Parameters are never confused with variables, and domains exclude values known to be impossible. |
| Constraints | 15 | Every constraint of the problem, stated formally and independently of the implementation, justified when not obvious. Constraints conditioned on variable values only when there is no alternative. |
| Symmetry breaking | 10 | Which symmetries are broken and how to recover the lost solutions; if there are none, a paragraph explaining why. |
| Redundant constraints | 10 | Why they are redundant and why they prune; if there are none, a paragraph explaining why. |
| Search strategies | 15 | At least two annotations besides the default, compared with MiniZinc's statistics (nodes, failures, time). |
| Tests | 5 | Enough instances to verify correctness and compare strategies, with results in tables or charts. |
| Coherence | 25 | The models, the implementations and the analyses in the report match each other. |
| Writing | 10 | Complete, clear, precise and well presented, with the main analyses and conclusions. |

## Working together

- Each person works in their own `scr/<exercise>/` and `content/03_0N-*.tex`. Those files never conflict.
- `main.tex`, `preamble.tex`, `front_page.tex` and the shared sections are changed by agreement. Adding entries to `bibliography.bib` is fine.
- Before pushing, run `make`; `grep -E '^!|undefined' build/main.log` should print nothing.

## Delivery (statement §3.3)

One member uploads a zip, named as §3.3 says, that contains:

1. `Readme.txt`: every file delivered and how to run it. Build it from the `scr/*/README.txt` files.
2. `InformeTaller1.pdf`: `build/main.pdf`, renamed.
3. Every `.mzn` and `.dzn` file.

`statement.pdf` is the March 2024 edition: check its deadline, group size and zip name against the current course announcement.

## For AI assistants

- Read `statement.pdf` before writing a model or a report section, and use the Kakuro files as the template.
- Stay inside the exercise you were asked about; say so before changing shared files.
- Never put a number in the report that isn't in a results CSV or a run you executed.
- Check the work: `make` for the report, `run_tests.sh` or `minizinc` for the models.
