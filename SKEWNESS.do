import excel "C:\Users\LOKMAN\Desktop\Mainsheet.xlsx", sheet("BHR_country") firstrow


xtset id date2, format(%tdNN/DD/CCYY)


 *gen week_start = cond(dow(date2) >= 3, date2 - dow(date2) + 3, date2 - dow(date2) - 4)
 
 *label var week_start "Every week starts in Wed and has the same value."
 
 *bysort id week_start: gen N = _N
 
 
 
 *bysort id (date2): generate  return = 100 * ln(Price/L.Price)

by id (date2), sort: gen stock_return = 100 * ln(Price/L.Price)

 *Creat market index
 pca Price Vol
 
 rotate
 predict market_index
 
*bysort id (date2): generate  market_return = 100 * ln(market_index/L.market_index)
by id (date2), sort: gen market_return = 100 * ln(market_index/L.market_index)
 
*bysort id (date2):  gen lag_market_return=market_return[_n-1] 
by id (date2), sort: gen lag_market_return=market_return[_n-1] 
 
 
*bysort id (date2) :  gen fwd_market_return=market_return[_n+1]
by id (date2), sort: gen fwd_market_return=market_return[_n+1]

***************
qui levelsof Price, local(Price)

capture 

 

reg market_index lag_market_return market_return fwd_market_return
predict res, residuals 


*Now, calculate stock price crash risk in two ways.
*ge resid_return = log(res + 1)       // transfrom the residual return
by id (date2), sort: gen resid_return = log(res + 1) 
 
 
*First way is to capture the negative skewness.
*keep Price date2 resid_return
*ge rret3 = resid_return^3
by id (date2), sort: gen rret3 = resid_return^3

*ge rret2 = resid_return^2
by id (date2), sort: gen rret2 = resid_return^2

***BEFORE COLLAPSING MAKE SHORE TO DECIDE BY WHAT YOU WANT TO COLLAPSE***
*capture the negative skewness by for each country.
collapse (sum) rret2 rret3 (count) n = resid_return,by(id)
gen NCSKEW=-[n*(n-1)^(3/2)*rret3]/[(n-1)*(n-2)*(rret2)^(3/2)]  //crash risk, NCSKEW
sum NCSKEW


*capture the negative skewness by for each date.
collapse (sum) rret2 rret3 (count) n = resid_return,by(date2)
gen NCSKEW=-[n*(n-1)^(3/2)*rret3]/[(n-1)*(n-2)*(rret2)^(3/2)]  //crash risk, NCSKEW
sum NCSKEW











