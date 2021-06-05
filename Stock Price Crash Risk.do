
clear


import excel "C:\Users\LOKMAN\Desktop\Stock Price Crash Risk\Mainsheet_Results.xlsx", sheet("Data") firstrow clear
xtset id date2, format(%tdNN/DD/CCYY)


bysort id : gen stock_return= 100*ln(Price[_n]/Price[_n-1])


*calculate the standard deviation of 
bysort id : egen  sd=sd(stock_return) //go


*calculate the mean of return
bysort id : egen mean=mean(stock_return) //go


*Create Crash variable for the return of our Stock

bysort id : egen crash_variabe = max(stock_return < mean - 3.09*sd)


export excel using "C:\Users\LOKMAN\Desktop\Stock Price Crash Risk\Main.xls", firstrow(variables)
 
****************End***********************************