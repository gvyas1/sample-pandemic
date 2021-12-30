clear
cd "C:/Users/gauta/Documents/GitHub/pandemic"
capture log close
log using "pandemic.log", replace

*Analysis 1: stock_1/stock_WHO2 ~ GHSI_Overall (12/09/21)
use "./Data/pandemic_master.dta", clear
keep Country inv_stock_1 inv_stock_WHO2 GHSI_Overall

scatter inv_stock_1 GHSI_Overall || lfit inv_stock_1 GHSI_Overall
scatter inv_stock_WHO2 GHSI_Overall ||lfit inv_stock_WHO2 GHSI_Overall

asdoc reg inv_stock_1 GHSI_Overall, robust
asdoc reg inv_stock_WHO2 GHSI_Overall, robust

*Analysis 2: dstr_WHO ~ GHSI_Overall (19/09/21)
use "./Data/pandemic_master.dta", clear
keep Country dstr_WHO dstr_WHO2 GHSI_Overall 
scatter dstr_WHO GHSI_Overall || lfit dstr_WHO GHSI_Overall, xtitle("GHSI") ytitle("dstr_WHO")
scatter dstr_WHO2 GHSI_Overall || lfit dstr_WHO2 GHSI_Overall, xtitle("GHSI") ytitle("dstr_WHO2")

asdoc reg dstr_WHO GHSI_Overall, robust replace dec(5)
reg dstr_WHO2 GHSI_Overall, robust

*Analysis 3: stock_1/stock_WHO2 ~ WHO_ACHB (20/09/21)
use "./Data/pandemic_master.dta", clear
keep Country inv_stock_1 inv_stock_WHO2 WHO_ACHB_p100k

scatter inv_stock_1 WHO_ACHB_p100k || lfit inv_stock_1 WHO_ACHB_p100k, xtitle("ACHB per 100,000") ytitle("Stock Fluctuation on" "Day of 1st Case")
scatter inv_stock_WHO2 WHO_ACHB_p100k || lfit inv_stock_WHO2 WHO_ACHB_p100k, xtitle("ACHB per 100,000") ytitle("Stock Fluctuation on 12th March")

//regressions: n is very low. Haven't downloaded a lot of stock data (18/24 countries), and the ACHB data only covers 51 countries.
reg inv_stock_1 WHO_ACHB_p100k //n = 9. Positive and insignificant.
asdoc reg inv_stock_WHO2 WHO_ACHB_p100k, robust replace dec(5) //n = 11. Negative and insignificant

*Analysis 4: dstr_WHO ~ WHO_ACHB
use "./Data/pandemic_master.dta", clear
keep Country dstr_WHO dstr_WHO2 WHO_ACHB_p100k

scatter dstr_WHO WHO_ACHB_p100k|| lfit dstr_WHO WHO_ACHB_p100k, xtitle("ACHB per 100,000") ytitle("Stock Fluctuation between" "06/03/20 and 13/03/20")
scatter dstr_WHO2 WHO_ACHB_p100k|| lfit dstr_WHO2 WHO_ACHB_p100k, xtitle("ACHB per 100,000") ytitle("Stock Fluctuation between" "06/03/20 and 20/03/20")

asdoc reg dstr_WHO WHO_ACHB_p100k, robust replace dec(5) //n = 16, positive insignificant.
asdoc reg dstr_WHO2 WHO_ACHB_p100k, robust replace dec(5)






*Analysis 5: dstr_WHO ~ WB Hospital Beds. (30/09/21).
use "./Data/pandemic_master_surface.dta", clear
keep Country id dstr_WHO dstr_WHO2 WB_hb_p1000 gdp_cap
drop if dstr_WHO ==.

/*pctile gdp_cap_quant = gdp_cap, nquantiles(5)
drop if gdp_cap > gdp_cap_quant[3]
drop if gdp_cap < gdp_cap_quant[1]*/


//graphing for presentation - 
gen pos = 3
replace pos = 6 if id=="ITA"
replace pos = 5 if id=="DNK"
replace pos = 6 if id=="SGP"
replace pos = 6 if id=="ESP"
replace pos = 7 if id=="BRA"
replace pos =9 if id=="TUR"
replace pos =6 if id=="NZI"


