\ProvidesClass{cdcalendar}[2023/09/18 CD Calendar 1.4.5 by LianTze LIM (liantze@gmail.com)]


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
  % v1.4.5 Turn off shorthands anyway
  \PassOptionsToPackage{shorthands=off}{babel}
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
    % v1.4.5 Fix border stroke for xelatex
    \pgfpageslogicalpageoptions{1}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\color{black}\pgfstroke
    }
    \pgfpageslogicalpageoptions{2}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\color{black}\pgfstroke
    }
    \pgfpageslogicalpageoptions{3}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\color{black}\pgfstroke
    }
    \pgfpageslogicalpageoptions{4}{
        resized width=9cm,
        resized height=9.5cm,
        border code=\pgfsetlinewidth{0.4pt}\color{black}\pgfstroke
    }
  \else
    \setlength{\CalPageMargin}{0.5cm}
    \geometry{paperheight=13.65cm,paperwidth=11.7cm,margin=\CalPageMargin}
    \RequirePackage{pgfpages}
    \pgfpagesuselayout{2 on 1}[a4paper,landscape]
    % v1.4.5 Fix border stroke for xelatex
    \pgfpageslogicalpageoptions{1}{
        resized width=11.7cm,
        resized height=13.65cm,
        border code=\pgfsetlinewidth{0.4pt}\color{black}\pgfstroke
    }
    \pgfpageslogicalpageoptions{2}{
        resized width=11.7cm,
        resized height=13.65cm,
        border code=\pgfsetlinewidth{0.4pt}\color{black}\pgfstroke
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
% \RequirePackage{xargs}
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
  \def\@coverBgColor{#1}%
}
\newcommand\coverImage[2][]{\def\@coverImageCaption{#1}\def\@coverImage{#2}}
\newcommand\coverTitle[2][]{
    \notblank{#1}{\tikzset{coverTitleOptions/.style={#1}}}{}
  \def\@coverTitleText{#2}
}

% v1.4.5: Hack/cheat for not printing an event when marking it
% useful for sneaking in marks on prev/next thumbnails on next/prev page
\newtoggle{stealth}\togglefalse{stealth}

\newcommand\makeCover{%
  \begingroup%
  \ifnum\pgf@logicalpages=0\relax
    \pagecolor{\@coverBgColor}%
  \else
    \ifx\@Gm@driver\@Gm@dvipdfm
      % \typeout{I see you dvipdfm}
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
% v1.4.4 Make it easier to customise caption below \illustration or \otherstuff
\newcommand\captionStyle[1]{\tikzset{illusCaptionOptions/.style={#1}}}

\pgfkeys{
  /eventmark/.is family, /eventmark,
  default/.style = {
    marker = {},
    mark style = {},
    smallver = {opacity=0.8,inner sep=1.25ex}
  },
  marker/.store in = \event@marker,
  mark style/.store in = \event@markstyle,
  % v1.4.5: add smallver for customising marks on prev/next thumbnail calendars
  smallver/.store in = \event@smallmarkstyle
}%

\newcommand{\printdate}[1]{\DTMdate{#1}}

\def\@eventlist{}
\newcounter{cdcalaux@next@page}
\newcounter{cdcalaux@prev@page}
\newwrite\cdcalaux@next@file
\newwrite\cdcalaux@prev@file

\newenvironment{monthCalendar}[2]{%
  % v1.4.5: lazy hack for turning off all the "there is no x in font nullfont" messages
  \tracinglostchars=0\relax%
  % v1.4.5: When @prevnext true, create two .aux files for each monthCalendar
  % page to hold the event marks from the previous and next page
  % Kinda ugly with all the plethora of generated files... but this is the 
  % best I can manage now.
  \setcounter{cdcalaux@next@page}{\value{page}}%
  \stepcounter{cdcalaux@next@page}%
  \setcounter{cdcalaux@prev@page}{\value{page}}%
  \addtocounter{cdcalaux@prev@page}{-1}%
  \if@prevnext
    \immediate\openout\cdcalaux@next@file=\jobname-p\thecdcalaux@next@page-p.aux
    \immediate\openout\cdcalaux@prev@file=\jobname-p\thecdcalaux@prev@page-n.aux
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
      \calendar (cdCal-p\thepage) [dates=#1-\tmpmonth-01 to #1-\tmpmonth-last];\\
      \pgfmathsetmacro{\tmpmonth}{int(\number#2+1)}%
      \calendar (cdCal-p\thepage) [dates=#1-\tmpmonth-01 to #1-\tmpmonth-last];\\
    };
    \endgroup\fi\fi
  \end{tikzpicture}
  \end{textblock*}%
  % 
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
        \begin{scope}[on background layer]
        \node[inner sep=1.25ex,\event@markstyle]
          at (cdCal-\thepage-##2) {\event@marker};%
        \end{scope}%
      }%
      %%% v1.4.5: When @prevnext true, write each event mark to the prev and 
      %%% next page .aux files too so that they get marked on the thumbnails 
      \if@prevnext
        \immediate\write\cdcalaux@next@file{%
          \noexpand\@ifundefined{pgf@sh@ns@cdCal-p\thecdcalaux@next@page-##2}{}{
          \noexpand\node[transform shape,scale=0.4,
          \expandonce\event@markstyle,\expandonce\event@smallmarkstyle]
            at (cdCal-p\thecdcalaux@next@page-##2) {\expandonce\event@marker};%
          }
        }
        % 
        \immediate\write\cdcalaux@prev@file{%
          \noexpand\@ifundefined{pgf@sh@ns@cdCal-p\thecdcalaux@prev@page-##2}{}{
          \noexpand\node[transform shape,scale=0.4,
          \expandonce\event@markstyle,\expandonce\event@smallmarkstyle]
            at (cdCal-p\thecdcalaux@prev@page-##2) {\expandonce\event@marker};%
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
      % v1.4.5: If in stealth mode, don't print the event name and date in list
      \nottoggle{stealth}{%
        \protected@xappto{\@eventlist}{%
          \makebox[1.75em][c]{\protect\tikz%
            \protect\node[\event@markstyle,font=\fontsize{1em}{1em},%
            \ifdefempty{\event@marker}{inner sep=0.5ex}{inner sep=0pt},
            ]{\event@marker};}%
          \printeventname{##3\eventSep}\DTMdate{##2}\par%
        }{}{}
      }{}
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
      % v1.4.5: If in stealth mode, don't print the event name and date in list
      \nottoggle{stealth}{%
        \protected@xappto{\@eventlist}{%
          \makebox[1.75em][c]{\protect\tikz%
            \protect\node[\event@markstyle,font=\fontsize{1em}{1em},%
            \ifdefempty{\event@marker}{inner sep=0.5ex}{inner sep=0pt},%
            ]{\event@marker};}%
          \printeventname{##4\eventSep}\DTMdate{##2}\,--\,\DTMusedate{tmp}\par}{}{}%
      }{}
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
  % v1.4.5: if @prevnext true, then read in the prev/next .aux files to
  % mark events on prev/next thumbnail calendars
  \if@prevnext
    \immediate\closeout\cdcalaux@next@file
    \immediate\closeout\cdcalaux@prev@file
    \makeatletter
    \begin{tikzpicture}[remember picture,overlay]
    \begin{scope}[on background layer]
    \IfFileExists{\jobname-p\thepage-p.aux}{\input{\jobname-p\thepage-p.aux}}{}
    \IfFileExists{\jobname-p\thepage-n.aux}{\input{\jobname-p\thepage-n.aux}}{}
    \end{scope}
    \end{tikzpicture}
    \makeatother
  \fi
}


\tikzset{default mark/.style={circle,draw=red!50}}

\newlength\illusSkip
\setlength{\illusSkip}{1em}
\tikzset{illusCaptionOptions/.style={font=\itshape\tiny}}
\newcommand{\illustration}[3][]{%
  \if@landscapecal
  \begin{textblock*}{\paperwidth}(\CalPageMargin,\CalPageMargin)
  \fi%
  \tikz\node[rectangle split, rectangle split parts=2,
    rectangle split part align={left,left},
    text width=#2,inner xsep=0pt, inner ysep=1pt, illusCaptionOptions]
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
    text width=#2,inner xsep=0pt,inner ysep=3pt,illusCaptionOptions]
  {#3 \nodepart{second} #1};\par
  \vspace*{\illusSkip}%
  \if@landscapecal
  \end{textblock*}
  \fi%
}

\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
