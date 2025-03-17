
* Saving the location of the database in panel format
 
global base "C:\LOGIT\OneDrive - LOGIT\Área de Trabalho\Dissertação\Base\base_CAIP.dta"

* Location where logs will be saved
global log "C:\LOGIT\OneDrive - LOGIT\Área de Trabalho\Dissertação\Logs"

* Location where figures will be saved
global figures "C:\LOGIT\OneDrive - LOGIT\Área de Trabalho\Dissertação\Figuras"

* Work Stata
global work "C:\LOGIT\OneDrive - LOGIT\Área de Trabalho\Dissertação\Work Stata"


 
 
 ***********************************
************* Figures *************
***********************************
{
*
* Figure 1 - Map of potential maximum productivities (created in R)
*
use "$base", clear
keep if ano == 1872
keep amc ay_*
sa "$work\ay_R.dta", replace


sum ay_*


*
* Figures 2-6 - Comparison Maps: fitted values and observed values (made in R)
*
use "$base", clear
keep if ano == 1872
keep amc s_vcaf s_vcac s_vtab s_valg s_vacu fit_s_vcaf fit_s_vcac fit_s_vtab fit_s_valg fit_s_vacu
ren s_v* obs*
ren fit_s_v* est*
sa "$work\shares_R.dta", replace

corr obs* est*


***** Figure X - Comparing the evolution of racial composition of municipalities

use "$base", clear
keep if ano == 1872 | ano == 1940 | ano == 1950
egen tot3 = rowtotal(branco preto pardo)
	
	foreach var in imig branco preto pardo {
		gen p_`var' = `var' / tot3
	}
	
	
// Share of enslaved population in 1872
	gen prop_esc = (escravos_1872 / tot3) if ano == 1872
	so amc prop_esc
	by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pret_esc = (adulto_preto_escravo_1872 / tot3) if ano == 1872
	so amc prop_esc
	by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pret_livre = (preto - adulto_preto_escravo_1872)/tot3 if ano == 1872
	so amc prop_esc
	by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pard_esc = (adulto_pardo_escravo_1872 / tot3) if ano == 1872
	so amc prop_esc
	by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pard_livre = (pardo - adulto_pardo_escravo_1872)/tot3 if ano == 1872
	so amc prop_esc
	by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen p_mig_int = migrante_interno_1872/tot3 if ano == 1872
	so amc prop_esc
	by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .

keep amc ano p_imig p_branco p_preto p_pardo prop_esc prop_pret_esc prop_pret_livre prop_pard_esc prop_pard_livre p_mig_int


sa "$work\racial_R.dta", replace

* Figure 7 - CAIP 1872 x CAIP 1940 x CAIP 1950 (Map in R)
*
use "$base", clear
keep if ano == 1872 | ano == 1940 | ano == 1950
keep amc ano caip_20
ren caip_20 caip

reshape wide caip, i(amc) j(ano)
egen caip1872std = std(caip1872), mean(0) std(1)
egen caip1940std = std(caip1940), mean(0) std(1)
egen caip1950std = std(caip1950), mean(0) std(1)
drop caip1872 caip1940 caip1950
sa "$work\base_mapa_caip_R.dta", replace

sum caip1872std caip1940std caip1950std



***** Figure 8 - CAIP vs Price Indices

use "$base", clear
keep amc cac_* caf_* acu_* tab_* alg_* caip1*
duplicates drop amc, force
reshape long cac_ caf_ acu_ tab_ alg_ caip, i(amc) j(ano)

gen caip_25 = caip
gen caip_50 = caip
gen caip_75 = caip
collapse (max)cac_ caf_ acu_ tab_ alg_ (p25)caip_25 (p50)caip_50 (p75)caip_75, by(ano)

*findit grc1leg2

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line caf_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") title("Coffee") name(coffee, replace) ///
legend(order(2 "CAIP (median)" 3 "Commodity's price index") row(1) pos(6)) ///
yscale(range(3 5.5)) ylabel(3 "3.0" 3.5 "3.5" 4 "4.0" 4.5 "4.5" 5 "5.0" 5.5 "5.5") scale(.8)

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line acu_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Sugar") name(sugar, replace) ///
yscale(range(3 5.5)) ylabel(3 "3.0" 3.5 "3.5" 4 "4.0" 4.5 "4.5" 5 "5.0" 5.5 "5.5") scale(.8)

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line alg_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Cotton") name(cotton, replace) ///
yscale(range(3 5.5)) ylabel(3 "3.0" 3.5 "3.5" 4 "4.0" 4.5 "4.5" 5 "5.0" 5.5 "5.5") scale(.8)

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line tab_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Tobacco") name(tobacco, replace) ///
yscale(range(3 5.5)) ylabel(3 "3.0" 3.5 "3.5" 4 "4.0" 4.5 "4.5" 5 "5.0" 5.5 "5.5") scale(.8)

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line cac_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Cocoa") name(cocoa, replace) ///
yscale(range(3 5.5)) ylabel(3 "3.0" 3.5 "3.5" 4 "4.0" 4.5 "4.5" 5 "5.0" 5.5 "5.5") scale(.8)

grc1leg2 coffee sugar cotton tobacco cocoa, legendfrom(coffee) position(6)
graph export "$figures\Figura 8 - caip vs precos_english.png", replace width(1000)



********* Figure - Population Variation by Ethnicity ********

use "$base", clear
keep amc ano branco preto pardo imig pop
keep if ano == 1872 | ano ==  1940 |ano == 1950


egen tot3 = rowtotal(branco preto pardo)

	
foreach var in branco preto pardo imig tot3{	
	egen media_`var' = mean(`var'), by(ano)
	 gen media_`var'_1000 = media_`var' / 1000
}

gen ano_cat = .
replace ano_cat = 1 if ano == 1872
replace ano_cat = 2 if ano == 1940
replace ano_cat = 3 if ano == 1950

duplicates drop ano, force

twoway (scatter media_branco_1000 ano_cat, mcolor(gray%90) msymbol(square) msize(media_branco_1000)) ///
       (scatter media_preto_1000 ano_cat, mcolor(cranberry%90) msymbol(circle) msize(media_preto_1000)) ///
       (scatter media_pardo_1000 ano_cat, mcolor(dkgreen%90) msymbol(triangle) msize(media_pardo_1000)) ///
       (scatter media_imig_1000 ano_cat, mcolor(dkkhaki%90) msymbol(diamond) msize(media_imig_1000)), ///
      xlabel(1 "1872" 2 "1940" 3 "1950") ///
      xtitle("Year") ytitle("Population (thousands of people)") ///
      legend(label(1 "White Population") label(2 "Black Population") label(3 "Mixed-Race Population") label(4 "Immigrants"))


graph export "$figures\Figura 1 - Racial Composition of Population.png", replace width(1000)



graph box branco, over(ano) 
graph box preto, over(ano) 
graph box imig, over(ano) 
graph box pardo, over(ano) 



****** Figure 11 - CAIP and Price Index Volatility

use "$base", clear
keep amc cafdp_* acudp_* tabdp_* algdp_* cacdp_* dpcaip1*
duplicates drop amc, force
reshape long cafdp_ acudp_ tabdp_ algdp_ cacdp_ dpcaip, i(amc) j(ano)

gen caip_25 = dpcaip
gen caip_50 = dpcaip
gen caip_75 = dpcaip
collapse (max)cacdp_ cafdp_ algdp_ acudp_ tabdp_ (p25)caip_25 (p50)caip_50 (p75)caip_75, by(ano)

*findit grc1leg2

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line cafdp_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") title("Coffee") name(coffee, replace) ///
legend(order(2 "CAIP (median) - volatility" 3 "Commodity's price index - volatility") row(1) pos(6)) ///
yscale(range(0 .7)) ylabel(0 "0.0" .1 "0.1" .2 "0.2" .3 "0.3" .4 "0.4" .5 "0.5" .6 "0.6" .7 "0.7") scale(.8) 

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line acudp_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Sugar") name(sugar, replace) ///
yscale(range(0 .7)) ylabel(0 "0.0" .1 "0.1" .2 "0.2" .3 "0.3" .4 "0.4" .5 "0.5" .6 "0.6" .7 "0.7") scale(.8) 

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line algdp_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Cotton") name(cotton, replace) ///
yscale(range(0 .7)) ylabel(0 "0.0" .1 "0.1" .2 "0.2" .3 "0.3" .4 "0.4" .5 "0.5" .6 "0.6" .7 "0.7") scale(.8)

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line tabdp_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Tobacco") name(tobacco, replace) ///
yscale(range(0 .7)) ylabel(0 "0.0" .1 "0.1" .2 "0.2" .3 "0.3" .4 "0.4" .5 "0.5" .6 "0.6" .7 "0.7") scale(.8)

twoway (rarea caip_75 caip_25 ano, col(gs12)) ///
(line caip_50 ano, lwidth(thick) lpattern(dash) lc(gs5)) ///
(line cacdp_ ano, lwidth(thick) lpattern(solid) lc(black)), ///
xscale(range(1872 1960)) xlabel(1872 1880 1890 1900 1910 1920 1930 1940 1950 1960, angle(35)) ///
xtitle("Year") ytitle("Value") legend(off) title("Cocoa") name(cocoa, replace) ///
yscale(range(0 .7)) ylabel(0 "0.0" .1 "0.1" .2 "0.2" .3 "0.3" .4 "0.4" .5 "0.5" .6 "0.6" .7 "0.7") scale(.8)

grc1leg2 coffee sugar cotton tobacco cocoa, legendfrom(coffee) position(6)
graph export "$figures\Figura 11 - caip_volat vs precos_volat_english.png", replace width(1000)

}



 **Inicial Tables**** 
  
 { 
  * Table 2 - Descriptive statistics - unbalanced panel 1872, 1940, 1950, and 1960
  
 
*
// Panel for 1872, 1940, 1950, and 1960
use "$base", clear


// Population variables
	egen adulto_bra_ama = rowtotal(adulto_branco adulto_amarelo)
	egen adulto_nao_branco = rowtotal(adulto_preto adulto_pardo)
	egen jovem_bra_ama = rowtotal(jovem_branco jovem_amarelo)
	egen jovem_nao_branco = rowtotal(jovem_preto jovem_pardo)
	gen lpop = ln(pop +1)
	gen ladulto = ln(adulto + 1)
	gen ljovem = ln(jovem + 1)

	
	gen branco_nao_imig = branco - imig
	

// Shares of adults and young individuals by skin color and immigrants
	egen tot1 = rowtotal(adulto_branco adulto_preto adulto_pardo)
	egen tot2 = rowtotal(jovem_branco jovem_preto jovem_pardo)
	egen tot3 = rowtotal(branco preto pardo)
	
	foreach var in branco preto pardo {
		gen p_adulto_`var' = adulto_`var' / tot1
	}
	foreach var in branco preto pardo {
		gen p_jovem_`var' = jovem_`var' / tot2
	}
	gen p_branco = branco / tot3
	gen p_preto = preto / tot3
	gen p_pardo = pardo / tot3
	gen p_imig = imig / tot3
	
	// Share of adults by economic sector
	egen tota1 = rowtotal(agro inds serv)
		
	gen p_agro = agro / tota1
	gen p_inds = inds / tota1
	gen p_serv = serv / tota1
	
	
	
	keep if ano == 1872 |ano == 1940 | ano == 1950 | ano == 1960
	
	gen p_analf15 = analf15 / adulto
		replace p_analf15 = 1 if p_analf15 > 1 & p_analf15 != .
	gen prop_esc = (escravos_1872 / pop) if ano == 1872
	gen p_preto_esc = (adulto_preto_escravo_1872 / adulto_preto) if ano == 1872		// Share of enslaved individuals in the Black population
	gen p_pardo_esc = (adulto_pardo_escravo_1872 / adulto_pardo) if ano == 1872		// Share of enslaved individuals in the Mixed-race populatio
		
	collapse (mean) p_agro p_inds p_serv p_analf15 p_imig p_preto p_branco p_pardo prop_esc p_preto_esc p_pardo_esc caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20, by(amc ano)
		sum  p_agro p_inds p_serv p_analf15 p_imig p_preto p_branco p_pardo prop_esc p_preto_esc p_pardo_esc caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1872
		sum  p_agro p_inds p_serv p_analf15 p_imig p_preto p_branco p_pardo caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1940
		sum  p_agro p_inds p_serv p_analf15 p_imig p_preto p_branco p_pardo caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1950
		sum  p_agro p_inds p_serv p_analf15 p_imig p_preto p_branco p_pardo caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1960
		
		
		
// Building descriptive statistics for population and CAIP:

// Descriptive statistics table for population:

		mean  p_analf15 p_agro p_inds p_serv p_imig p_preto p_branco p_pardo prop_esc p_preto_esc p_pardo_esc  if ano == 1872
		qui estimates store mean_1872_pop
		
		mean  p_analf15 p_agro p_inds p_serv p_imig p_preto p_branco p_pardo   if ano == 1940
		qui estimates store mean_1940_pop
		
		mean  p_analf15 p_agro p_inds p_serv p_imig p_preto p_branco p_pardo if ano == 1950
		qui estimates store mean_1950_pop
		
		mean  p_analf15 p_agro p_inds p_serv p_imig p_preto p_branco p_pardo if ano == 1960
		qui estimates store mean_1960_pop
		
estimates table mean_1872_pop mean_1940_pop mean_1950_pop mean_1960_pop, stats(N) title("Descriptive statsitics of population. Years: 1872, 1940, 1950 e 1960") 
		
qui outreg2 [mean_1872_pop mean_1940_pop mean_1950_pop mean_1960_pop] using "$log\Tabela_descr_pop",  tex title("Descriptive statsitics of population. Years: 1872, 1940, 1950 e 1960")   dec(3) stats(coef) replace 

// Descriptive statistics table for CAIP:

		mean  caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1872
		qui estimates store mean_1872_caip		
	
		mean  caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1940
		qui estimates store mean_1940_caip
		
		mean  caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1950
		qui estimates store mean_1950_caip
		
		mean  caip_20 caip_conscaf_20 caip_consacu_20 caip_consalg_20 caip_constab_20 caip_conscac_20 dp_caip20 if ano == 1960
		qui estimates store mean_1960_caip
		
estimates table mean_1872_caip mean_1940_caip mean_1950_caip mean_1960_caip, stats(N) title("CAIP.  Years: 1872, 1920, 1940, 1950 e 1960") 
		
qui outreg2 [mean_1872_caip mean_1940_caip mean_1950_caip mean_1960_caip] using "$log\Tabela_descr_caip",  tex title("CAIP.  Years: 1872, 1920, 1940, 1950 e 1960") dec(3) stats(coef) replace 
		
		
  }
 
