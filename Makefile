PAGER ?= less
EDITOR ?= vi

PDFLATEX = pdflatex
BIBTEX = bibtex
MPOST = mpost
ISPELL = ispell

PDFLATEXFLAGS = -interaction=nonstopmode
BIBTEXFLAGS =
MPOSTFLAGS = -interaction=nonstopmode
ISPELLFLAGS = -t -b -d american

SRC-tex = haiku-3.tex
SRC-bib = haiku-3.bib
SRCS-mp = ${shell find figs -name '*.mp'}

JOB-tex = ${SRC-tex:.tex=}
JOB-bib = ${SRC-bib:.bib=}
JOBS-mp = ${SRCS-mp:.mp=}

SRCS-all = ${SRC-tex} ${SRCS-mp}
PDF = ${SRC-tex:.tex=.pdf}
MPSS = ${SRCS-mp:.mp=.mps}

CLEANFILES = ${shell find . -name '*.log' -o -name '*.mpx' -o -name '*.mps' \
			-o -name '*.aux' -o -name '*.pdf' -o -name '*.bbl' \
			-o -name '*.blg' -o -name '*.dvi' }

all: pdf

# Keep intermediates
.SECONDARY:

.PHONY: all pdf figs edit page clean spell

pdf: figs ${SRC-tex} ${SRC-bib}
	${PDFLATEX} ${PDFLATEXFLAGS} ${JOB-tex}
	${BIBTEX} ${BIBTEXFLAGS} ${JOB-bib}
	${PDFLATEX} ${PDFLATEXFLAGS} ${JOB-tex}
	${PDFLATEX} ${PDFLATEXFLAGS} ${JOB-tex}

figs: ${SRCS-mp}
	for mpjob in ${JOBS-mp} ; do \
	    ( \
		cd `dirname $${mpjob}` ; \
		${MPOST} ${MPOSTFLAGS} `basename $${mpjob}` ; \
	    ) ; \
	    if [ "$$?" -ne "0" ] ; then exit 1 ; fi ; \
	done

edit: ${SRCS-all}
	${EDITOR} $^

page: ${SRCS-all}
	${PAGER} $^

spell: ${SRC-tex}
	${ISPELL} ${ISPELLFLAGS} $^

clean:
	-rm -f ${CLEANFILES}
