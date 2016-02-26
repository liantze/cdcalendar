# Customisable multilingual calendars with LaTeX

The calendars are printed 4-up to fit 3.5" floppy disk jewel cases, or 2-up to fit CD jewel cases. There is now also a full-page version for wall calendars. (Updated February 26, 2016).

![actual.jpg](https://bitbucket.org/repo/j59y5j/images/4048533618-actual.jpg)

Colours, illustrations, fonts etc are customisable. The calendars can be marked with events with date ranges (updated June 22, 2015).

Localisation possible with languages supported by babel/translator/datetime2.

Tested with british, spanish, french, ngerman, italian, portuges, polish, croatian, greek, bahasai, bahasam.

bahasai (Indonesian) works with the following new or modified files in this project:

- translator-language-mappings.tex
- translator-months-dictionary-Indonesian.dict
- datetime2-bahasai.ldf

bahasam (Bahasa Malaysia) works with the following new or
modified files in this project:

- translator-language-mappings.tex
- translator-months-dictionary-Malaysian.dict
- datetime2-bahasam.ldf

(Use lualatex for french. If using `pdflatex` for greek, remember to load `LGR,T1` for `fontenc`.)

See [this blog post](https://www.overleaf.com/blog/217-a-multilingual-customisable-cd-slash-floppy-disk-jewel-case-calendar-with-latex) for more information, or open and edit a [CD-sized](https://www.overleaf.com/read/htkctjjgmxjx), [floppy disk-sized](https://www.overleaf.com/read/vtqtzgbcvmbg) or [full-page](https://www.overleaf.com/read/csttbxxjydvz) calendar template on Overleaf.