// Creating CAIP persistence variables

use $base, clear

	
* Create an empty local list to store variable names
local varlist ""

* Loop through years 1872 to 1950
forvalues year = 1872/1950 {
    * Add each caipXXXX variable to the list
    local varlist "`varlist' caip`year'"
}

* Keep only the variables in the list
keep amc `varlist'
bysort amc: keep if _n == 1


** Transforming into long format
reshape long caip, i(amc) j(ano) string

summarize caip, detail
*gen mediana = r(p50)

egen mediana = median(caip)
					
gen tag = 1 if caip > mediana

egen intervalo_total = total(tag), by(amc)

*replace intervalo_total = intervalo_total + 1

gen caip_temp_7250 = intervalo_total/79

sum caip_temp_7250 

keep amc caip_temp_7250

bysort amc: keep if _n == 1

save "C:\LOGIT\OneDrive - LOGIT\Área de Trabalho\Dissertação\Base\base_caip_temp_7250.dta", replace

  

***** Estimating tables excluding the year 1920

{

use $base, clear


	
// Creating CAIP components
	gen mfitcaf_20 = fit_s_vcaf * mpcaf20
	gen mfitacu_20 = fit_s_vacu * mpacu20
	gen mfitalg_20 = fit_s_valg * mpalg20
	gen mfittab_20 = fit_s_vtab * mptab20
	gen mfitcac_20 = fit_s_vcac * mpcac20
	
// Creating interactions between average prices and geographic variables
	foreach var in dist_ocean dist_capital altitude latitude t_primavera t_verao t_outono t_inverno ch_primavera ch_verao ch_outono ch_inverno {
		gen mcaf_`var' = mpcaf20 * `var'
		gen malg_`var' = mpalg20 * `var'
		gen macu_`var' = mpacu20 * `var'
		gen mtab_`var' = mptab20 * `var'
		gen mcac_`var' = mpcac20 * `var'
		gen mpreco_`var' = mcaf_`var' + malg_`var' + macu_`var' + mtab_`var' + mcac_`var'

}

