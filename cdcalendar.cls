\ProvidesClass{cdcalendar}[2016/12/15 CD Calendar 1.2 by LianTze LIM (liantze@gmail.com)]


\newif\if@smallcal\@smallcalfalse
\newif\if@giantcal\@giantcalfalse

\DeclareOption{small}{
  \@smallcaltrue
  \@giantcalfalse
}

\DeclareOption{giant}{
  \@smallcalfalse
  \@giantcaltrue
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

\if@giantcal
  \ExecuteOptions{20pt}
\else
  \ExecuteOptions{10pt}
\fi
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\ProcessOptions\relax
\LoadClass{extarticle}

\RequirePackage[dvipsnames,svgnames]{xcolor}
\newlength{\CalPageMargin}
\newlength{\EventLineWidth}

\if@giantcal
  \setlength{\CalPageMargin}{1cm}
  \setlength{\EventLineWidth}{6in}
  \RequirePackage[margin=\CalPageMargin]{geometry}
\else
  \setlength{\EventLineWidth}{3in}
  \if@smallcal
    \setlength{\CalPageMargin}{0.3cm}
    \RequirePackage[paperheight=9.5cm,paperwidth=9cm,margin=\CalPageMargin]{geometry}
    \RequirePackage{pgfpages}
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
    \RequirePackage[paperheight=13.65cm,paperwidth=11.7cm,margin=\CalPageMargin]{geometry}
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


\RequirePackage{ifxetex}
\RequirePackage{xstring}

\ifxetex
  \ClassError{cdcalendar}{xelatex will not work correctly with cdcalendar!}{%
  Compile using lualatex instead.}
\fi

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

\RequirePackage{tikz}
\usetikzlibrary{calendar,positioning,backgrounds,shapes}
\RequirePackage[useregional,showdow]{datetime2}
\DTMlangsetup{abbr,ord=raise,showyear=false}
\RequirePackage{url}
% \urlstyle{rm}
\renewcommand{\UrlFont}{\rmfamily}
\RequirePackage{xpatch}
\RequirePackage{xargs}
\RequirePackage{pgfkeys}

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

\newcommand\coverBgColor[1]{\def\@coverBgColor{#1}}
\newcommand\coverImage[2][]{\def\@coverImageCaption{#1}\def\@coverImage{#2}}
\newcommand\coverTitle[2][]{
    \notblank{#1}{\tikzset{coverTitleOptions/.style={#1}}}{}
  \def\@coverTitleText{#2}
}

\newcommand\makeCover{%
{\pagecolor{\@coverBgColor}
\begin{tikzpicture}[overlay,remember picture]
  \ifdefempty{\@coverImage}{}{
    \node[rectangle split, rectangle split parts=2,
    rectangle split part align={left,left},
    text width=\dimexpr\paperwidth-1em\relax,
    font=\tiny\itshape,
    anchor=north west,inner xsep=0pt,inner ysep=1pt] at (current page.north west) {%
    \includegraphics[width=\paperwidth]{\@coverImage}
    \nodepart{second} \space\begin{minipage}{\dimexpr\hsize-0.5em}\@coverImageCaption\par\end{minipage}};
  }
\node[anchor=south east, coverTitleOptions,
inner sep=2ex] at (current page.south east) {\@coverTitleText};
\end{tikzpicture}}
\clearpage\nopagecolor\normalsize
}

%%%%%%%%
% Using code from http://tex.stackexchange.com/a/245279/226
% \if@babel
  \let\xpgfcalendarweekdayname\pgfcalendarweekdayname
  \xpatchcmd{\xpgfcalendarweekdayname}
   {\translate}
   {\xtranslate}
   {}{\ddt}
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

\newenvironment{monthCalendar}[2]{%
  \begin{tikzpicture}[overlay,remember picture]
  \node[anchor=north east,at=(current page.south east),rotate=-90,transform shape,monthTitleOptions, inner sep=\CalPageMargin]
  {\pgfcalendarmonthname{#2} #1};
  \node[anchor=south west] at (current page.south west)
  {
  \tikz \calendar (cdCal-\thepage) [
    dates=#1-#2-01 to #1-#2-last,
    month text = {\%mt \%y-},
    inner sep=\CalPageMargin,
    \if@sundayweek week list sunday\else week list\fi,
    day xshift=2.75em,
    day letter headings
    ]
    if (Sunday) [\@sundayColor];
  };%

  \gdef\@eventlist{}

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
  }

  % #1=style; #2=startdate; #3=enddate or days; #4=name
  \newcommand{\event}[4][mark style=default mark]{%
    \ifblank{##3}{\oneDayEvent[##1]{##2}{##4}}%
                 {\multiDayEvent[##1]{##2}{##3}{##4}}%
  }

  % #1=style; #2=startdate; #4=name
  \newcommand{\oneDayEvent}[3][mark style=default mark]{%
    \pgfkeys{/eventmark,default,##1}%
    \markCalendar[##1]{##2}%
    \protected@xappto{\@eventlist}{%
      \makebox[1.75em][c]{\protect\tikz%
        \protect\node[\event@markstyle,font=\@eventStyle,%
        \ifdefempty{\event@marker}{inner sep=0.5ex}{inner sep=0pt},
]{\event@marker};}%
      \printeventname{##3\eventSep}\DTMdate{##2}\par%
    }{}{}
  }

  % #1=style; #2=startdate; #3=enddate or days; #4=name
  \newcommand{\multiDayEvent}[4][mark style=default mark]{%
    \IfInteger{##3}%
      {\multiDayEventWithDuration[##1]{##2}{##3}{##4}}%
      {\multiDayEventWithEnd[##1]{##2}{##3}{##4}}%
  }

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
        \ifdefempty{\event@marker}{inner sep=0.5ex}{inner sep=0pt},
        ]{\event@marker};}%
      \printeventname{##4\eventSep}\DTMdate{##2}-- \DTMusedate{tmp}\par}{}{}
  }

  % #1=style; #2=startdate; #3=enddate; #4=name
  \newcommand{\multiDayEventWithEnd}[4][mark style=default mark]{%
    \DTMsavedate{startdate}{##2}%
    \DTMsavedate{enddate}{##3+1}%
    \newcount\myct%
    \DTMsaveddatediff{enddate}{startdate}{\myct}%
    \multiDayEventWithDuration[##1]{##2}{\myct}{##4}%
  }

}{%
  \end{tikzpicture}

  \begin{minipage}[t]{\EventLineWidth}\@eventStyle%
  \setlength{\parskip}{0.5ex}%
  \@eventlist%
  \end{minipage}%
}


\tikzset{default mark/.style={circle,draw=red!50}}

\newlength\lessIllusSkip
\setlength{\lessIllusSkip}{1ex}

\newcommand{\illustration}[3][]{%
  \tikz\node[rectangle split, rectangle split parts=2,
    rectangle split part align={left,left},
    text width=#2,inner xsep=0pt, inner ysep=1pt, font=\itshape\tiny]
  {\includegraphics[width=#2]{#3} \nodepart{second} #1};
\vspace*{-\lessIllusSkip}%
}

\newcommand{\otherstuff}[3][1]{%
  \tikz\node[rectangle split, rectangle split parts=2,
    rectangle split part align={left,left},
    text width=#2,inner xsep=0pt,inner ysep=3pt,font=\itshape\tiny]
  {#3 \nodepart{second} #1};
  \vspace*{-\lessIllusSkip}%
}

\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
