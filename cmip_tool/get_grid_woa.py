import numpy as np
from netCDF4 import Dataset
from datetime import datetime

levs = np.genfromtxt('def_zgrid_woa.txt', delimiter=',')

# Define the WOA grid (example: 1-degree resolution grid)
latitudes = np.arange(-89.5, 90.5, 1.0)
longitudes = np.arange(-179.5, 180.5, 1.0)

# Create a new NetCDF file
ncfile = Dataset('target_grid_woa.nc', 'w', format='NETCDF4_CLASSIC')

# Create the latitude and longitude dimensions
lev_dim = ncfile.createDimension('lev', len(levs))
lat_dim = ncfile.createDimension('lat', len(latitudes))
lon_dim = ncfile.createDimension('lon', len(longitudes))

# Create coordinate variables for latitudes and longitudes
levs_var = ncfile.createVariable('lev', np.float32, ('lev',))
latitudes_var = ncfile.createVariable('lat', np.float32, ('lat',))
longitudes_var = ncfile.createVariable('lon', np.float32, ('lon',))

# Assign units attributes to coordinate variables
levs_var.units = 'meter'
latitudes_var.units = 'degrees_north'
longitudes_var.units = 'degrees_east'

# Write data to coordinate variables
levs_var[:] = levs
latitudes_var[:] = latitudes
longitudes_var[:] = longitudes

# Add global attributes
ncfile.description = 'Target grid for regridding, based on World Ocean Atlas grid coordinates'
ncfile.history = 'Created ' + datetime.now().strftime("%Y-%m-%d %H:%M:%S")
ncfile.source = 'Generated using Python with netCDF4 and numpy'

# Close the NetCDF file
ncfile.close()

print('target_grid_woa.nc created successfully')
