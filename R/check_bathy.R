# Internal helper used to sort bathy matrices by increasing longitude and
# latitude. It is intentionally not exported.
check_bathy = function(x){
	order(as.numeric(colnames(x))) -> xc
	order(as.numeric(rownames(x))) -> xr
	x[xr, xc, drop = FALSE] -> sorted.x
	return(sorted.x)
}
