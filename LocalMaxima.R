library(terra)
library(lidR) 
library(sf)
chm = rast("C:\\Users\\Oren\\Nardi_workspace\\Tech\\OFO\\StemMaps\\Data\\703_Triton\\FinalData\\CHM\\TritonCHM.tif") 

chm[chm < 0] = -0.1 # Set to 0 if less than 0; to remove artifacts from chm creation

#resample coarser
chm_coarse = project(chm, y = "epsg:26910", res = 0.25) # resample to meters based coordinate system; 0.25 meters for spatial resolution

# apply sliding window mean smooth
smooth_size = 7 # make a 7 by 7 moving window; values are equal, (7 pixels) new value of every raster pixel; takes the mean of nearby pixels
weights = matrix(1,nrow = smooth_size, ncol = smooth_size) #equal weighting, every pixel has equal weighting (whole window has equal weight)
chm_smooth = focal(chm_coarse, weights, fun = mean) # focal function performs the smoothing 

# define variable window function
lin = function(x){
  win = x*0.11 + 0
  win[win < 0.5] = 0.5
  win[win > 100] = 100
  return(win)
}



# # Need to get the full raster loaded into memory before the locate_trees step
# writeRaster(chm_smooth, file.path(data_dir, "temp/chm.tif"), overwrite = TRUE)
# chm_smooth = raster::raster(file.path(data_dir, "temp/chm.tif"))
# chm_smooth = chm_smooth * 1

treetops = locate_trees(chm_smooth, lmf(ws = lin, shape = "circular", hmin = 5))
gc()

st_write(treetops,"C:\\Users\\Oren\\Nardi_workspace\\Tech\\OFO\\StemMaps\\Data\\703_Triton\\FinalData\\Vector\\triton_detected_treetops.gpkg")