// Share of adults and young individuals by skin color
	egen tot1 = rowtotal(adulto_branco adulto_preto adulto_pardo) if adulto_branco != . & adulto_preto != . & adulto_pardo != .
	egen tot2 = rowtotal(jovem_branco jovem_preto jovem_pardo) if jovem_branco != . & jovem_preto != . & jovem_pardo != . 
	egen tot3 = rowtotal(branco preto pardo) if branco != . & preto != . & pardo != .
	
	foreach var in branco preto pardo  {
		gen p_adulto_`var' = adulto_`var' / tot1
	}
	foreach var in branco preto pardo {
		gen p_jovem_`var' = jovem_`var' / tot2
	}
	
	gen branco_nao_imig = branco - imig
	
	gen p_branco_nao_imig = branco_nao_imig / tot3
	gen p_branco = branco / tot3
	gen p_preto = preto / tot3
	gen p_pardo = pardo / tot3
	gen p_jovem = tot2/tot3
	gen p_adulto= tot1/tot3
	gen p_imig = imig/tot3
	
	gen dif_pop_tot = pop - (tot3 + imig)
	
**** Share of young individuals in school
gen p_naescola = naescola/jovem
	
	
// Share of the population with at least a high school diploma, by skin color
	gen p_bra_es = es_bra_ama / (branco + amarelo)
	gen p_naobra_es = es_nao_branco / (preto + pardo + indigena)
	* DiferenÃ§a
	gen dif_es = p_bra_es - p_naobra_es

// Difference in average income
	gen dif_renda = renda_bra_ama - renda_nao_branco
	
// Share of adults by economic sector
	egen tota1 = rowtotal(agro inds serv)
		
	gen p_agro = agro / tota1
	gen p_inds = inds / tota1
	gen p_serv = serv / tota1
	
	
// Share of adults by economic sector and skin color
	egen tot_cor_setor = rowtotal(inds_branco inds_preto inds_pardo agro_branco agro_preto agro_pardo serv_branco serv_preto serv_pardo)
	
foreach var in branco preto pardo  {
		gen p_inds_`var' = inds_`var' / tot_cor_setor
	}
	
foreach var in branco preto pardo  {
		gen p_agro_`var' = agro_`var' / tot_cor_setor
	}
	
foreach var in branco preto pardo  {
		gen p_serv_`var' = serv_`var' / tot_cor_setor
	}
		

// Share of enslaved people in 1872
	gen prop_esc = (escravos_1872 / tot3) if ano == 1872
	so amc prop_esc
	by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pret_esc = (adulto_preto_escravo_1872 / tot3) if ano == 1872
	*so amc prop_esc
	*by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pret_livre = (preto - adulto_preto_escravo_1872)/tot3 if ano == 1872
	*so amc prop_esc
	*by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pard_esc = (adulto_pardo_escravo_1872 / tot3) if ano == 1872
	*so amc prop_esc
	*by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen prop_pard_livre = (pardo - adulto_pardo_escravo_1872)/tot3 if ano == 1872
	*so amc prop_esc
	*by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	
	gen p_mig_int = migrante_interno_1872/tot3 if ano == 1872
	*so amc prop_esc
	*by amc: replace prop_esc = prop_esc[_n-1] if prop_esc == .
	

	
foreach var in branco preto pardo  {
		gen ln_adulto_`var' = ln(adulto_`var' + 1 ) if `var'!= .
	}
	
foreach var in branco preto pardo  {
		gen ln_jovem_`var' = ln(jovem_`var' + 1 ) if `var'!= .
	}
	
foreach var in imig pop branco preto pardo  {
		gen ln_`var' = ln(`var' + 1 ) if `var'!= .
	}	
	
	
gen ln_pop_tot3 = ln(tot3  + 1 ) if tot3!= .
gen ln_jovem_tot2 = ln(tot2  + 1 ) if tot2 != .
gen ln_adulto_tot1 = ln(tot1  + 1 ) if tot1!= .

gen ln_branco_nao_imig = ln(branco_nao_imig  + 1 ) if branco_nao_imig != .


****Creating state dummies 
	
* Convert the variable "cod_uf" into a string
gen str2 cod_uf_str = string(cod_uf)

*Extract the first digit of the state code
gen primeiro_digito = substr(cod_uf_str, 1, 1)

* Remove the temporary variable
drop cod_uf_str
	
gen regiao = .

