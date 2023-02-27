(TeX-add-style-hook
 "ParallelProgramming"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("beamer" "pdflatex" "colorlinks" "landscape")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("babel" "english") ("inputenc" "latin1") ("fontenc" "T1") ("xy" "all" "cmtip")))
   (add-to-list 'LaTeX-verbatim-environments-local "semiverbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "SaveVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "VerbatimOut")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "Verb")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "Verb*")
   (TeX-run-style-hooks
    "latex2e"
    "beamer"
    "beamer10"
    "etex"
    "mathtools"
    "babel"
    "inputenc"
    "times"
    "fontenc"
    "graphicx"
    "wrapfig"
    "algorithmicx"
    "epsfig"
    "tikz"
    "tikz-qtree"
    "listings"
    "color"
    "algorithm"
    "algpseudocode"
    "fancyvrb"
    "caption"
    "subcaption"
    "xy")
   (TeX-add-symbols
    '("emph" 1)
    '("mat" 1)
    '("vec" 1)
    "ints"
    "nats"
    "rats"
    "reals"
    "complex"
    "disk"
    "torus"
    "proj"
    "reducesto"
    "implies"
    "Id"
    "Prob"
    "Expect"
    "calC"
    "calD"
    "F"
    "P")
   (LaTeX-add-xcolor-definecolors
    "mygreen"
    "mylilas"))
 :latex)

