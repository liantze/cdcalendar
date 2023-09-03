\ProvidesClass{cdcalendar}[2021/08/28 CD Calendar 1.4.3 by LianTze LIM (liantze@gmail.com)]


\newif\if@smallcal\@smallcalfalse
\newif\if@giantcal\@giantcalfalse
\newif\if@prevnext\@prevnextfalse
\newif\if@landscapecal\@landscapecalfalse

\DeclareOption{small}{
  \@smallcaltrue
  \@giantcalfalse
}

\DeclareOption{giant}{
  \@smallcalfalse
  \@giantcaltrue
  \@prevnexttrue
}

\DeclareOption{giantsolo}{
  \@smallcalfalse
  \@giantcaltrue
  \@prevnextfalse
}

\DeclareOption{landscape}{
  \if@giantcal
    \@landscapecaltrue
  \else
    \ClassWarning{cdcalenar}{Sorry, `landscape' option only supported with `giant' and `giantsolo'}
  \fi
}


\newif\if@babel\@babeltrue
\DeclareOption{nobabel}{
  \@babelfalse
}

\newif\if@sundayweek\@sundayweekfalse
\def\@daynumlist{0/0,1/1,2/2,3/3,4/4,5/5,6/6}
\DeclareOption{sundayweek}{
  \@sundayweektrue
  \def\@daynumlist{0/6,1/0,2/1,3/2,4/3,5/4,6/5}
}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\ProcessOptions\relax
\LoadClass{extarticle}

\RequirePackage[dvipsnames,svgnames]{xcolor}
\newlength{\CalPageMargin}
\newlength{\EventLineWidth}

% v1.3.4 Load babel and translator even earlier
\if@babel
  \RequirePackage{babel}
  \RequirePackage{translator}
  \languagealias{british}{English}
\else
  \RequirePackage{translator}
  \providetranslation{Sunday}{S}
  \providetranslation{Monday}{S}
  \providetranslation{Tuesday}{T}
  \providetranslation{Wednesday}{W}
  \providetranslation{Thursday}{T}
  \providetranslation{Friday}{F}
  \providetranslation{Saturday}{S}
  \AtBeginDocument{\renewcommand*{\DTMdisplaydate}[4]{\number#3/\number#2}}
\fi

%% v1.3.3. Load pgfpages early
\RequirePackage{geometry}
\RequirePackage{pgfpages}
\if@giantcal
  \setlength{\CalPageMargin}{1cm}
  \setlength{\EventLineWidth}{6in}
  \geometry{margin=\CalPageMargin}
\else
  \setlength{\EventLineWidth}{3in}
  \if@smallcal
    \setlength{\CalPageMargin}{0.3cm}
    \geometry{paperheight=9.5cm,paperwidth=9cm,margin=\CalPageMargin}
    \pgfpagesuselayout{4 on 1}[a4paper]
    \pgfpageslogicalpageoptions{1}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\pgfstroke
    }
    \pgfpageslogicalpageoptions{2}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\pgfstroke
    }
    \pgfpageslogicalpageoptions{3}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\pgfstroke
    }
    \pgfpageslogicalpageoptions{4}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\pgfstroke
    }
  \else
    \setlength{\CalPageMargin}{0.5cm}
    \geometry{paperheight=13.65cm,paperwidth=11.7cm,margin=\CalPageMargin}
    \RequirePackage{pgfpages}
    \pgfpagesuselayout{2 on 1}[a4paper,landscape]
    \pgfpageslogicalpageoptions{1}{
        resized width=11.7cm,
        resized height=13.65cm,
        border code=\pgfsetlinewidth{0.4pt}\pgfstroke
    }
    \pgfpageslogicalpageoptions{2}{
        resized width=11.7cm,
        resized height=13.65cm,
        border code=\pgfsetlinewidth{0.4pt}\pgfstroke
    }
  \fi
\fi
\if@landscapecal
  \setlength{\EventLineWidth}{\linewidth}
  \geometry{landscape,left=.3\paperheight}
\fi

\RequirePackage{ifxetex}
\RequirePackage{xstring}