replace regiao = 1 if primeiro_digito == "1"
replace regiao = 2 if primeiro_digito == "2"
replace regiao = 3 if primeiro_digito == "3"
replace regiao = 4 if primeiro_digito == "4"
replace regiao = 5 if primeiro_digito == "5"

foreach regiao in 1 2 3 4 5 {
	gen a`regiao' = 0
	replace a`regiao' = 1 if regiao == `regiao'
	}

label var regiao  "codigo de cada regiao"
label var a1 "dummy regiao norte "
label var a2 "dummy regiao nordeste" 
label var a3 "dummy regiao sudeste"
label var a4 "dummy regiao sul"
label var a5 "dummy regiao centro-oeste"


**** Creating dummy for São Paulo

gen dummy_sp = 0
replace dummy_sp = 1 if cod_uf == 35



	gen balance = .
		replace balance = 0 if p_adulto_branco == . & ano == 1960 | p_adulto_branco == . & ano == 1872
		replace balance = 0 if p_adulto_preto == . & ano == 1960 | p_adulto_preto == . & ano == 1872
		replace balance = 0 if p_adulto_pardo == . & ano == 1960 | p_adulto_pardo == . & ano == 1872
		replace balance = 0 if p_jovem_branco == . & ano == 1960 | p_jovem_branco == . & ano == 1872
		replace balance = 0 if p_jovem_preto == . & ano == 1960 | p_jovem_preto == . & ano == 1872
		replace balance = 0 if p_jovem_pardo == . & ano == 1960 | p_jovem_pardo == . & ano == 1872
		replace balance = 0 if p_jovem == . & ano == 1960 | p_jovem == . & ano == 1872
		replace balance = 0 if p_adulto == . & ano == 1960 | p_adulto == . & ano == 1872
		
		replace balance = 0 if p_adulto_branco == . & ano == 1960 | p_adulto_branco == . & ano == 1872
		replace balance = 0 if p_adulto_preto == . & ano == 1960 | p_adulto_preto == . & ano == 1872
		replace balance = 0 if p_adulto_pardo == . & ano == 1960 | p_adulto_pardo == . & ano == 1872
		replace balance = 0 if ln_jovem_branco == . & ano == 1960 | ln_jovem_branco == . & ano == 1872
		replace balance = 0 if ln_jovem_preto == . & ano == 1960 | ln_jovem_preto == . & ano == 1872
		replace balance = 0 if ln_jovem_pardo == . & ano == 1960 | ln_jovem_pardo == . & ano == 1872
		replace balance = 0 if ln_jovem_tot2 == . & ano == 1960 | ln_jovem_tot2 == . & ano == 1872
		replace balance = 0 if ln_adulto_tot1 == . & ano == 1960 | ln_adulto_tot1 == . & ano == 1872

	  	so amc balance
		by amc: replace balance = balance[_n-1] if balance == .
		so amc ano
		replace balance = 1 if balance == .
		

		
		
	
