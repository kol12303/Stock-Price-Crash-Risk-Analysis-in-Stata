import excel "C:\Users\LOKMAN\Desktop\Mainsheet.xlsx", sheet("BHR_country") firstrow


xtset id date2, format(%tdNN/DD/CCYY)




 
 by id (date2), sort: generate  stock_return = 100 * ln(Price/L.Price)
 
 by id (date2), sort: egen mean=mean(stock_return) //go
 
 *generate logreturn = log(Price + 1)
 

 *egen lret, by (date2 week_start)
 
 
 
 *collapse (sum) lret, by(date2 week_start)
 
  *gen weekreturn = exp(logreturn) - 1 
  
/* Explanation:（1+r） = (1+r_1)(1+r_2)...(1+r_5), take log on both sides,log(1+r)=log(1+r_1)+...log(1+r_5), then r = exp(log(1+r_1)+...log(1+r_5))-1 */

 /*First calculate lead and lag market return; an alternative way is to tsset your data set then use l. and f.*/
 


 *Creat market index
 pca Price Vol
 
 rotate
 predict market_index
 
*bysort id (date2): generate  market_return = 100 * ln(market_index/L.market_index)
 by id (date2), sort: generate  market_return = 100 * ln(market_index/L.market_index)
 
*bysort id (date2):  gen lag_market_return=market_return[_n-1] 
by id (date2), sort: generate lag_market_return=market_return[_n-1] 
 
 
 *bysort id (date2) :  gen fwd_market_return=market_return[_n+1]
by id (date2), sort: generate fwd_market_return=market_return[_n+1]
***************
qui levelsof Price, local(Price)

capture 
*drop resid

*ge resid = .

 
 
*foreach Price of local Price{

reg market_index lag_market_return market_return fwd_market_return
predict res, residuals 

*replace resid = res
*drop res
*}


*Now, calculate stock price crash risk in two ways.
*ge resid_return = log(res + 1)       // transfrom the residual return
by id (date2), sort: generate resid_return = log(res + 1)

*bysort id (date2):
*sort resid_return by(id )
*save resid_return, replace
 
 
 
*First way is to capture the negative skewness.
*keep Price date2 resid_return
*ge rret3 = resid_return^3
by id (date2), sort: generate rret3 = resid_return^3
*ge rret2 = resid_return^2
by id (date2), sort: generate rret2 = resid_return^2
*collapse (sum) rret2 rret3 (count) n = resid_return,by(date2)
 
 *******************************************************************

*Second way is to measure the positive and negative return volatility.
*use resid_return, clear
*drop if resid_return == .
*by price date2, sort: 
*egen avgggg=mean(resid_return)
by id (date2), sort: egen avg = mean(resid_return)

*ge m = resid_return<avg
by id (date2), sort: ge m = resid_return < avg

*ge Drret2 = resid_return^2 if m == 1
by id (date2), sort: ge Drret2 = resid_return^2 if m == 1

*ge Urret2 = resid_return^2 if m == 2
by id (date2), sort: ge Urret2 = resid_return^2 if m == 2
collapse (sum) Drret2 Urret2 (count) nod = Drret2 nou = Urret2, by(date2)

collapse (sum) Drret2 Urret2 (count) nod = Drret2 nou = Urret2, by(id)

 
*********************END******************************************


 
 
 
 
 
 
 
 
 
 
 
 
 