\RequirePackage{tikz}
\usetikzlibrary{babel,calendar,positioning,backgrounds,shapes}
\RequirePackage[useregional,showdow]{datetime2}
\DTMlangsetup{abbr,ord=raise,showyear=false}
\RequirePackage{url}
% \urlstyle{rm}
\renewcommand{\UrlFont}{\rmfamily}
\RequirePackage{regexpatch}
\RequirePackage{xargs}
\RequirePackage{pgfkeys}
\RequirePackage[absolute,overlay]{textpos}
\RequirePackage[nopagecolor=white,pagecolor=white]{pagecolor}

\def\@coverBgColor{white}
\def\@coverImage{}
\def\@coverImageCaption{}
\def\@coverTitleText{}
\tikzset{coverTitleOptions/.style={font=\Huge\sffamily}}
\tikzset{dayHeadingsOptions/.style={font=\sffamily\bfseries,gray!90}}
\def\@sundayColor{red}
\tikzset{monthTitleOptions/.style={font={\fontsize{40pt}{42pt}\bfseries\sffamily\itshape\selectfont}, red!50!RedViolet}}
\def\@eventStyle{}
\newcommand\printeventname[1]{\textbf{#1}}
\def\eventSep{: }

\newcommand\coverBgColor[1]{%
  % \ifxetex%
  % \ClassWarning{cdcalendar}{xelatex may not work correctly with cdcalendar especially if you use \noexpand\coverBgColor! Compile with xelatex instead.}
  % \fi%
  \def\@coverBgColor{#1}%
}
\newcommand\coverImage[2][]{\def\@coverImageCaption{#1}\def\@coverImage{#2}}
\newcommand\coverTitle[2][]{
    \notblank{#1}{\tikzset{coverTitleOptions/.style={#1}}}{}
  \def\@coverTitleText{#2}
}

\newcommand\makeCover{%
  \begingroup%
  \ifnum\pgf@logicalpages=0\relax
    \pagecolor{\@coverBgColor}%
  \else
    \ifx\@Gm@driver\@Gm@dvipdfm
      \typeout{I see you dvipdfm}
      \tikz[remember picture,overlay]
      \fill[\@coverBgColor] (current page.north west) rectangle (current page.south east);%
    \else
      \pagecolor{\@coverBgColor}%
    \fi%
  \fi%
  \ifdefempty{\@coverImage}{}{%
    \begin{textblock*}{\paperwidth}(0pt,0pt)%
    \tikz\node[rectangle split, rectangle split parts=2,
      rectangle split part align={left,left},
      text width=\paperwidth,
      font=\tiny\itshape,inner sep=0pt] {%
      \includegraphics[width=\paperwidth]{\@coverImage}
      \nodepart{second}%
      \space\begin{minipage}{\dimexpr\hsize-0.5em}\vskip0.5ex%
      \@coverImageCaption\par\end{minipage}};
  \end{textblock*}}
  \begin{textblock*}{\paperwidth}[1,1](\dimexpr\paperwidth-2ex\relax,\dimexpr\paperheight-2ex\relax)
    \noindent\tikz\node[coverTitleOptions,inner sep=0pt] {\@coverTitleText};
  \end{textblock*}
  \endgroup\null\clearpage\nopagecolor\normalsize%
}

%%%%%%%%
% Using code from http://tex.stackexchange.com/a/245279/226
% \if@babel
  %% v1.3.3 After 2019/01/10, \pgfcalendarweekname uses
  %% \pgfutil@translate instead of \xtranslate.
  \let\xpgfcalendarweekdayname\pgfcalendarweekdayname
  %% After 2019/01/10
  \xpatchcmd{\xpgfcalendarweekdayname}
     {\pgfutil@translate}
     {\xtranslate}
     {}{}

  \newcommand{\xtranslate}[1]{%
    \csname tr@@@\csname tr@ml@\languagename\endcsname @#1\endcsname
  }
% \fi

%%%%%%%%%
% Code from http://tex.stackexchange.com/a/10199/226
\tikzstyle{day heading}=[]
\tikzstyle{day letter headings}=[
    execute before day scope={ \ifdate{day of month=1}{%
      \pgfmathsetlength{\pgf@ya}{\tikz@lib@cal@yshift}%
      \pgfmathsetlength\pgf@xa{\tikz@lib@cal@xshift}%
      \pgftransformyshift{-\pgf@ya}
      \foreach \n/\d in \@daynumlist {
        \if@babel
          \StrLeft{\xpgfcalendarweekdayname{\d}}{1}[\theD]
        \else
          \def\theD{\pgfcalendarweekdayname{\d}}
        \fi
        \pgf@xa=\n\pgf@xa%
        \pgftransformxshift{\pgf@xa}%
        \pgftransformyshift{\pgf@ya}%
        \node[every day,dayHeadingsOptions]{\theD};%
      }
    }{}%
  }%
]
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%
% Code from http://www.texample.net/tikz/examples/changing-the-default-calendar-layout/
% for weeks to start on Sunday
\tikzstyle{week list sunday}=[
  % Note that we cannot extend from week list,
  % the execute before day scope is cumulative
  execute before day scope={%
    \ifdate{day of month=1}{\ifdate{equals=\pgfcalendarbeginiso}{}{
    % On first of month, except when first date in calendar.
       \pgfmathsetlength{\pgf@y}{\tikz@lib@cal@month@yshift}%
       \pgftransformyshift{-\pgf@y}
    }}{}%
  },
  execute at begin day scope={%
    % Because for TikZ Monday is 0 and Sunday is 6,
    % we can't directly use \pgfcalendercurrentweekday,
    % but instead we define \c@pgf@counta (basically) as:
    % (\pgfcalendercurrentweekday + 1) % 7
    \pgfmathsetlength\pgf@x{\tikz@lib@cal@xshift}%
    \ifnum\pgfcalendarcurrentweekday=6
      \c@pgf@counta=0
    \else
      \c@pgf@counta=\pgfcalendarcurrentweekday
      \advance\c@pgf@counta by 1
    \fi
    \pgf@x=\c@pgf@counta\pgf@x
    % Shift to the right position for the day.
    \pgftransformxshift{\pgf@x}
  },
  execute after day scope={
    % Week is done, shift to the next line.
    \ifdate{Saturday}{
      \pgfmathsetlength{\pgf@y}{\tikz@lib@cal@yshift}%
      \pgftransformyshift{-\pgf@y}
    }{}%
  },
  % This should be defined, glancing from the source code.
  tikz@lib@cal@width=7
]
%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand\dayHeadingStyle[1]{\tikzset{dayHeadingsOptions/.style={#1}}}
\newcommand\sundayColor[1]{\def\@sundayColor{#1}}
\newcommand\monthTitleStyle[1]{\tikzset{monthTitleOptions/.style={#1}}}
\newcommand\eventStyle[1]{\def\@eventStyle{#1}}

\pgfkeys{
  /eventmark/.is family, /eventmark,
  default/.style = {
    marker = {},
    mark style = {}
  },
  marker/.store in = \event@marker,
  mark style/.store in = \event@markstyle
}%

\newcommand{\printdate}[1]{\DTMdate{#1}}

\def\@eventlist{}
\newcounter{cdcalaux@next@page}
\newcounter{cdcalaux@prev@page}
\newwrite\cdcalaux@next@file
\newwrite\cdcalaux@prev@file

\newenvironment{monthCalendar}[2]{%
  \tracinglostchars=0\relax%
  \setcounter{cdcalaux@next@page}{\value{page}}%
  \stepcounter{cdcalaux@next@page}%
  \setcounter{cdcalaux@prev@page}{\value{page}}%
  \addtocounter{cdcalaux@prev@page}{-1}%
  \if@prevnext
    \immediate\openout\cdcalaux@next@file=\jobname-p\thecdcalaux@next@page-p.calaux
    \immediate\openout\cdcalaux@prev@file=\jobname-p\thecdcalaux@prev@page-n.calaux
  \fi%
  \begin{textblock*}{\textwidth}[1,1](\paperwidth,\paperheight)
    \raggedleft\tiny\color{black!70}
    \begin{tikzpicture}[remember picture]
    \node[rotate=-90,transform shape,monthTitleOptions, inner sep=\CalPageMargin] (mainMonthHead)
    {\pgfcalendarmonthname{#2} #1};
    \if@giantcal\if@prevnext\begingroup%
    \tikzset{every calendar/.append style={
        day yshift=1.5em,month label above centered,
        \if@sundayweek week list sunday\else week list\fi,
        day xshift=1.5em,day letter headings},
      % dayHeadingsOptions/.append style={yshift=0.25em},
      dayHeadingsOptions/.style={font=\sffamily\bfseries,gray!90},
      every day/.append style={align=center,font={\mdseries\sffamily},text width=1.5em},every month/.append style={font=\sffamily\mdseries}}
    \matrix[row sep=2em,matrix anchor=south east,left=0pt of mainMonthHead.south east,yshift=\CalPageMargin]{%
      \pgfmathsetmacro{\tmpmonth}{int(\number#2-1)}%
      \calendar (cdCal-\thepage-prev) [dates=#1-\tmpmonth-01 to #1-\tmpmonth-last];\\
      \pgfmathsetmacro{\tmpmonth}{int(\number#2+1)}%
      \calendar (cdCal-\thepage-next) [dates=#1-\tmpmonth-01 to #1-\tmpmonth-last];\\
    };
    \endgroup\fi\fi
  \end{tikzpicture}
  \end{textblock*}%
  % \begin{textblock*}{\textwidth}[0,1](0pt,\paperheight)
  \begin{textblock*}{\textwidth}[0,1](
      \if@landscapecal\dimexpr\Gm@lmargin-\CalPageMargin\relax
      \else 0pt\fi,
      \paperheight)
  \noindent\begin{tikzpicture}[remember picture]
  \calendar (cdCal-\thepage) [
    dates=#1-#2-01 to #1-#2-last,
    month text = {\%mt \%y-},
    inner sep=\CalPageMargin,
    \if@sundayweek week list sunday\else week list\fi,
    day xshift=2.75em,
    every day/.append style={text height=1.5ex,text depth=0.25ex,text width=1.5em,align=flush center,font={\bfseries}},
    day letter headings
    ]
    if (Sunday) [\@sundayColor];
  \end{tikzpicture}
  \end{textblock*}%
%
  \gdef\@eventlist{}%
%
  \begin{tikzpicture}[remember picture,overlay]
%
    \newcommand{\markCalendar}[2][]{%
      \pgfkeys{/eventmark,default,##1}%
      \DTMsavedate{tmp}{##2}%
      \@ifundefined{pgf@sh@ns@cdCal-\thepage-##2}{}{%
        % \begin{tikzpicture}[overlay,remember picture]%
        \begin{scope}[on background layer]
        \node[inner sep=1.25ex,\event@markstyle]
          at (cdCal-\thepage-##2) {\event@marker};%
        \end{scope}%
        % \end{tikzpicture}%
      }%
      %%% crossing fingers again...
      \if@prevnext
        \immediate\write\cdcalaux@next@file{%
          \noexpand\@ifundefined{pgf@sh@ns@cdCal-\thecdcalaux@next@page-prev-##2}{}{
          \noexpand\node[transform shape,scale=0.4,inner sep=1.25ex,\expandonce\event@markstyle]
            at (cdCal-\thecdcalaux@next@page-prev-##2) {\expandonce\event@marker};%
          }
        }
        % 
        \immediate\write\cdcalaux@prev@file{%
          \noexpand\@ifundefined{pgf@sh@ns@cdCal-\thecdcalaux@prev@page-next-##2}{}{
          \noexpand\node[transform shape,scale=0.4,inner sep=1.25ex,\expandonce\event@markstyle]
            at (cdCal-\thecdcalaux@prev@page-next-##2) {\expandonce\event@marker};%
          }
        }
      \fi
    }
%
    % #1=style; #2=startdate; #3=enddate or days; #4=name
    \newcommand{\event}[4][mark style=default mark]{%
      \ifblank{##3}{\oneDayEvent[##1]{##2}{##4}}{%
        \ifboolexpr{ test {\ifstrequal{##2}{##3}}
                  or test {\ifdefequal{##2}{##3}}
                  or test {\ifdefstring{##3}{1}}}
                   {\oneDayEvent[##1]{##2}{##4}}%
                   {\multiDayEvent[##1]{##2}{##3}{##4}}%
        }%
    }
%
    % #1=style; #2=startdate; #4=name
    \newcommand{\oneDayEvent}[3][mark style=default mark]{%
      \pgfkeys{/eventmark,default,##1}%
      \markCalendar[##1]{##2}%
      \protected@xappto{\@eventlist}{%
        \makebox[1.75em][c]{\protect\tikz%
          \protect\node[\event@markstyle,font=\fontsize{1em}{1em},%
          \ifdefempty{\event@marker}{inner sep=0.5ex}{inner sep=0pt},
  ]{\event@marker};}%
        \printeventname{##3\eventSep}\DTMdate{##2}\par%
      }{}{}
    }
%
    % #1=style; #2=startdate; #3=enddate or days; #4=name
    \newcommand{\multiDayEvent}[4][mark style=default mark]{%
      \IfInteger{##3}%
        {\multiDayEventWithDuration[##1]{##2}{##3}{##4}}%
        {\multiDayEventWithEnd[##1]{##2}{##3}{##4}}%
    }
%
    % #1=style; #2=startdate; #3=days; #4=name
    \newcommand{\multiDayEventWithDuration}[4][mark style=default mark]{%
      \pgfkeys{/eventmark,default,##1}%
      \pgfmathparse{##3-1}%
      \foreach \d in {0,...,\pgfmathresult}{%
      	\DTMsavedate{tmp}{##2+\d}%
        \DTMmakeglobal{tmp}%
      	\markCalendar[##1]{\DTMfetchyear{tmp}-\DTMfetchmonth{tmp}-\DTMfetchday{tmp}}%
      }%
      \protected@xappto{\@eventlist}{%
        \makebox[1.75em][c]{\protect\tikz%
          \protect\node[\event@markstyle,font=\fontsize{1em}{1em},%
          \ifdefempty{\event@marker}{inner sep=0.5ex}{inner sep=0pt},%
          ]{\event@marker};}%
        \printeventname{##4\eventSep}\DTMdate{##2}\,--\,\DTMusedate{tmp}\par}{}{}%
    }
%
    % #1=style; #2=startdate; #3=enddate; #4=name
    \newcommand{\multiDayEventWithEnd}[4][mark style=default mark]{%
      \DTMsavedate{startdate}{##2}%
      \DTMsavedate{enddate}{##3+1}%
      \newcount\myct%
      \DTMsaveddatediff{enddate}{startdate}{\myct}%
      \multiDayEventWithDuration[##1]{##2}{\myct}{##4}%
    }
}{%
  \end{tikzpicture}%
  \noindent\begin{minipage}{\EventLineWidth}\@eventStyle%
  \setlength{\parskip}{0.5ex}%
  \@eventlist%
  \end{minipage}%
  \if@prevnext
    \immediate\closeout\cdcalaux@next@file
    \immediate\closeout\cdcalaux@prev@file
    \makeatletter
    \begin{tikzpicture}[remember picture,overlay]
    \begin{scope}[on background layer]
    \IfFileExists{\jobname-p\thepage-p.calaux}{\input{\jobname-p\thepage-p.calaux}}{}
    \IfFileExists{\jobname-p\thepage-n.calaux}{\input{\jobname-p\thepage-n.calaux}}{}
    \end{scope}
    \end{tikzpicture}
    \makeatother
  \fi
}


\tikzset{default mark/.style={circle,draw=red!50}}

\newlength\illusSkip
\setlength{\illusSkip}{1em}

\newcommand{\illustration}[3][]{%
  \if@landscapecal
  \begin{textblock*}{\paperwidth}(\CalPageMargin,\CalPageMargin)
  \fi%
  \tikz\node[rectangle split, rectangle split parts=2,
    rectangle split part align={left,left},
    text width=#2,inner xsep=0pt, inner ysep=1pt, font=\itshape\tiny]
  {\includegraphics[width=#2]{#3} \nodepart{second} #1};\par
  \vspace*{\illusSkip}%
  \if@landscapecal
  \end{textblock*}
  \fi%
}

\newcommand{\otherstuff}[3][]{%
  \if@landscapecal
  \begin{textblock*}{\paperwidth}(\CalPageMargin,\CalPageMargin)
  \fi%
  \tikz\node[rectangle split, rectangle split parts=2,
    rectangle split part align={left,left},
    text width=#2,inner xsep=0pt,inner ysep=3pt,font=\itshape\tiny]
  {#3 \nodepart{second} #1};\par
  \vspace*{\illusSkip}%
  \if@landscapecal
  \end{textblock*}
  \fi%
}

\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