* Panel A (1872, 1940, and 1950)
// Standardizing CAIPs to mean = 0 and std = 1, using only the sample analyzed in regressions
		egen caip_20_A = std(caip_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_caf_20_A = std(caip_conscaf_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_acu_20_A = std(caip_consacu_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_alg_20_A = std(caip_consalg_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_tab_20_A = std(caip_constab_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_cac_20_A = std(caip_conscac_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_10_A = std(caip_10) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_median20_A = std(caip_median20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen caip_median10_A = std(caip_median10) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen dp_caip_20_A = std(dp_caip20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen dp_caipconscaf_20_A = std(dp_caipconscaf20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen mfit_cafe = std(mfitcaf_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen mfit_acucar = std(mfitacu_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen mfit_algodao = std(mfitalg_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen mfit_tabaco = std(mfittab_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)
		egen mfit_cacau = std(mfitcac_20) if ano == 1872  | ano == 1940 | ano == 1950 , mean(0) std(1)

* Panel B (1872 and 1960)
// Standardizing CAIPs to mean = 0 and std = 1, using only the sample analyzed in regressions
		egen caip_20_B = std(caip_20) if ano == 1872 & balance == 1 | ano == 1960 & balance == 1, mean(0) std(1)
		egen dp_caip_20_B = std(dp_caip20) if ano == 1872 & ano == 1960 & balance == 1, mean(0) std(1)
		
		
		* Panel E (1940 and 1950)
// Standardizing CAIPs to mean = 0 and std = 1, using only the sample analyzed in regressions
		egen caip_20_E = std(caip_20) if ano == 1940 | ano == 1950 , mean(0) std(1)
		
		
* Cross-Section year 1872
		egen caip_20_1872 = std(caip_20) if ano == 1872, mean(0) std(1) 
		
		egen mfit_cafe_1872 = std(mfitcaf_20) if ano == 1872, mean(0) std(1)
		egen mfit_acucar_1872 = std(mfitacu_20) if ano == 1872, mean(0) std(1)
		egen mfit_algodao_1872 = std(mfitalg_20) if ano == 1872, mean(0) std(1)
		egen mfit_tabaco_1872 = std(mfittab_20) if ano == 1872, mean(0) std(1)
		egen mfit_cacau_1872 = std(mfitcac_20) if ano == 1872, mean(0) std(1)
		
		
		
		
* Panel considering only the state of São Paulo
		egen caip_20_SP = std(caip_20) if ano == 1940 & dummy_sp == 1| ano == 1950 & dummy_sp == 1, mean(0) std(1)
		
		
		
*** Main regression

** In share format

qui cap gen caip = .
qui replace caip = caip_20_A

xtreg p_branco caip caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store parc_bran

xtreg p_preto caip  i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store parc_pret
	
xtreg p_pardo caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store parc_pard
	

estimates table parc_bran parc_pret parc_pard, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Tabela 8.B. RelaÃ§Ã£o entre CAIP e mecanismos especÃ­ficos. Anos (pop. geral): 1872, 1940, 1950 e 1960. Anos (pop. adulta ou jovem): 1872 e 1950")
	
	qui outreg2 [ parc_bran parc_pret parc_pard] using "$log\Tabela_15a",  tex keep(caip) pdec(3) dec(3) title("Relationship between CAIP racial composition.") replace 
	
	
**** Splitting  Whites into Immigrant Whites and Non-Immigrant Whites
	
** In share format
	
	qui cap gen caip = .
qui replace caip = caip_20_A
	
local dep_vars "p_imig  p_branco_nao_imig "

foreach dep_var in `dep_vars' {
    xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
}

estimates table p_imig  p_branco_nao_imig, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relationship between CAIP racial composition - whites (share)")
	
	qui outreg2 [p_imig  p_branco_nao_imig] using "$log\Tabela_15b",  tex keep(caip) dec(3) rdec(3) title("Relationship between CAIP racial composition - whites (share)") replace 
	
qui cap gen caip = .
	qui replace caip = caip_20_A

xtreg ln_pop_tot3 caip caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store log_pop
	
xtreg ln_branco caip caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store log_bran
	
xtreg ln_preto caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store log_pret
	
xtreg ln_pardo caip  i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store log_pard
	


estimates table log_bran log_pret log_pard  log_pop , stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relationship between CAIP racial composition ( log)")
	
	qui outreg2 [log_bran log_pret log_pard log_pop ] using "$log\Tabela_16a",  tex keep(caip) dec(3) rdec(3) title("Relationship between CAIP racial composition ( log)") replace 

			

** In Ln share format


qui cap gen caip = .
qui replace caip = caip_20_A
	
local dep_vars "ln_imig  ln_branco_nao_imig "

foreach dep_var in `dep_vars' {
    xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
}

estimates table ln_imig  ln_branco_nao_imig, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relationship between CAIP racial composition - whites (share)")
	
	qui outreg2 [ln_imig  ln_branco_nao_imig] using "$log\Tabela_16b",  tex keep(caip) dec(3) rdec(3) title("Relationship between CAIP racial composition - whites (share)") replace 

		
***** ESTIMATING BY AGE GROUP (Appendix)
		
******* Population Share 
*** Adult Population
		
qui cap gen caip = .
qui replace caip = caip_20_B

local dep_vars "p_adulto_branco p_adulto_preto p_adulto_pardo p_adulto"

foreach dep_var in `dep_vars' {
    xtreg `dep_var' caip  i.a1960 if ano == 1872 & balance == 1 | ano == 1960 & balance == 1, fe
	qui estimates store `dep_var'
}


estimates table p_adulto_branco p_adulto_preto p_adulto_pardo p_adulto, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relationship between CAIP racial composition by age (share)")
	
	qui outreg2 [p_adulto_branco p_adulto_preto p_adulto_pardo p_adulto] using "$log\Tabela_21a",  tex keep(caip) dec(3) rdec(3) title("Relationship between CAIP racial composition by age (share)") replace 

	
*** Young Population 

qui cap gen caip = .
qui replace caip = caip_20_B

local dep_vars "p_jovem_branco p_jovem_preto p_jovem_pardo p_jovem"

foreach dep_var in `dep_vars' {
    xtreg `dep_var' caip  i.a1960 if ano == 1872 & balance == 1 | ano == 1960 & balance == 1, fe
	qui estimates store `dep_var'
}


estimates table p_jovem_branco p_jovem_preto p_jovem_pardo p_jovem, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relationship between CAIP racial composition by age (share)")
	
	qui outreg2 [p_jovem_branco p_jovem_preto p_jovem_pardo p_jovem] using "$log\Tabela_21b",  tex keep(caip) dec(3) rdec(3) title("Relationship between CAIP racial composition by age (share)") replace 

	
	
*** Ln of Population
** Adult Population

qui cap gen caip = .
qui replace caip = caip_20_B

local dep_vars "ln_adulto_branco ln_adulto_preto ln_adulto_pardo ln_adulto_tot1"

foreach dep_var in `dep_vars' {
    xtreg `dep_var' caip  i.a1960 if ano == 1872 & balance == 1 | ano == 1960 & balance == 1, fe
	qui estimates store `dep_var'
}


estimates table ln_adulto_branco ln_adulto_preto ln_adulto_pardo ln_adulto_tot1, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relationship between CAIP racial composition by age (share)")
	
	qui outreg2 [ln_adulto_branco ln_adulto_preto ln_adulto_pardo ln_adulto_tot1] using "$log\Tabela_22a",  tex keep(caip) dec(3) rdec(3) title("Relationship between CAIP racial composition by age (share)") replace

*** Young Population
	
qui cap gen caip = .
qui replace caip = caip_20_B

local dep_vars "ln_jovem_branco ln_jovem_preto ln_jovem_pardo ln_jovem_tot2"

foreach dep_var in `dep_vars' {
    xtreg `dep_var' caip  i.a1960 if ano == 1872 & balance == 1 | ano == 1960 & balance == 1, fe
	qui estimates store `dep_var'
}


estimates table ln_jovem_branco ln_jovem_preto ln_jovem_pardo ln_jovem_tot2, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relationship between CAIP racial composition by age (share)")
	
	qui outreg2 [ln_jovem_branco ln_jovem_preto ln_jovem_pardo ln_jovem_tot2] using "$log\Tabela_22b",  tex keep(caip) dec(3) rdec(3) title("Relationship between CAIP racial composition by age (share)") replace
	
		
**** CAIP Volatility (Appendix)
qui cap gen caip = .


qui replace caip = dp_caip_20_A

local dep_vars "p_imig  p_branco p_preto p_pardo ln_pop_tot3"

foreach dep_var in `dep_vars' 
    xtreg `dep_var' caip  i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store volat_`dep_var'
}


estimates table volat_p_imig  volat_p_branco volat_p_preto  volat_p_pardo volat_ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relação entre volatilidade do CAIP e composição racial dos municípios.")
	
	qui outreg2 [volat_p_imig  volat_p_branco volat_p_preto  volat_p_pardo volat_ln_pop_tot3] using "$log\Tabela_13",  tex keep(caip) pdec(3) dec(3) title("Relationship between CAIP volatility adn racial composition of municipalities.") replace 


	


**** Estimating by region
** By Share 

qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo ln_pop_tot3"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#i.regiao i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
    margins  i.regiao, dydx(caip) post
    qui est store marg_`dep_var'
}



estimates table  p_imig p_branco p_preto p_pardo ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#i.regiao) title("Relação entre volatilidade do CAIP e composição racial dos municípios por região.")

est table marg_p_imig marg_p_branco marg_p_preto marg_p_pardo marg_ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")


qui outreg2 [p_imig p_branco p_preto p_pardo ln_pop_tot3] using "$log\Tabela_24a",  tex keep(caip c.caip#i.regiao) pdec(3) dec(3) title("Relationship between CAIP volatility adn racial composition of municipalities by Region.") replace


qui outreg2 [marg_p_imig marg_p_branco marg_p_preto marg_p_pardo marg_ln_pop_tot3] using "$log\Tabela_24b",  tex pdec(3) dec(3) title("Marginal Effects") replace



** By Ln 

qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars "ln_imig ln_branco ln_preto ln_pardo ln_pop_tot3"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#i.regiao i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
    margins  i.regiao, dydx(caip) post
    qui est store marg_`dep_var'
}


estimates table  ln_imig ln_branco ln_preto ln_pardo ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#i.regiao) title("Relação entre volatilidade do CAIP e composição racial dos municípios por região.")


qui outreg2 [ ln_imig ln_branco ln_preto ln_pardo ln_pop_tot3] using "$log\Tabela_25a",  tex keep(caip c.caip#i.regiao) pdec(3) dec(3) title("Relationship between CAIP volatility adn racial composition of municipalities by Region.") replace


est table   marg_ln_imig marg_ln_branco marg_ln_preto marg_ln_pardo marg_ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")

qui outreg2 [ marg_ln_imig marg_ln_branco marg_ln_preto marg_ln_pardo marg_ln_pop_tot3] using "$log\Tabela_25b",  tex pdec(3) dec(3) title("Marginal Effects") replace




**** Re-estimating by region in age groups
*** in share 
 
		
		
qui cap gen caip = .

qui replace caip = caip_20_B


local dep_vars "p_adulto_branco p_jovem_branco p_adulto_preto p_jovem_preto p_adulto_pardo p_jovem_pardo p_jovem p_adulto"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#i.regiao i.a1960 if ano == 1872 & balance == 1 | ano == 1960 & balance == 1, fe
	qui estimates store `dep_var'
    margins  i.regiao, dydx(caip) post
    qui est store marg_`dep_var'
}


estimates table p_adulto_branco p_jovem_branco p_adulto_preto p_jovem_preto p_adulto_pardo p_jovem_pardo p_jovem p_adulto, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#i.regiao) title("Relação entre volatilidade do CAIP e composição racial dos municípios por região e faixa etária por porcentagem.")


qui outreg2 [p_adulto_branco p_jovem_branco p_adulto_preto p_jovem_preto p_adulto_pardo p_jovem_pardo p_jovem p_adulto] using "$log\Tabela_26a",  tex keep(caip c.caip#i.regiao) pdec(3) dec(3) title("Relationship between CAIP volatility adn racial composition of municipalities by Region and age group (share).") replace


est table marg_p_adulto_branco marg_p_jovem_branco marg_p_adulto_preto marg_p_jovem_preto marg_p_adulto_pardo marg_p_jovem_pardo marg_p_jovem marg_p_adulto, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")

qui outreg2 [marg_p_adulto_branco marg_p_jovem_branco marg_p_adulto_preto marg_p_jovem_preto marg_p_adulto_pardo marg_p_jovem_pardo marg_p_jovem marg_p_adulto] using "$log\Tabela_26b",  tex pdec(3) dec(3) title("Marginal Effects") replace


	
	
*** In Lna
qui cap gen caip = .

qui replace caip = caip_20_B


local dep_vars "ln_adulto_branco ln_jovem_branco ln_adulto_preto ln_jovem_preto ln_adulto_pardo ln_jovem_pardo ln_jovem_tot2 ln_adulto_tot1"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#i.regiao i.a1960 if ano == 1872 & balance == 1 | ano == 1960 & balance == 1, fe
	qui estimates store `dep_var'
    margins  i.regiao, dydx(caip) post
    qui est store marg_`dep_var'
}


estimates table ln_adulto_branco ln_jovem_branco ln_adulto_preto ln_jovem_preto ln_adulto_pardo ln_jovem_pardo ln_jovem_tot2 ln_adulto_tot1, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#i.regiao) title("Relação entre volatilidade do CAIP e composição racial dos municípios por região e faixa etária em log.")


qui outreg2 [ln_adulto_branco ln_jovem_branco ln_adulto_preto ln_jovem_preto ln_adulto_pardo ln_jovem_pardo ln_jovem_tot2 ln_adulto_tot1] using "$log\Tabela_27a",  tex keep(caip c.caip#i.regiao) pdec(3) dec(3) title("Relationship between CAIP volatility adn racial composition of municipalities by Region and age group (log).") replace


est table marg_ln_adulto_branco marg_ln_jovem_branco marg_ln_adulto_preto marg_ln_jovem_preto marg_ln_adulto_pardo marg_ln_jovem_pardo marg_ln_jovem_tot2 marg_ln_adulto_tot1, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")

qui outreg2 [marg_ln_adulto_branco marg_ln_jovem_branco marg_ln_adulto_preto marg_ln_jovem_preto marg_ln_adulto_pardo marg_ln_jovem_pardo marg_ln_jovem_tot2 marg_ln_adulto_tot1] using "$log\Tabela_27b",  tex pdec(3) dec(3) title("Marginal Effects") replace

	


****** 1872 Cross-Section Regression on slavery


local dep_vars "prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre "


foreach dep_var in `dep_vars' {
    reg `dep_var' caip_20_1872 dist_capital dist_ocean c.caip_20_1872#i.regiao if ano == 1872, vce(robust)
	qui estimates store `dep_var'
    margins i.regiao, dydx(caip_20_1872) post
    qui est store marg_`dep_var'
}


estimates table prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip_20_1872 c.caip_20_1872#i.regiao) title("Relação entre volatilidade do CAIP e composição racial dos municípios por região.")


qui outreg2 [prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre] using "$log\Tabela_28a",  tex keep(caip_20_1872 c.caip_20_1872#i.regiao) pdec(3) dec(3) title("Relationship between CAIP volatility and racial composition of municipalities by Region in 1872.") replace


est table  marg_prop_esc marg_prop_pret_esc marg_prop_pard_esc marg_prop_pret_livre marg_prop_pard_livre, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")

qui outreg2 [marg_prop_esc marg_prop_pret_esc marg_prop_pard_esc marg_prop_pret_livre marg_prop_pard_livre] using "$log\Tabela_28b",  tex pdec(3) dec(3) title("Marginal Effects") replace


local dep_vars "p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3"

foreach dep_var in `dep_vars' {
    reg `dep_var' caip_20_1872 dist_capital dist_ocean c.caip_20_1872#i.regiao if ano == 1872, vce(robust)
	qui estimates store `dep_var'
    margins i.regiao, dydx(caip_20_1872) post
    qui est store marg_`dep_var'
}
	
estimates table p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip_20_1872 c.caip_20_1872#i.regiao) title("Relação entre volatilidade do CAIP e composição racial dos municípios por região.")

qui outreg2 [p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3] using "$log\Tabela_29a",  tex keep(caip_20_1872 c.caip_20_1872#i.regiao) pdec(3) dec(3) title("Relationship between CAIP volatility and racial composition of municipalities by Region in 1872.") replace

est table  marg_p_mig_int marg_p_imig marg_p_branco marg_p_preto marg_p_pardo marg_ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")

qui outreg2 [marg_p_mig_int marg_p_imig marg_p_branco marg_p_preto marg_p_pardo marg_ln_pop_tot3] using "$log\Tabela_29b",  tex pdec(3) dec(3) title("Marginal Effects") replace




*** Cross-Section Regression with potential of each crop

**Racial Composition
**CAIP
local dep_vars "p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3"


foreach dep_var in `dep_vars' {
   	reg `dep_var' caip_20_1872 dist_capital dist_ocean  if ano == 1872 , vce(robust)
	qui estimates store `dep_var'
}

estimates table  p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip_20_1872) title("CAIP  1872")

qui outreg2 [p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3] using "$log\Tabela_59a",  tex keep(caip_20_1872) pdec(3) dec(3) title("CAIP 1872") replace

** CAIP Components

local dep_vars "p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3"


foreach dep_var in `dep_vars' {
   	reg `dep_var' mfit_cafe_1872 mfit_acucar_1872 mfit_algodao_1872 mfit_tabaco_1872 mfit_cacau_1872, vce(robust)
	qui estimates store `dep_var'
}

estimates table  p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(mfit_cafe_1872 mfit_acucar_1872 mfit_algodao_1872 mfit_tabaco_1872 mfit_cacau_1872 ) title("CAIP Components 1872")

qui outreg2 [p_mig_int p_imig p_branco p_preto p_pardo ln_pop_tot3] using "$log\Tabela_59b",  tex keep(mfit_cafe_1872 mfit_acucar_1872 mfit_algodao_1872 mfit_tabaco_1872 mfit_cacau_1872) pdec(3) dec(3) title("CAIP Components 1872") replace


**Slavery data
**CAIP

local dep_vars "prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre"

foreach dep_var in `dep_vars' {
   	reg `dep_var' caip_20_1872 dist_capital dist_ocean  if ano == 1872 , vce(robust)
	qui estimates store `dep_var'
}

estimates table  prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip_20_1872) title("CAIP  1872")

qui outreg2 [prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre] using "$log\Tabela_60a",  tex keep(caip_20_1872) pdec(3) dec(3) title("CAIP 1872") replace

** CAIP Components

local dep_vars "prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre"


foreach dep_var in `dep_vars' {
   	reg `dep_var' mfit_cafe_1872 mfit_acucar_1872 mfit_algodao_1872 mfit_tabaco_1872 mfit_cacau_1872 if ano == 1872, vce(robust)
	qui estimates store `dep_var'
}

estimates table  prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(mfit_cafe_1872 mfit_acucar_1872 mfit_algodao_1872 mfit_tabaco_1872 mfit_cacau_1872) title("CAIP Components 1872")

qui outreg2 [prop_esc prop_pret_esc prop_pard_esc prop_pret_livre prop_pard_livre] using "$log\Tabela_60b",  tex keep(mfit_cafe_1872 mfit_acucar_1872 mfit_algodao_1872 mfit_tabaco_1872 mfit_cacau_1872) pdec(3) dec(3) title("CAIP Components 1872") replace



corr ay_caf ay_acu ay_alg ay_tab ay_cac a1 a2 a3 a4 a5 if ano == 1872 | ano == 1940 | ano == 1950
esttab using "$log\Tabela_corr", tex replace






**** Structural Change 

**General
qui cap gen caip = .
qui replace caip = caip_20_A


local dep_vars "p_agro p_inds p_serv"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
}


estimates table p_agro p_inds p_serv, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("Relação entre CAIP e Mudança estrutural (share)")


qui outreg2 [p_agro p_inds p_serv] using "$log\Tabela_30",  tex keep(caip) pdec(3) dec(3) title("Relação entre CAIP e Mudança estrutural (share)") replace



**By region (not used)

qui cap gen caip = .
qui replace caip = caip_20_A


local dep_vars "p_agro p_inds p_serv"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#i.regiao i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
    margins  i.regiao, dydx(caip) post
    qui est store marg_`dep_var'
}


estimates table p_agro p_inds p_serv, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#i.regiao) title("Relação entre CAIP e Mudança estrutural por região (share)")


qui outreg2 [p_agro p_inds p_serv] using "$log\Tabela_31a",  tex keep(caip c.caip#i.regiao) pdec(3) dec(3) title("Relação entre CAIP e Mudança estrutural por região (share)") replace


est table marg_p_agro marg_p_inds marg_p_serv, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")

qui outreg2 [marg_p_agro marg_p_inds marg_p_serv] using "$log\Tabela_31b",  tex pdec(3) dec(3) title("Marginal Effects") replace




*** Slavery in 1872 (and interaction with CAIP) ****

 

qui cap gen caip = .
qui replace caip = caip_20_A


local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#c.prop_esc prop_esc i.a1940 i.a1950  if ano == 1872 | ano == 1940 | ano == 1950  , fe cluster(amc)
	 estimates store `dep_var'   
	
}

	
estimates table p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#c.prop_esc) title("Tabela 9. Relação entre CAIP e Composição Racial, controlando pela interação entre CAIP e parcela de escravizados na população geral em 1872. Anos: 1940 e 1950 .")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_9",  tex keep(caip c.caip#c.prop_esc) pdec(3) dec(3) title("Tabela 9. Relação entre CAIP e Composição Racial, controlando pela interação entre CAIP e parcela de escravizados na população geral em 1872. Anos: 1872 à 1950") replace
	


*** 1872 Dummy *****



qui cap gen caip = .
qui replace caip = caip_20_A


local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#i.a1872 i.a1940 i.a1950  if ano == 1872 | ano == 1940 | ano == 1950  , fe cluster(amc)
	 estimates store `dep_var'
	  margins  i.a1872, dydx(caip) post
    qui est store marg_`dep_var'
}


estimates table p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#i.a1872) title("Tabela 10. Relação entre CAIP e Composição Racial, controlando pela interação entre CAIP e parcela de dummy de 1872. Anos: 1872 à 1950 ")


est table  marg_p_imig marg_p_branco marg_p_preto marg_p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")


qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_10a",  tex keep(caip c.caip#i.a1872) pdec(3) dec(3) title("Tabela 10. Relação entre CAIP e Composição Racial, controlando pela interação entre CAIP e parcela de dummy de 1872. Anos: 1872 à 1950" ) replace
	
qui outreg2 [marg_p_imig marg_p_branco marg_p_preto marg_p_pardo] using "$log\Tabela_10b",  tex pdec(3) dec(3) title("Marginal Effects") replace




**** São Paulo State Dummy
**General
	

qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#i.dummy_sp i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
    margins  i.dummy_sp, dydx(caip) post
    qui est store marg_`dep_var'
}


estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#i.dummy_sp) title("Relação entre CAIP e composição racial dos municípios com dummy para SP")

est table  marg_p_imig marg_p_branco marg_p_preto marg_p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) title("Efeitos Marginais")


qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_32a",  tex keep(caip c.caip#i.dummy_sp) pdec(3) dec(3) title("Relationship between CAIP and racial composition of municipalities considering SP dummy.") replace


qui outreg2 [marg_p_imig marg_p_branco marg_p_preto marg_p_pardo] using "$log\Tabela_32b",  tex pdec(3) dec(3) title("Marginal Effects") replace


** Interacting with the percentage of slaves in 1872 (Share)

qui cap gen caip = .

qui replace caip = caip_20_SP

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip c.caip#c.prop_esc i.a1950 if ano == 1940 & dummy_sp == 1| ano == 1950 & dummy_sp == 1, fe cluster(amc)
	qui estimates store `dep_var'
    
}

estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip c.caip#c.prop_esc) title("Relação entre CAIP e composição racial dos municípios do estado de SP")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_35",  tex keep(caip c.caip#c.prop_esc) pdec(3) dec(3) title("Relationship between CAIP and racial composition of municipalities considering SP state.") replace

coefplot p_imig p_branco p_preto p_pardo, drop(_cons) keep(caip) xline(0)


**** Robustness Tests:
*CAIP restricting some prices to the year 1872


** Restricting Coffee
qui cap gen caip = .

qui replace caip = caip_caf_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
	
}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP restricting coffee")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_36",  tex keep(caip) pdec(3) dec(3) title("CAIP restricting coffee.") replace

	

** Restricting Sugar
qui replace caip = caip_acu_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
	
}
	
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP restricting sugar")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_37",  tex keep(caip) pdec(3) dec(3) title("CAIP restricting sugar.") replace



