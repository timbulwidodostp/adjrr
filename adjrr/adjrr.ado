*! Stata version 12  12mar2013

capture program drop adjrr
program define adjrr, rclass
	syntax varlist(max=1) [if] [, x0(real 0) x1(real 1) at(string asis)] 
	tempname r0 r0_se r1 r1_se pval pval2 arr ard arr_se ard_se lnarr lnarr_se q

	estimates store regresults
	
	preserve
	if "`if'" ~= "" {
		quietly keep `if'
		}
	
	if "`e(prefix)'" == "svy" {
		local userse = "vce(unconditional)" 
		}
	else if "`e(prefix)'" ~= "svy" {
		local userse = ""
		}

	if "`e(cmd)'" == "logit" | "`e(cmd)'" == "probit" | "`e(cmd)'" == "logistic"{
		quietly {
			margins, at(`varlist' = (`x0' `x1') `at') `userse' post 

			estimates store margresults

			scalar `r0' = _b[1._at]
			scalar `r0_se' = _se[1._at]
			scalar `r1' = _b[2._at]
			scalar `r1_se' = _se[2._at]
			
			return scalar R1_se = _se[2._at]
			return scalar R1 = _b[2._at]
			return scalar R0_se = _se[1._at]
			return scalar R0 = _b[1._at]
			return scalar N = r(N)	
			
			test _b[1._at] = _b[2._at]
			scalar `pval' = r(p)
			return scalar pvalue = r(p)
			
			testnl ln(_b[2._at] / _b[1._at]) = 0
			scalar `pval2' = r(p)
			return scalar pvalue2 = r(p)
			
			nlcom (ARR: _b[2._at] / _b[1._at]), post
			scalar `arr' = _b[ARR]
			scalar `arr_se' = _se[ARR]

			return scalar ARR_se = _se[ARR]
			return scalar ARR = _b[ARR]
			
			estimates restore margresults
			
			nlcom (lnARR: ln(_b[2._at] / _b[1._at])), post
			scalar `lnarr' = _b[lnARR]
			scalar `lnarr_se' = _se[lnARR]
			
			estimates restore margresults 

			nlcom (ARD: _b[2._at] - _b[1._at]), post
			scalar `ard' = _b[ARD]
			scalar `ard_se' = _se[ARD]
						
			return scalar ARD_se = _se[ARD]
			return scalar ARD = _b[ARD]
			
			estimates restore regresults
			estimates drop margresults
		}
		display
		display "R1  = " %-6.4f `r1' " (" %-6.4f `r1_se' ")    95% CI  (" ///
			%-6.4f `r1'-invnorm(0.975)*`r1_se' ", " %-6.4f `r1'+invnorm(0.975)*`r1_se' ")"
		display "R0  = " %-6.4f `r0' " (" %-6.4f `r0_se' ")    95% CI  (" ///
			%-6.4f `r0'-invnorm(0.975)*`r0_se' ", " %-6.4f `r0'+invnorm(0.975)*`r0_se' ")"
		display "ARR = " %-6.4f `arr' " (" %-6.4f `arr_se' ")    95% CI  (" ///
			%-6.4f exp(`lnarr' -invnorm(0.975)*`lnarr_se') ", " ///
			%-6.4f exp(`lnarr'+ invnorm(0.975)*`lnarr_se') ")"
		display "ARD = " %-6.4f `ard' " (" %-6.4f `ard_se' ")    95% CI  (" ///
			%-6.4f `ard'-invnorm(0.975)*`ard_se' ", " %-6.4f `ard'+invnorm(0.975)*`ard_se' ")" 
		display "p-value (R0 = R1):  " %-6.4f `pval'
		display "p-value (ln(R1/R0) = 0):  " %-6.4f `pval2'
	}


	
	local outcomes = e(k_out)
	matrix define k = e(out) 
	
	if "`e(cmd)'" == "mlogit" {
		forvalues i = 1(1)`outcomes' {
			quietly {
				local q = k[1,`i']
				margins, at(`varlist' = (`x0' `x1')) predict(outcome(`q')) `userse' post
				
				estimates store margresults				
				
				scalar `r0' = _b[1._at]
				scalar `r0_se' = _se[1._at]
				scalar `r1' = _b[2._at]
				scalar `r1_se' = _se[2._at]
			
				return scalar R1_se_`i' = _se[2._at]
				return scalar R1_`i' = _b[2._at]
				return scalar R0_se_`i' = _se[1._at]
				return scalar R0_`i' = _b[1._at]
				return scalar N = r(N)	
				
				test _b[1._at] = _b[2._at]
				scalar `pval' = r(p)
				return scalar pvalue_`i' = r(p)
				
				testnl ln(_b[2._at] / _b[1._at]) = 0
				scalar `pval2' = r(p)
				return scalar pvalue2_`i' = r(p)
				
				nlcom (ARR: _b[2._at] / _b[1._at]), post
				scalar `arr' = _b[ARR]
				scalar `arr_se' = _se[ARR]
			
				estimates restore margresults
				
				nlcom (lnARR: ln(_b[2._at] / _b[1._at])), post
				scalar `lnarr' = _b[lnARR]
				scalar `lnarr_se' = _se[lnARR]
			
				estimates restore margresults 
			
				nlcom (ARD: _b[2._at] - _b[1._at]), post
				scalar `ard' = _b[ARD]
				scalar `ard_se' = _se[ARD]
			
				estimates restore regresults
				estimates drop margresults
			}
		display 
		display "R1(outcome " `q' ")  = " %-6.4f `r1' " (" %-6.4f `r1_se' ")    95% CI  (" ///
			%-6.4f `r1'-invnorm(0.975)*`r1_se' ", " %-6.4f `r1'+invnorm(0.975)*`r1_se' ")"
		display "R0(outcome " `q' ")  = " %-6.4f `r0' " (" %-6.4f `r0_se' ")    95% CI  (" ///
			%-6.4f `r0'-invnorm(0.975)*`r0_se' ", " %-6.4f `r0'+invnorm(0.975)*`r0_se' ")"
		display "ARR(outcome " `q' ") = " %-6.4f `arr' " (" %-6.4f `arr_se' ")    95% CI  (" ///
			%-6.4f exp(`lnarr' -invnorm(0.975)*`lnarr_se') ", " ///
			%-6.4f exp(`lnarr'+ invnorm(0.975)*`lnarr_se') ")"
		display "ARD(outcome " `q' ") = " %-6.4f `ard' " (" %-6.4f `ard_se' ")    95% CI  (" ///
			%-6.4f `ard'-invnorm(0.975)*`ard_se' ", " %-6.4f `ard'+invnorm(0.975)*`ard_se' ")" 
		display "p-value (R0 = R1)(outcome " `q' "):  " %-6.4f `pval'
		display "p-value (ln(R1/R0) = 0)(outcome " `q' "):  " %-6.4f `pval2'
		}
	}
	

	local outcomes = e(k_out)
	matrix define z = e(outcomes) 

	if "`e(cmd)'" == "mprobit" {
		forvalues i = 1(1)`outcomes' {
			quietly {
				local q = z[`i',1]
				margins, at(`varlist' = (`x0' `x1')) predict(outcome(`q')) `userse' post

				estimates store margresults

				scalar `r0' = _b[1._at]
				scalar `r0_se' = _se[1._at]
				scalar `r1' = _b[2._at]
				scalar `r1_se' = _se[2._at]
				
				return scalar R1_se_`i' = _se[2._at]
				return scalar R1_`i' = _b[2._at]
				return scalar R0_se_`i' = _se[1._at]
				return scalar R0_`i' = _b[1._at]
				return scalar N = r(N)	
				
				test _b[1._at] = _b[2._at]
				scalar `pval' = r(p)
				return scalar pvalue_`i' = r(p)		
				
				testnl ln(_b[2._at] / _b[1._at]) = 0
				scalar `pval2' = r(p)
				return scalar pvalue2_`i' = r(p)
				
				nlcom (ARR: _b[2._at] / _b[1._at]), post
				scalar `arr' = _b[ARR]
				scalar `arr_se' = _se[ARR]
			
				estimates restore margresults

				nlcom (lnARR: ln(_b[2._at] / _b[1._at])), post
				scalar `lnarr' = _b[lnARR]
				scalar `lnarr_se' = _se[lnARR]
			
				estimates restore margresults 
			
				nlcom (ARD: _b[2._at] - _b[1._at]), post
				scalar `ard' = _b[ARD]
				scalar `ard_se' = _se[ARD]
			
				estimates restore regresults
				estimates drop margresults
			}
		display 
		display "R1(outcome " `q' ")  = " %-6.4f `r1' " (" %-6.4f `r1_se' ")    95% CI  (" ///
			%-6.4f `r1'-invnorm(0.975)*`r1_se' ", " %-6.4f `r1'+invnorm(0.975)*`r1_se' ")"
		display "R0(outcome " `q' ")  = " %-6.4f `r0' " (" %-6.4f `r0_se' ")    95% CI  (" ///
			%-6.4f `r0'-invnorm(0.975)*`r0_se' ", " %-6.4f `r0'+invnorm(0.975)*`r0_se' ")"
		display "ARR(outcome " `q' ") = " %-6.4f `arr' " (" %-6.4f `arr_se' ")    95% CI  (" ///
			%-6.4f exp(`lnarr' -invnorm(0.975)*`lnarr_se') ", " ///
			%-6.4f exp(`lnarr'+ invnorm(0.975)*`lnarr_se') ")"
		display "ARD(outcome " `q' ") = " %-6.4f `ard' " (" %-6.4f `ard_se' ")    95% CI  (" ///
			%-6.4f `ard'-invnorm(0.975)*`ard_se' ", " %-6.4f `ard'+invnorm(0.975)*`ard_se' ")" 
		display "p-value (R0 = R1)(outcome " `q' "):  " %-6.4f `pval'
		display "p-value (ln(R1/R0) = 0)(outcome " `q' "):  " %-6.4f `pval2'
		}
	}
	
	
	local categories = e(k_cat)
	matrix define j = e(cat)
	
	if "`e(cmd)'" == "ologit" | "`e(cmd)'" == "oprobit"{
		forvalues i = 1(1)`categories' {
			quietly {
				local q = j[1,`i']
				margins, at(`varlist' = (`x0' `x1')) predict(outcome(`q')) `userse' post

				estimates store margresults

				scalar `r0' = _b[1._at]
				scalar `r0_se' = _se[1._at]
				scalar `r1' = _b[2._at]
				scalar `r1_se' = _se[2._at]				
				
				return scalar R1_se_`i' = _se[2._at]
				return scalar R1_`i' = _b[2._at]
				return scalar R0_se_`i' = _se[1._at]
				return scalar R0_`i' = _b[1._at]
				return scalar N = r(N)	
				
				test _b[1._at] = _b[2._at]
				scalar `pval' = r(p)
				return scalar pvalue_`i' = r(p)

				testnl ln(_b[2._at] / _b[1._at]) = 0
				scalar `pval2' = r(p)
				return scalar pvalue2_`i' = r(p)
				
				nlcom (ARR: _b[2._at] / _b[1._at]), post
				scalar `arr' = _b[ARR]
				scalar `arr_se' = _se[ARR]
			
				estimates restore margresults
				
				nlcom (lnARR: ln(_b[2._at] / _b[1._at])), post
				scalar `lnarr' = _b[lnARR]
				scalar `lnarr_se' = _se[lnARR]
			
				estimates restore margresults 
			
				nlcom (ARD: _b[2._at] - _b[1._at]), post
				scalar `ard' = _b[ARD]
				scalar `ard_se' = _se[ARD]
			
				estimates restore regresults
				estimates drop margresults
			}
		display 
		display "R1(outcome " `q' ")  = " %-6.4f `r1' " (" %-6.4f `r1_se' ")    95% CI  (" ///
			%-6.4f `r1'-invnorm(0.975)*`r1_se' ", " %-6.4f `r1'+invnorm(0.975)*`r1_se' ")"
		display "R0(outcome " `q' ")  = " %-6.4f `r0' " (" %-6.4f `r0_se' ")    95% CI  (" ///
			%-6.4f `r0'-invnorm(0.975)*`r0_se' ", " %-6.4f `r0'+invnorm(0.975)*`r0_se' ")"
		display "ARR(outcome " `q' ") = " %-6.4f `arr' " (" %-6.4f `arr_se' ")    95% CI  (" ///
			%-6.4f exp(`lnarr' -invnorm(0.975)*`lnarr_se') ", " ///
			%-6.4f exp(`lnarr'+ invnorm(0.975)*`lnarr_se') ")"
		display "ARD(outcome " `q' ") = " %-6.4f `ard' " (" %-6.4f `ard_se' ")    95% CI  (" ///
			%-6.4f `ard'-invnorm(0.975)*`ard_se' ", " %-6.4f `ard'+invnorm(0.975)*`ard_se' ")" 
		display "p-value (R0 = R1)(outcome " `q' "):  " %-6.4f `pval'
		display "p-value (ln(R1/R0) = 0)(outcome " `q' "):  " %-6.4f `pval2'
	
		}
	}
	else if "`e(cmd)'" ~= "logit" & "`e(cmd)'" ~= "probit" &  "`e(cmd)'" ~= "logistic" & ///
		"`e(cmd)'" ~= "mlogit" & "`e(cmd)'" ~= "mprobit" & "`e(cmd)'" ~= "ologit" & "`e(cmd)'" ~= "oprobit" {
		display "-adjrr- only works with -logit-, -logistic-, -probit-, -mlogit-, -mprobit-, -ologit- & -oprobit-"
		}
	
	restore
end	
	
