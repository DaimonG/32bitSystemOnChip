# Create Floorplan (45 nm)

# floorPlan -su <aspectRatio> [<stdCellDensity> [<coreToLeft> <coreToBottom> <coreToRight> <coreToTop>]]
set defOutLefDNR 1
set defOutLefVia 1
set lefDefOutVersion 5.5

exec rm -rf temp
exec mkdir temp
exec rm -rf results
exec mkdir results
exec mkdir results/summary
exec mkdir results/timing
exec mkdir results/verilog

#floorPlan -su 1  0.6 4 4 4 4   
floorplan -d 630 480 5 5 5 5
placeInstance my_Mem 394 300
placeInstance my_aes 120 60

# add halos
#addRoutingHalo -block my_Mem my_aes


editPin -fixedPin 1 -snap TRACK -side Top -unit TRACK -layer 2 -spreadType center -spacing 5.0 \
        -pin {resetn EXT_BUSY EXT_MR EXT_MW {EXT_ADDRBUS[0]} {EXT_ADDRBUS[1]} {EXT_ADDRBUS[2]} {EXT_ADDRBUS[3]} {EXT_ADDRBUS[4]} {EXT_ADDRBUS[5]} {EXT_ADDRBUS[6]} {EXT_ADDRBUS[7]} {EXT_ADDRBUS[8]} {EXT_ADDRBUS[9]} {EXT_ADDRBUS[10]} {EXT_ADDRBUS[11]} {EXT_ADDRBUS[12]} {EXT_ADDRBUS[13]} {EXT_ADDRBUS[14]} {EXT_ADDRBUS[15]} {EXT_ADDRBUS[16]} {EXT_ADDRBUS[17]} {EXT_ADDRBUS[18]} {EXT_ADDRBUS[19]} {EXT_ADDRBUS[20]} {EXT_ADDRBUS[21]} {EXT_ADDRBUS[22]} {EXT_ADDRBUS[23]} {EXT_ADDRBUS[24]} {EXT_ADDRBUS[25]} {EXT_ADDRBUS[26]} {EXT_ADDRBUS[27]} {EXT_ADDRBUS[28]} {EXT_ADDRBUS[29]} {EXT_ADDRBUS[30]} {EXT_ADDRBUS[31]} {EXT_WDATABUS[0]} {EXT_WDATABUS[1]} {EXT_WDATABUS[2]} {EXT_WDATABUS[3]} {EXT_WDATABUS[4]} {EXT_WDATABUS[5]} {EXT_WDATABUS[6]} {EXT_WDATABUS[7]} {EXT_WDATABUS[8]} {EXT_WDATABUS[9]} {EXT_WDATABUS[10]} {EXT_WDATABUS[11]} {EXT_WDATABUS[12]} {EXT_WDATABUS[13]} {EXT_WDATABUS[14]} {EXT_WDATABUS[15]} {EXT_WDATABUS[16]} {EXT_WDATABUS[17]} {EXT_WDATABUS[18]} {EXT_WDATABUS[19]} {EXT_WDATABUS[20]} {EXT_WDATABUS[21]} {EXT_WDATABUS[22]} {EXT_WDATABUS[23]} {EXT_WDATABUS[24]} {EXT_WDATABUS[25]} {EXT_WDATABUS[26]} {EXT_WDATABUS[27]} {EXT_WDATABUS[28]} {EXT_WDATABUS[29]} {EXT_WDATABUS[30]} {EXT_WDATABUS[31]}}
#-use TIELOW is meant to set output pinst to 0. Notice how these pins are all of type output.
editPin -fixedPin 1 -snap TRACK -side Bottom -use TIELOW -unit TRACK -layer 2 -spreadType center -spacing 10.0 \
        -pin {EXT_NREADY {EXT_RDATABUS[0]} {EXT_RDATABUS[1]} {EXT_RDATABUS[2]} {EXT_RDATABUS[3]} {EXT_RDATABUS[4]} {EXT_RDATABUS[5]} {EXT_RDATABUS[6]} {EXT_RDATABUS[7]} {EXT_RDATABUS[8]} {EXT_RDATABUS[9]} {EXT_RDATABUS[10]} {EXT_RDATABUS[11]} {EXT_RDATABUS[12]} {EXT_RDATABUS[13]} {EXT_RDATABUS[14]} {EXT_RDATABUS[15]} {EXT_RDATABUS[16]} {EXT_RDATABUS[17]} {EXT_RDATABUS[18]} {EXT_RDATABUS[19]} {EXT_RDATABUS[20]} {EXT_RDATABUS[21]} {EXT_RDATABUS[22]} {EXT_RDATABUS[23]} {EXT_RDATABUS[24]} {EXT_RDATABUS[25]} {EXT_RDATABUS[26]} {EXT_RDATABUS[27]} {EXT_RDATABUS[28]} {EXT_RDATABUS[29]} {EXT_RDATABUS[30]} {EXT_RDATABUS[31]}}

# Building a Power Ring for Vdd / Vdds, extending top/bottom segments to create pins
# From the LEF file we know that M9 and M10 are the highest metals, and that the min width of the M9 M10 metals
# is 0.8. We need to make this ring a multiple of 0.8.Since the area is small, we dont expect huge consumption,
# we keep it at pitch. 
# Note that in the foorplan we must reserve enough space between core (rows) and pins to build rings 

addRing -nets {VDD VSS} -width 0.6 -spacing 0.5 \
       -layer [list top 7 bottom 7 left 6 right 6]

#hookup the rings with stripes
addStripe -nets {VSS VDD} -layer 6 -direction vertical -width 0.4 -spacing 0.5 -set_to_set_distance 17.5
addStripe -nets {VSS VDD} -layer 7 -direction horizontal -width 0.4 -spacing 0.5 -set_to_set_distance 17.5
sroute -connect { blockPin corePin floatingStripe } -routingEffort allowShortJogs  -nets {VDD VSS}

globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *

globalNetConnect VDD -type net -net VDD -inst *
globalNetConnect VSS -type net -net VSS -inst *

defOut -floorplan -noStdCells results/ensc450_floor.def
saveDesign ./DBS/03-floorplan.enc -relativePath -compress
summaryReport -outfile results/summary/03-floorplan.rpt