** Restricting Tobacco
qui replace caip = caip_alg_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
	
}
	
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP restricting cotton")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_38",  tex keep(caip) pdec(3) dec(3) title("CAIP restricting cotton.") replace



** Restricting Tobacco
qui replace caip = caip_tab_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
	
}
	
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP restricting tobacco")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_39",  tex keep(caip) pdec(3) dec(3) title("CAIP restricting tobacco.") replace



** Restricting Cocoa
qui replace caip = caip_cac_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
	
}
	
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP restricting cocoa")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_40",  tex keep(caip) pdec(3) dec(3) title("CAIP restricting cocoa.") replace



**General CAIP

qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'
	
}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP General")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_41",  tex keep(caip) pdec(3) dec(3) title("CAIP General.") replace

	
	
*** Robustness Tests: Median and Mean CAIP for 10 and 20 years


** ** Standard CAIP (20 years mean)

qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP General")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_41",  tex keep(caip) pdec(3) dec(3) title("CAIP General.") replace


**CAIP 10 years mean

qui cap gen caip = .

qui replace caip = caip_10_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP 10 years mean")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_42",  tex keep(caip) pdec(3) dec(3) title("CAIP 10 years mean.") replace



***CAIP 20 years median 

qui cap gen caip = .

qui replace caip = caip_median20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP 20 years median")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_43",  tex keep(caip) pdec(3) dec(3) title("CAIP 20 years median.") replace




