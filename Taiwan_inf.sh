#!/usr/bin/env -S bash -e
# GMT modern mode bash template
# Date:    2024-07-14T10:52:26
# User:    suphakornpoobua
# Purpose: Make an interferogram of Taiwan during Hualien earthquake 

# set variables

range="119.505/122.375/23.78/25.5"
proj="M12c" 
wet="153/204/255"

gmt makecpt -Cgray -T-11000/9000/500 -Z > topo.cpt
gmt grdgradient ~/Desktop/Taiwan/topo/dem.grd -Nt1 -A45 -Gtopo_i.grd -V

# for unwrapped only 
gmt grdmath ~/Desktop/Taiwan/merge/unwrap_mask_ll.grd 0.0554658 MUL 79.58 MUL = ~/Desktop/Taiwan/merge/unwrap_mask_ll_mm.grd
gmt makecpt -Cjet -T-100/300/10 -Ww > los_unwrapcos_disp.cpt
gmt begin unw-taiwan png

	gmt basemap -J$proj -R$range -Ba1f0.5 -BWeSn+t"Mw 7.4 Hualien Earthquake"
	gmt grdimage ~/Desktop/Taiwan/topo/dem.grd -R$range -J$proj -Ctopo.cpt -Itopo_i.grd
	gmt coast -Na/1p,black,-.- -Slightblue -Df
	gmt grdimage ~/Desktop/Taiwan/merge/unwrap_mask_ll_mm.grd -J$proj -R$range -Q -C/Users/suphakornpoobua/Desktop/Taiwan/los_unwrapcos_disp.cpt
	gmt psscale -D0.5/1.0+w1.0i/0.1+h+jBL -C/Users/suphakornpoobua/Desktop/Taiwan/los_unwrapcos_disp.cpt -Ba+l"Unwrapped LOS (mm): + subsidence"

	# from https://www.globalcmt.org/CMTsearch.html
	gmt meca archive-mw6up-Taiwan-eq.dat -Sd0.15c+f0p -Gred -Ewhite 
	gmt meca Hualien-beachball.dat -Sd0.2c+f0p 

	# from https://github.com/cossatot/gem-global-active-faults
	gmt plot gem_active_faults.gmt -W0.5p,red

	echo 121.6044 24.015 Hualien > city.dat
	echo 121.5654 25.065 Taipei >> city.dat

	echo 119.75 25.27 Reference: 2024-03-03  | gmt text -F+f5p,Helvetica-Bold
	echo 119.72 25.22 Repeat: 2024-04-08 | gmt text -F+f5p,Helvetica-Bold
	echo 119.835 25.17 Perpendicular Baseline = 84 m | gmt text -F+f5p,Helvetica-Bold

	echo 121.6070 23.9870 | gmt plot -Si0.1c -W1p,black -Gblack
	echo 121.5680 25.0367 | gmt plot -Si0.1c -W1p,black -Gblack 
 
	gmt text city.dat -F+f5p,Helvetica-Bold
	echo 121.80 23.88 Mw7.4 Hualien | gmt text -F+f5p,Helvetica-Bold
	# flip the sign to match the real ascending LOS direction of the satellite
	echo 121.610217 24.199035 0.656015 0.120382 0 0 0.0001 Look | gmt psvelo -R$range -J$proj -A10p+e+a20 -Se1.0/0.95/8 -Gblack -W1p,black,solid 


gmt end show
