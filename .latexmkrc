$pdf_mode = 1;

$out_dir = 'build';

$pdflatex = 'pdflatex -halt-on-error -file-line-error '
          . '-interaction=nonstopmode %O %S';

$bibtex_use = 2;

@default_files = ('main.tex');
