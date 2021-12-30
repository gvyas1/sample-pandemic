clear
cd "C:/Users/gauta/Documents/GitHub/pandemic/Data/Xvar"
*X Variables
//GHSI DATA (X1a)
import excel "./GHSI_2019_data.xlsx", sheet("Sheet2") firstrow clear
drop J K L M N O P Q R S T U

rename Overall GHSI_Overall
rename D GHSI_prev
rename E GHSI_det
rename F GHSI_resp
rename G GHSI_hea_sec
rename H GHSI_commit
rename I GHSI_risk

save ghsi.dta, replace

*Acute Care Hospital Beds (X1b)

import excel "./WHO_ACHB.xlsx", firstrow clear
encode COUNTRY, gen(panel_id)
drop if panel_id ==.
xtset panel_id YEAR
kountry COUNTRY, from(iso3c)
rename NAMES_STD Country
rename VALUE WHO_ACHB_p100k
rename YEAR Year
keep Country panel_id Year WHO_ACHB_p100k


//generating cross-section of most recent value
bysort panel_id(Year) : gen diff = panel_id != panel_id[_n+1]
drop if diff != 1
drop if Year ==.
save WHO_ACHB.dta, replace

drop panel_id diff Year
merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/Xvar/ghsi.dta"
drop _merge
save master_X, replace

//WB Hosptial beds per 1000
import excel "WB_Hosp_Beds_p1000.xlsx", sheet("Table2") firstrow clear
encode CountryName, gen(id)
rename Attribute Year
encode Year, gen(Yearid)
rename Value WB_hb_p1000
xtset id Yearid

//generating cross-section of most recent value
bysort CountryName(Year) : gen diff = CountryName != CountryName[_n+1]
drop if diff != 1
drop if Yearid ==.
save WB_HB_p100k.dta, replace

rename CountryName Country
keep Country WB_hb_p1000
merge 1:1 Country using master_X
drop _merge
save master_X, replace

//WB Current Health Expenditure as %GDP
import excel "WB_HEGDP.xlsx", firstrow clear
rename BK WHO_2018_HE_GDP //this is lazy - as a formality create a loop to ensure most recent value is used.
save WB_HEGDP.dta, replace

keep Country WHO_2018_HE_GDP
merge 1:1 Country using master_X
drop _merge
save master_X, replace

//-----------------------------------------------------------------------------

//STOCK MARKET DATA (Y)
cd "C:/Users/gauta/Documents/GitHub/pandemic/Data/stockdata"

*stock market data from Investing.com
import excel "stockfluctuations_1.xlsx", firstrow clear
rename stock_1 inv_stock_1
rename stock_2 inv_stock_2
rename stock_7 inv_stock_7
rename stock_WHO1 inv_stock_WHO1
rename stock_WHO2 inv_stock_WHO2
save inv_fluctuations.dta, replace

*Datastream data - For Loop generating % change between 06/03 and 13/03
import excel "DataStream/data/stock_ts.xlsx", sheet(Table1) firstrow clear

*generating WHO crash - can adjust this for loop in the future to generate % drop in week of first case, etc. 
keep Country K L M
foreach i in Country {
	gen dstr_WHO = ((L - K)/K)
	gen dstr_WHO2 = ((M - K)/K)
	}

drop K L M
save dstr_fluctuations.dta, replace

*saving master stock fluctuations file
merge 1:1 Country using inv_fluctuations.dta
drop _merge
save master_Y.dta, replace

*merging master Y and X data
merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/Xvar/master_X.dta"
drop _merge
kountry Country, from(other) stuck
rename _ISO3N_ iso3
kountry iso3, from(iso3n) to(iso3c)
rename _ISO3C_ id
save "C:/Users/gauta/Documents/GitHub/pandemic/Data/pandemic_master.dta", replace

//------------------------------------------------------------------------------------------------