*** CAIP 10 years median

qui cap gen caip = .

qui replace caip = caip_median10_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP 10 years median")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_44",  tex keep(caip) pdec(3) dec(3) title("CAIP 10 years median.") replace



*** Robustez: CAIP e geographic variables

** Standard  CAIP
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip) title("CAIP General")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_41",  tex keep(caip) pdec(3) dec(3) title("CAIP General.") replace


*** CAIP controlling  by discance to the ocean
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_dist_ocean i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_dist_ocean) title("CAIP Dist Oceani")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_44",  tex keep(caip mpreco_dist_ocean) pdec(3) dec(3) title("CAIP Dist Oceano.") replace



*** CAIP controlling  by discance to the capital city
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_dist_capital i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_dist_capital) title("CAIP controle Dist da capital")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_45",  tex keep(caip mpreco_dist_capital) pdec(3) dec(3) title("CAIP controle Dist da capital.") replace



*** CAIP controlling  by altitude 
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_alti i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_alti) title("CAIP controle Altitude ")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_46",  tex keep(caip mpreco_alti) pdec(3) dec(3) title("CAIP controle Altitude .") replace



*** CAIP controlling  by  Latitude
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_lati i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_lati) title("CAIP controle Latitude")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_47",  tex keep(caip mpreco_lati) pdec(3) dec(3) title("CAIP controle Latitude") replace



