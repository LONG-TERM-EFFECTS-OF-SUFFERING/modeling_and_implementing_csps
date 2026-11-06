# Modeling and implementing CSPs

Workshop 1 (*Taller 1: Modelamiento e implementación de CSPs*) of *Programación por Restricciones*, Universidad del Valle. Six problems are modeled as constraint satisfaction problems, implemented in MiniZinc, tested, and written up in one LaTeX report.

[`statement.pdf`](statement.pdf) is the assignment. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before adding an exercise.

## Members

- Brandon Calderón Prieto (2125974).

- Orlando Alexis Rengifo Mejia (2223878).

-

## Exercises

| § | Problem | Model file | Code folder | Report section | Owner | Status |
|---|---|---|---|---|---|---|
| 2.1 | Sudoku | `sudoku.mzn` | `scr/sudoku/` | `content/03_03-sudoku.tex` | Santiago | Done |
| 2.2 | Kakuro | `kakuro.mzn` | `scr/kakuro/` | `content/03_05-kakuro.tex` | Brandon | Done; Gist screenshots missing |
| 2.3 | Secuencia mágica | `secuencia.mzn` | `scr/magical_sequence/` | `content/03_02-magical_sequence.tex` | Santiago | Done |
| 2.4 | Acertijo lógico | `acertijo.mzn` | `scr/logic_puzzle/` | `content/03_01-logic_puzzle.tex` | Alexis | Code and tests done; report pending |
| 2.5 | Ubicación de personas en una reunión | `reunion.mzn` | `scr/meeting/` | `content/03_04-meeting.tex` | Alexis | Code and tests done; report pending |
| 2.6 | Construcción de un rectángulo | `rectangulo.mzn` | `scr/rectangle/` | `content/03_06-rectangle.tex` | Brandon | Done; Gist screenshots missing |

§ is the section of the statement. The report presents the exercises in the order of their report files (03_01 to 03_06).

## Repository layout

```text
.
├── statement.pdf             assignment
├── main.tex                  report entry point: front page + content/
├── preamble.tex              packages and macros
├── front_page.tex            APA title-page fields: title, authors, course, professor
├── bibliography.bib          references
├── content/                  one .tex file per report section
├── assets/                   images for the report
├── scr/<exercise>/           one folder per exercise
├── Makefile, .latexmkrc      report build
└── build/                    LaTeX output (gitignored)
```

Every exercise folder has the same shape:

```text
scr/kakuro/
├── kakuro.mzn                model
├── tests/kakuro_NN.dzn       test instances
├── run_tests.sh              runs every test × impl × strategy
├── results/kakuro_gecode.csv statistics of every run
└── README.txt                files and how to run them (Spanish, part of the delivery)
```

## Requirements

- MiniZinc 2.9 or later, full bundle (includes Gecode and Chuffed).
- Bash for `run_tests.sh`; on Windows, Git Bash or WSL.
- A LaTeX distribution with `latexmk`, `biber`, `apa7` and `biblatex-apa`. A full TeX Live install has all of them.
- Optional: VS Code with LaTeX Workshop, which builds, formats and lints on save.

## Running

```sh
# One instance (-s prints statistics, -a enumerates all solutions)
cd scr/kakuro
minizinc --solver gecode -s kakuro.mzn tests/kakuro_01.dzn -D "impl=3;strategy=3"

# Every test with every impl and strategy (defaults: gecode, 60000 ms per run).
# Overwrites results/<model>_<solver>.csv.
./run_tests.sh [solver] [timeout_ms]

# Report, from the repository root
make          # writes build/main.pdf
latexmk -C    # removes the build output
```

## Open items

- [ ] `front_page.tex`: teammates' names, course name and professor. The statement names Juan Francisco Díaz Frías; the front page currently says Robinson Andrey Duque Agudelo.
- [ ] Introducción and Metodología experimental sections (`content/01-introduction.tex`, `content/02-experimental_methodology.tex`).
- [ ] Gecode Gist screenshots for Kakuro and rectangle (marked `% TODO Figura` in their report files).
- [ ] Exercises 2.1 and 2.3; report sections for 2.4 and 2.5.