/**Playing around with datasets.
//WHO Expediture on Immunisation Programs as % of Health Expenditure. n=78. Currently merging with Datastream yields n=6. Prob not worth it.
cd "C:/Users/gauta/Documents/GitHub/pandemic/Data/Xvar"
import excel "WHO_immperc.xlsx", firstrow clear
encode Countries, gen(id)
rename Countries Country
merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/stockdata/dstr_fluctuations.dta"

//WB Hospital Beds per 1000. n = 248 (includes some aggregated groups). After merge n currently = 21. Much more promising.
import excel "WB_Hosp_Beds_p1000.xlsx", sheet("Table2") firstrow clear
encode CountryName, gen(id)
rename Attribute Year
encode Year, gen(Yearid)
rename Value WB_hb_p1000
xtset id Yearid

//generating cross-section of most recent value
bysort CountryName(Year) : gen diff = CountryName != CountryName[_n+1]
drop if diff != 1
drop if Yearid ==.
save WB_HB_p100k.dta, replace

rename CountryName Country
merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/stockdata/dstr_fluctuations.dta"
drop if _merge !=3

*MOVE TO ANALYSIS DO FILE.
reg dstr_WHO WB_hb_p1000, robust //neg and significant!
reg dstr_WHO2 WB_hb_p1000, robust

*readyscore. n = 103 (after dropping incomplete countries.) n = 6; but some countries are probably not merged properly. 
import excel "readyscore.xlsx", sheet(Sheet2) firstrow clear
rename country Country
keep if status == "Completed"
merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/stockdata/dstr_fluctuations.dta"

*eurostat available beds per 100k. n = 39. Merged n = 11 and could definitely increase. Worth doing.
import excel "euro_beds.xlsx", firstrow clear
encode Country, gen(id)
encode Year, gen(yearid)
xtset id yearid

drop if euro_abeds_p100k == ":"
bysort Country(year) : gen diff = Country != Country[_n+1]
drop if diff !=1
save euro_abeds_p100k.dta, replace

merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/stockdata/dstr_fluctuations.dta"

*eurostat curative beds per 100k. n = 36. Merged n = 10: same as above.
import excel "euro_beds.xlsx", sheet(loop_c) firstrow clear 
encode Country, gen(id)
encode Year, gen(yearid)
xtset id yearid

drop if euro_cbeds_p100k == ":"
bysort Country(year) : gen diff = Country != Country[_n+1]
drop if diff !=1
save euro_cbeds_p100k.dta, replace

merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/stockdata/dstr_fluctuations.dta"

*WB Current Health Expenditure as % of GDP. n = 187, Merged n = 21. Can def boost to 30, use.
import excel "WB_HEGDP.xlsx", firstrow clear
rename BK WHO_2018_HE_GDP //this is lazy - as a formality create a loop to ensure most recent value is used.
save WB_HEGDP.dta, replace

keep Country WHO_2018_HE_GDP
merge 1:1 Country using "C:/Users/gauta/Documents/GitHub/pandemic/Data/stockdata/dstr_fluctuations.dta"
drop if _merge != 3

reg dstr_WHO WHO_2018_HE_GDP, robust
reg dstr_WHO2 WHO_2018_HE_GDP, robust //both negative and insignificant.




*NEXT STEP: Look through the XVars - which countries would be useful to have data for?
//+ maybe add in a systematic conversion to country codes, to ensure no countries are lost in the merge?
//integrate the code into the Xvar section properly.

//CURRENTLY thinking: use eurostat beds, WB beds and WB_HEGDP. Don't do WHO Immunisation, IHR Preparation or Readyscore.














//only downloaded/merged x and y thus far, for a subsample of countries. No control variables yet.

//todo: download subsample of stock market data when the pandemic hit. 
	//first, download time series stock market excel sheets for Jan/Feb/March/April each country. Have this dataset available (so that we can edit the lags if needed in next step) - DONE
		//then cut in STATA - for each country, 4 variables: stock market performance on the day it hit, 1 week, 2 weeks and 1 month after. Dates: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7068164/
			//then merge into GHSI data.
	
	//pandemic timeline: do a variable of stock returns following: WHO pandemic announcement (11th March) + 2 day and 1 week lags. For lags - do average of daily fluctuations or? Probably. Could do sum of variation (don't think this would have an effect).
	//then also do 1st case in country + lags.
	
//regression: % change_i = a + bGHSI_i + u_i. No control variables yet; dependent variable varies depending on dates.