*** CAIP controlling by average spring temperature
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_t_pri i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_t_pri) title("CAIP controle Temp Media Primavera")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_48",  tex keep(caip mpreco_t_pri) pdec(3) dec(3) title("CCAIP controle Temp Media Primavera.") replace



*** CAIP controlling by average summer temperature
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_t_ver i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_t_ver) title("CAIP controle Temp Media Verão")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_49",  tex keep(caip mpreco_t_ver) pdec(3) dec(3) title("CAIP controle Temp Media Verão.") replace



*** CAIP controlling by average fall temperature
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_t_out i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_t_out) title(" CAIP controle Temp Media Outono")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_50",  tex keep(caip mpreco_t_out) pdec(3) dec(3) title("CAIP controle Temp Media Outono") replace



*** CAIP controlling by average winter temperature
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_t_inv i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_t_inv) title("CAIP controle Temp Media Inverno")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_51",  tex keep(caip mpreco_t_inv) pdec(3) dec(3) title("CAIP controle Temp Media Inverno") replace



*** CAIP controlling by average spring rainfall
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_ch_pri i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_ch_pri) title("CAIP controle Média Pluviométrica Primavera")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_52",  tex keep(caip mpreco_ch_pri) pdec(3) dec(3) title("CAIP controle Média Pluviométrica Primavera.") replace



*** CAIP controlling by average summer rainfall
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_ch_ver i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_ch_ver) title("CAIP controle Média Pluviométrica Verão")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_53",  tex keep(caip mpreco_ch_ver) pdec(3) dec(3) title("CAIP controle Média Pluviométrica Verão") replace



*** CAIP controlling by average fall rainfall
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_ch_out i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_ch_out) title("CAIP controle Média Pluviométrica Outono")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_54",  tex keep(caip mpreco_ch_out) pdec(3) dec(3) title("CAIP controle Média Pluviométrica Outono.") replace



*** CAIP controlling by average winter rainfall
qui cap gen caip = .

qui replace caip = caip_20_A

local dep_vars " p_imig p_branco p_preto p_pardo"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' caip mpreco_ch_inv i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip mpreco_ch_inv) title("CAIP controle Média Pluviométrica Inverno")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_55",  tex keep(caip mpreco_ch_inv) pdec(3) dec(3) title("CAIP controle Média Pluviométrica Inverno") replace


******** CAIP Components


qui cap gen caip = .

local dep_vars " p_imig p_branco p_preto p_pardo ln_pop_tot3"

foreach dep_var in `dep_vars' {
   	xtreg `dep_var' mfit_cafe mfit_acucar mfit_algodao mfit_tabaco mfit_cacau  i.a1940 i.a1950 if ano == 1872 | ano == 1940 | ano == 1950, fe cluster(amc)
	qui estimates store `dep_var'

}
	
estimates table  p_imig p_branco p_preto p_pardo ln_pop_tot3, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(mfit_cafe mfit_acucar mfit_algodao mfit_tabaco mfit_cacau) title("CAIP Components")

qui outreg2 [p_imig p_branco p_preto p_pardo ln_pop_tot3] using "$log\Tabela_56",  tex keep(mfit_cafe mfit_acucar mfit_algodao mfit_tabaco mfit_cacau) pdec(3) dec(3) title("CAIP Components") replace



**** Long-term CAIP effects 

merge m:1 amc using "C:\LOGIT\OneDrive - LOGIT\Área de Trabalho\Mestrado\Dissertação\Base\base_caip_temp_7250.dta" 

keep if ano == 2010

egen caip_temp_7250_pad = std(caip_temp_7250) if ano == 2010 , mean(0) std(1)


local dep_vars "p_imig p_branco p_preto p_pardo p_inds p_naescola dif_es gini_renda dif_renda "

foreach dep_var in `dep_vars' {
   	reg `dep_var' caip_temp_7250_pad 
	qui estimates store `dep_var'

}


estimates table p_imig p_branco p_preto p_pardo, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip_temp_7250_pad) title("CAIP Long Term Effects - Racial Composition")

qui outreg2 [p_imig p_branco p_preto p_pardo] using "$log\Tabela_57",  tex keep(caip_temp_7250_pad) pdec(3) dec(3) title("CAIP Long Term Effects - Racial Composition") replace

estimates table p_inds p_naescola dif_es gini_renda dif_renda, stats(N N_clust) star(.1 .05 .01) b(%6,3f) keep(caip_temp_7250_pad) title("CAIP Long Term Effects - Inequality")

qui outreg2 [p_inds p_naescola dif_es gini_renda dif_renda] using "$log\Tabela_58",  tex keep(caip_temp_7250_pad) pdec(3) dec(3) title("CAIP Long Term Effects - Inequality") replace


}
