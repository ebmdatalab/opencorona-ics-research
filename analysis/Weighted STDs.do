cap program drop _stddiff2
program define _stddiff2, rclass
	version 13.0
	syntax varlist  [if] [in], by(varname) [continuous categorical cohensd hedgesg abs]
	tempname m1 m2 v1 v2 s1 s2 res table output r
	if("`continuous'"=="" & "`categorical'"==""){
		local continuous="continuous"
	}
	if("`continuous'"=="continuous" ){
		foreach v of varlist `varlist'{
			qui tabstat `v' `if' `in' [fw = wts] , by(`by') stat(mean n v sd) save
			mat `s1'=r(Stat1)
			mat `s2'=r(Stat2)
			scalar `v1'=`s1'[3,1]
			scalar `v2'=`s2'[3,1]
			scalar `m1'=`s1'[1,1]
			scalar `m2'=`s2'[1,1]
			
			if( "`hedgesg'"=="hedgesg"){
				qui esize twosample `v' `if' `in' , by(`by') `hedgesg'
				local sd=r(g)
			}
			else if("`cohensd'"=="cohensd"){
				qui esize twosample `v' `if' `in', by(`by') `cohensd'
				local sd=r(d)
			}
			else{
				local sd= (`m1'-`m2') /  sqrt((`v1'+`v2' )/2)
			}
		mat `res'=nullmat(`res') \ `sd'
		if("`abs'"=="abs") local sd=abs(`sd')
		mat `output' = nullmat(`output') \ `m1', `s1'[4,1], `m2', `s2'[4,1], `sd' , 1
		local vlist "`vlist' `v'"
		local llist "`llist' `v'"
		}
	}
	else{ // categorical varaibles
		foreach v of varlist `varlist'{
			qui tab `v' `by' `if' `in' [fw = wts], matcell(`table') matrow(`r')
			mata: matasd(st_matrix("`table'"))
			mat `res'=nullmat(`res') \ r(std)
			mat `output'=nullmat(`output') \ J(2,6,.z) \ (r(output) , J(rowsof(r(output)),1,2)) \ J(1,6,.z) 
			local vv="`v' " *rowsof(r(output))
			local vlist "`vlist' `vv'" 
			mata: st_local("isvallab",st_varvaluelabel("`v'"))
			if("`isvallab'"==""){
				mata: st_local("rstring",invtokens(strofreal(st_matrix("`r'")')))
			}
			else{
				mata: st_local("rstring",invtokens(st_vlmap(st_varvaluelabel("`v'"),st_matrix("`r'")')))
			}
			local llist = "`llist' . `v' `rstring' ."
		}
	}
	return matrix sds = `res'
	return matrix output = `output'
	return local vlist = "`vlist'"
	return local llist = "`llist'"
end program



cap program drop stddiff2
program define stddiff2, rclass
	version 13.0
	* Ahmed Bayoumi
	* version 0.2
	syntax varlist(fv) [if] [in] , BY(varname numeric) [ ///
		COHensd  ///  report cohensd as calculated by esize
		HEDgesg ///  report hedgesg as calculated by esize 
		abs /// report absolute values
	]
	tempname sds  output 
	qui inspect `by' `if' `in' // check that by has only 2 levels
	if (r(N_unique)!=2){
		di as error "`by' can only have 2 categories"
		error 420
	}

	foreach v in `varlist'{
		fvexpand(`v')
		capture assert r(fvops)=="true"
		if(_rc==0){
			_ms_parse_parts 1.`v'
			local v=r(name)
			_stddiff2  `v' `if' `in', by(`by') `opts' `cohensd' `hedgesg' categorical	// for each, call stddiff program
		}
		else{
			_stddiff2  `v' `if' `in', by(`by') `opts' `cohensd' `hedgesg' continuous `abs' // for each, call stddiff program

		}
		matrix `sds'= nullmat(`sds') \ r(sds)
		matrix `output' = nullmat(`output') \ r(output)
		local llist ="`llist' " + r(llist)
	}
	
	stddiff_display2, output(`output') llist(`llist') by("`by'")

	matrix rownames `sds' = `vlist'	
	matrix rownames `output' = `llist'
	matrix colnames `sds'=Std_Diff
	matrix colnames `output' = Mean_or_N SD_or_% Mean_or_N SD_or_% Std_Diff Var_type
	matrix coleq `output'= `by'=`l1' `by'=`l1' `by'=`l2' `by'=`l2'  .
	
	return matrix stddiff=`sds'
	return matrix output = `output'
end program	


cap program drop stddiff_display2	
program define stddiff_display2
	syntax [if] [in], output(name) llist(string) by(string)
//	di as text "Standardized Differences" _n
	tempname rt
	qui tab `by' `if' `in', matrow(`rt')
	mata: st_local("isvallab",st_varvaluelabel("`by'"))
	if("`isvallab'"==""){
		mata: st_local("rstring",invtokens(strofreal(st_matrix("`rt'")')))
	}
	else{
		mata: st_local("rstring",invtokens(st_vlmap(st_varvaluelabel("`by'"),st_matrix("`rt'")')))
	}

	local l1=word("`rstring'",1)
	local l2=word("`rstring'",2)

	di as text _n "{hline 13}{c TT}{hline 25}{c TT}{hline 25}{c TT}{hline 12}" _n /*
		*/ _col(14) "{c |}" "{rcenter 25:`=abbrev("`by'=`l1'",24)' }" /*
		*/ _col(40) "{c |}" "{rcenter 25:`=abbrev("`by'=`l2'",24)' }" /*
		*/ _col(66) "{c |}" _n /*
		*/ _col(14) "{c |}{ralign 10:Mean or N} {ralign 13:SD or (%)} " /*
		*/  		"{c |}{ralign 10:Mean or N} {ralign 13:SD or (%)} " /*
		*/  "{c |}{ralign 10:Std Diff}" _n /*
		*/ "{hline 13}{c +}{hline 25}{c +}{hline 25}{c +}{hline 12}"  

	forv r=1/`=rowsof(`output')'{
		if!(`r'==1 & word("`llist'",1)=="." ) & ! (word("`llist'",`r')=="." & word("`llist'",`r'+1)==".") ///
		& !(`r'==rowsof(`output') & word("`llist'",`r')=="." ){
			di as text  %12s  abbrev(subinstr(word("`llist'",`r'),".","",.),12) as text _col(14) "{c |} "  _c
			if(`output'[`r',1]!=.z) {
				di as result %9.4g `output'[`r',1] "  "  _c
			}
			if(`output'[`r',2]!=.z) {
				if(`output'[`r',6]==1){
					di as result %12.5g `output'[`r',2] " {c |} "  _c
				}
				else{
					di as result _skip(6) "(" %4.1f `output'[`r',2]	") {c |} "  _c
				}
			}
			else{
				di as result _col(40) as text "{c |} "  _c
			}
			if(`output'[`r',3]!=.z) {
				di as result %9.4g `output'[`r',3] "  "  _c
			}

			
			if(`output'[`r',4]!=.z) {
				if(`output'[`r',6]==1){
					di as result %12.5g `output'[`r',4] " {c |} "  _c
				}
				else{
					di as result _skip(6) "(" %4.1f `output'[`r',4]	") {c |} "  _c
				}
			}
			else{
				di as text _col(66)   "{c |}"  _c
			}
			
			if(`output'[`r',5]!=.z) {
				di as result %10.5f `output'[`r',5] 
			}
			else{
				di "" 
			}
		}
	}
	di as text "{hline 13}{c BT}{hline 25}{c BT}{hline 25}{c BT}{hline 12}"  

end program	





