
**getting data
use "C:\Users\mvl\Dropbox\Kausaleksperiment\regtocaus.dta", clear

cd "C:\Users\mvl\Dropbox\Kausaleksperiment\"

** figure three
gen age=113-year_of_birth
replace age=1 if age > 22
replace age=0 if age < 23 & age!=1

reg news_cons_causality i.causal_presentation##(c.age##i.program)
margins, dydx(causal_presentation) at(age=(0 1) program=(1 2))
marginsplot, level(68)  xlabel(0 "Younger" 1 "Older")  scheme(s2mono) graphregion(color(white)) ///
ylabel(-3(1)3) legend(off)  title("") ytitle("News Consumption" " " " " "Effect of regression style presentation" " ")  ///
xtitle (" ") saving(g1, replace) ///
yline(0)

reg democracy_causality i.causal_presentation##(c.age##i.program)
margins, dydx(causal_presentation) at(age=(0 1) program=(1 2))
marginsplot, level(68)  xlabel(0 "Younger" 1 "Older")  scheme(s2mono) graphregion(color(white)) ///
ylabel(-3(1)3) legend(off)  title(" ") ytitle("Democracy" " " " " "Effect of regression style presentation" " ") ///
xtitle(" " " " "PoliSci is dark and Econ is light") saving(g2, replace) ///
yline(0)

reg news_cons_causality i.causal_presentation##(c.age##i.program)
margins, dydx(causal_presentation) at(age=(0 1) program=(1 2))
marginsplot, level(68)  xlabel(0 "Younger" 1 "Older")  scheme(s2mono) graphregion(color(white)) ///
ylabel(-3(1)3) legend(off)  title("")  ytitle(" ")  ///
xtitle(" ") ytitle(" ") saving(g3, replace) ///
yline(0)



reg democracy_causality i.causal_presentation##(c.age##i.program)
margins, dydx(causal_presentation) at(age=(0 1) program=(1 2))
marginsplot, level(68)  xlabel(0 "Younger" 1 "Older")  scheme(s2mono) graphregion(color(white)) ///
ylabel(-3(1)3) legend(off)  title("")  ytitle(" ")  ///
xtitle(" " " " "PoliSci is dark and Soc is light") saving(g4, replace) ///
yline(0)


reg news_cons_causality i.causal_presentation##(c.age##i.program)
margins, dydx(causal_presentation) at(age=(0 1) program=(1 2))
marginsplot, level(68)  xlabel(0 "Younger" 1 "Older")  scheme(s2mono) graphregion(color(white)) ///
ylabel(-3(1)3) legend(off)  title("")  ///
xtitle(" ") ytitle(" ") saving(g5, replace) ///
yline(0)


reg democracy_causality i.causal_presentation##(c.age##i.program)
margins, dydx(causal_presentation) at(age=(0 1) program=(1 2))
marginsplot, level(68)  xlabel(0 "Younger" 1 "Older")  scheme(s2mono) graphregion(color(white)) ///
ylabel(-3(1)3) legend(off)  title("")  ytitle(" ")  ///
xtitle(" " " " "Econ is dark and Soc is light") saving(g6, replace) ///
yline(0)

graph combine g1.gph g3.gph g5.gph g2.gph g4.gph g6.gph, xsize(16) ysize(10) graphregion(color(white)) saving(g, replace)

graph use g.gph
graph export het_fig.eps, replace

-

***figure one data
postfile results str20(id) base effect error mean using  output1 , replace

foreach i in  causality significance {

foreach x in news_cons democracy {

reg `x'_`i' causal_presentation i.program, r

local ef=_b[causal_presentation] 
local se=_se[causal_presentation]
local base=_b[_cons]

su `x'_`i'

local mean= r(mean)

post results ( "`x'`i'") (`base') ( `ef' ) ( `se' ) ( `mean' ) 

}
}


postclose results

**table one 

  

lab var democracy_causality "Democracy - Caus."
lab var democracy_significance "Democracy - Sig."
lab var news_cons_causality "News - Caus."
lab var news_cons_significance  "News - Sig."

file open anyname using tabel1.txt, write text replace
file write anyname  _newline  _col(0)  "\begin{table} [htbp] \centering \caption{Descriptive statistics}\begin{tabular}{l*{6}{c}}\hline\hline"
file write anyname _newline _col(0) "&T-test & & &Regression & &  &\\ \hline"
file write anyname _newline _col(0) "&M & SD & n &M & SD & n\\ \hline"
foreach x of varlist news_cons_causality democracy_causality news_cons_significance democracy_significance {
su `x' if causal_presentation==0, d
file write anyname  _newline  _col(0) (`"`: var label `x''"') "&" _col(25) %9.2f  (r(mean)) "&" _col(35) %9.2f  (r(sd))  " &" _col(45) %9.0f  (r(N)) "&"
su `x' if causal_presentation==1, d
file write anyname _col(55) %9.2f  (r(mean)) "&" _col(65) %9.2f  (r(sd))  " &" _col(75) %9.0f  (r(N)) " \\"
}
file write anyname _newline _col(0) "\hline\hline"
file write anyname _newline _col(0) "\end{tabular}"
file write anyname _newline _col(0) "\end{table}"
file close anyname

**doing figure 2

use "output1", clear 


gen n=_n
replace n=n*2-1
replace n=n+1 if n > 4
set obs 8

replace n=0 if _n==7
replace n=9 if _n==8





gen ub=effect+1.96*error
gen lb=effect-1.96*error

gen ub1=effect+1.64*error
gen lb1=effect-1.64*error




twoway rspike ub1 lb1 n, lwidth(vthick) lcolor(black) || rspike ub lb n, lwidth(thick) lcolor(black) || scatter effect n , msymbol(O) msize(huge) mcolor(black) ///
scheme(s2mono) legend(off) xlabel( 1 "News" 3 "Democracy"  6 "News" 8 "Democracy", labsize(large)) ///
 xtitle( " " "Intrepretation of causality                      Intrepretation of significance") ///
 ytitle("The effect of regression-style presentation" " ") yline(0) xline(4.5, lwidth(thin) lpattern(dash)) ///
  saving(a, replace) graphregion(style(none) color(gs16)) ylabel(-1(1)2, angle(0))  

graph export "figure1.eps", as(png) replace
  
  
