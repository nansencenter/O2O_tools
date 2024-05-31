import numpy as np
from netCDF4 import Dataset
from datetime import datetime

# Define the WOA grid (example: 1-degree resolution grid)
latitudes = np.arange(-89.5, 89.5, 1.0)
longitudes = np.arange(-179.5, 179.5, 1.0)

# Create a new NetCDF file
ncfile = Dataset('target_grid_woa.nc', 'w', format='NETCDF4_CLASSIC')

# Create the latitude and longitude dimensions
lat_dim = ncfile.createDimension('lat', len(latitudes))
lon_dim = ncfile.createDimension('lon', len(longitudes))

# Create coordinate variables for latitudes and longitudes
latitudes_var = ncfile.createVariable('lat', np.float32, ('lat',))
longitudes_var = ncfile.createVariable('lon', np.float32, ('lon',))

# Assign units attributes to coordinate variables
latitudes_var.units = 'degrees_north'
longitudes_var.units = 'degrees_east'

# Write data to coordinate variables
latitudes_var[:] = latitudes
longitudes_var[:] = longitudes

# Add global attributes
ncfile.description = 'Target grid for regridding, based on World Ocean Atlas grid coordinates'
ncfile.history = 'Created ' + datetime.now().strftime("%Y-%m-%d %H:%M:%S")
ncfile.source = 'Generated using Python with netCDF4 and numpy'

# Close the NetCDF file
ncfile.close()

print('target_grid_woa.nc created successfully')
