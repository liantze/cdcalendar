# Customisable multilingual calendars with LaTeX

The calendars are printed 4-up to fit 3.5" floppy disk jewel cases, or 2-up to fit CD jewel cases. There is now also a full-page version for wall calendars. (Updated Dec, 2016).

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

slovak works if you add `\shorthandoff{-}` after `\begin{document}`.

(Use lualatex for french or fontspec. If using `pdflatex` for greek, remember to load `LGR,T1` for `fontenc`.)

An example of a month calendar with events (syntax updated in v1.2):

    \begin{monthCalendar}{2015}{10}

    %% This is a 1-day event
    \event{2015-10-25}{}{Daylight saving time ends}

    %% This is a 5-day event starting Oct 26th
    \event{2015-10-26}{5}{Autumn half-term holiday}

    %% You could also write
    %\event{2015-10-26}{2015-10-30}{Autumn half-term holiday}
    \end{monthCalendar}
    \clearpage %% Do remember this; I guess I could have made it automatic but well.

The events mark and style can be customised: (All `\tikzset` styles for use with
`mark style` should be issued in the document preamble; new in v1.2)

    % In the preamble
    \tikzset{blue icon/.style={text=SkyBlue!60,font=\large}}
    % In the monthCalendar
    \event[mark style=blue icon, marker=\faCake]{2015-10-10}{Someone's birthday}

Currently the value for `mark style` must be a single style name.

You can add an illustration on each page (the length is the width of the image):

    \illustration[image caption]{8.5cm}{filename.png}

...or in fact you could insert anything that'll be typeset as a minipage: (new in v1.2)

    \otherstuff[caption]{8.5cm}{\Huge Perhaps a Smart Quote Here?}

As mentioned above, some language names are recognised for automatically translating the month names and week day headings. However there are cases where you might want to do this yourself, either because the language isn't supported by babel and translator, or because the language doesn't lend itself well to having the first letter extracted for the week day headings (e.g. Chinese). In this case you can pass the `nobabel` to `\documentclass{cdcalendar}`, and proceed to do your own modifications. See `ChineseCalendar.tex` and `zh-mod.sty` for an example.

See [this blog post](https://www.overleaf.com/blog/217-a-multilingual-customisable-cd-slash-floppy-disk-jewel-case-calendar-with-latex) for more information (syntax of some commands have changed though),
or open and edit a [CD-sized](https://www.overleaf.com/read/htkctjjgmxjx), [floppy disk-sized](https://www.overleaf.com/read/vtqtzgbcvmbg) or [full-page](https://www.overleaf.com/read/csttbxxjydvz) calendar template on Overleaf.