set scheme plottig
twoway scatter dstr_WHO WB_hb_p1000, msize (1pt) mlabel(id) mlabsize(tiny) mlabv(pos) title("Hospital Beds and Stock Index Performance (week of WHO Announcement)", size(8pt)) xtitle("Hospital Beds/1000") ytitle("Stock Fluctuation between" "06/03/20 and 13/03/20") || lfit dstr_WHO WB_hb_p1000

//main graphing
replace pos = 3
replace pos = 12 if id=="NLD"
replace pos = 2 if id=="VNM"
replace pos = 4 if id=="TUR"
replace pos = 6 if id=="NZL"
replace pos = 12 if id=="POL"
replace pos = 1 if id=="HRV"
replace pos = 2 if id=="DEU"
replace pos = 8 if id=="ESP"
replace pos = 12 if id=="SWE"
replace pos = 6 if id=="MEX"
replace pos = 4 if id=="ISR"
replace pos = 12 if id=="KOR"
replace pos = 9 if id== "GBR"

twoway scatter dstr_WHO2 WB_hb_p1000, title({bf:Hospital Beds and Stock Index Performance (all countries):} {it:6th March - 20th March}, size(8pt)) xtitle("Hospital Beds/1000") ytitle("Stock Fluctuation between" "06/03/20 and 20/03/20") mlabel(id) msize(1pt) mlabsize(tiny) mlabv(pos) legend(off) || lfit dstr_WHO2 WB_hb_p1000, lcolor(black) 

graph save "C:/Users/gauta/Documents/GitHub/pandemic/figures/scatterplots/pres_1_1.gph", replace

asdoc reg dstr_WHO WB_hb_p1000, robust replace dec(5) //n =32, negative and insignificant
asdoc reg dstr_WHO2 WB_hb_p1000 gdp_cap, robust replace dec(5) //n = 32, negative and insignificant.


*thinking about modelling a non linear relationship.
*most basic model - dummy interaction for rich country.
pctile gdp_cap_median = gdp_cap
gen rich = 1 if gdp_cap > gdp_cap_median[1]
replace rich = 0 if gdp_cap < gdp_cap_median[1]
gen interaction = WB_hb_p1000 * rich

asdoc reg dstr_WHO2 WB_hb_p1000 rich interaction, robust replace dec(5)


*Analysis 6: dstr_WHO ~ WB Health Expenditure.
use "./Data/pandemic_master.dta", clear
keep Country id dstr_WHO dstr_WHO2 WHO_2018_HE_GDP

scatter dstr_WHO WHO_2018_HE_GDP|| lfit dstr_WHO WHO_2018_HE_GDP, xtitle("Health Expenditure as % of GDP") ytitle("Stock Fluctuation between" "06/03/20 and 13/03/20")

//main
gen pos = 3
replace pos = 2 if id=="DEU"
replace pos = 6 if id=="SGP"
replace pos = 6 if id=="NZL"
replace pos = 6 if id=="AUT"
replace pos = 2 if id=="BEL"
replace pos = 9 if id=="JPN"


scatter dstr_WHO2 WHO_2018_HE_GDP, title({bf:Health Expenditure and Stock Index Performance:} {it:6th March - 20th March}, size(8pt)) xtitle("Health Expenditure as % of GDP") ytitle("Stock Fluctuation between" "06/03/20 and 20/03/20") mlabel(id) msize(1pt) mlabsize(tiny) mlabv(pos) legend(off)|| lfit dstr_WHO2 WHO_2018_HE_GDP, lcolor(black)

graph save "C:/Users/gauta/Documents/GitHub/pandemic/figures/scatterplots/pres_1_2.gph", replace

asdoc reg dstr_WHO WHO_2018_HE_GDP, robust replace dec(5)
asdoc reg dstr_WHO2 WHO_2018_HE_GDP, robust replace dec(5)


log close

//todo: set up a loop to save graphs more systematically.