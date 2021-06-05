
clear

*calculate liquidity for Bahrain

import excel "C:\Users\LOKMAN\Desktop\Mainsheet_Results - Original.xlsx", sheet("Bahrain") firstrow


tsset date2, format(%tdNN/DD/CCYY)


*generete the liquidity
gen liquidity= abs(stock_return)/ln(Vol)

*You use the same formula for the other countries