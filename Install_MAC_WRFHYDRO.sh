#!/usr/bin/env bash

## WRF Hydro installation with parallel process.
# Download and install required library and data files for WRF.
# Tested in macOS Catalina 10.15.7
# Tested in 32-bit
# Tested with current available libraries on 05/11/2022
# If newer libraries exist edit script paths for changes
#Estimated Run Time ~ 90 - 150 Minutes with 10mb/s downloadspeed.
#Special thanks to  Youtube's meteoadriatic and GitHub user jamal919

#############################basic package managment############################


brew install gcc libtool automake autoconf make m4 java ksh git wget mpich grads ksh tcsh python@3.9

##############################Directory Listing############################

export HOME=`cd;pwd`
mkdir $HOME/WRF-Hydro
export DIR=$HOME/WRF-Hydro/Libs
cd $HOME/WRF-Hydro
mkdir Downloads
mkdir WRFPLUS
mkdir $HOME/WRF-Hydro/Hydro-Basecode
mkdir WRFDA
mkdir Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH


##############################Downloading Libraries############################

cd Downloads
wget -c https://github.com/madler/zlib/archive/refs/tags/v1.2.12.tar.gz
wget -c https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_12_2.tar.gz
wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz
wget -c https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip




#############################Compilers############################


export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran

#############################zlib############################
#Uncalling compilers due to comfigure issue with zlib1.2.12
#With CC & CXX definied ./configure uses different compiler Flags

cd $HOME/WRF-Hydro/Downloads
tar -xvzf v1.2.12.tar.gz
cd zlib-1.2.12/
CC= CXX= ./configure --prefix=$DIR/grib2
make
make install
make check

#############################libpng############################
cd $HOME/WRF-Hydro/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-1.6.37.tar.gz
cd libpng-1.6.37/
./configure --prefix=$DIR/grib2
make
make install
make check

#############################JasPer############################

cd $HOME/WRF-Hydro/Downloads
unzip jasper-1.900.1.zip
cd jasper-1.900.1/
autoreconf -i
./configure --prefix=$DIR/grib2
make
make install
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include


#############################hdf5 library for netcdf4 functionality############################

cd $HOME/WRF-Hydro/Downloads
tar -xvzf hdf5-1_12_2.tar.gz
cd hdf5-hdf5-1_12_2
./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran
make 
make install
make check

export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH

##############################Install NETCDF C Library############################
cd $HOME/WRF-Hydro/Downloads
tar -xzvf v4.8.1.tar.gz
cd netcdf-c-4.8.1/
export CPPFLAGS=-I$DIR/grib2/include 
export LDFLAGS=-L$DIR/grib2/lib
./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared
make 
make install
make check

export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF

##############################NetCDF fortran library############################

cd $HOME/WRF-Hydro/Downloads
tar -xvzf v4.5.4.tar.gz
cd netcdf-fortran-4.5.4/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS=-I$DIR/NETCDF/include 
export LDFLAGS=-L$DIR/NETCDF/lib
./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared
make install
make check



######################## ARWpost V3.1  ############################
## ARWpost
##Configure #3
###################################################################
cd $HOME/WRF-Hydro/Downloads
wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
tar -xvzf ARWpost_V3.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro/ARWpost
./clean -a
sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' $HOME/WRF-Hydro/ARWpost/src/Makefile
export NETCDF=$DIR/NETCDF
./configure  
sed -i -e 's/-C -P -traditional/-P -traditional/g' $HOME/WRF-Hydro/ARWpost/configure.arwp
./compile


export PATH=$HOME/WRF-Hydro/ARWpost/ARWpost.exe:$PATH



##################### NCAR COMMAND LANGUAGE           ##################
########### NCL compiled via Conda                    ##################
########### This is the preferred method by NCAR      ##################
########### https://www.ncl.ucar.edu/index.shtml      ##################

#Installing Miniconda3 to WRF directory and updating libraries
source $HOME/WRFHYDRO-Coupled-5.2-install-script-macOS/Miniconda3_Install.sh

#Installing NCL via Conda
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda update -n ncl_stable --all -y
conda deactivate 
conda deactivate

##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n wrf-python -c conda-forge wrf-python -y
conda activate wrf-python
conda update -n wrf-python --all -y
conda deactivate
conda deactivate



########################## WRF Hydro GIS PreProcessor ##############################
#  Compiled with Conda
#  https://github.com/NCAR/wrf_hydro_gis_preprocessor
####################################################################################

conda init bash
conda activate base
conda create -n wrfh_gis_env -c conda-forge python=3.6 gdal netCDF4 numpy pyproj whitebox=1.5.0
conda activate wrfh_gis_env
conda update -n wrfh_gis_env --all
conda deactivate
conda deactivate

cd $HOME/WRF-Hydro
git clone https://github.com/NCAR/wrf_hydro_gis_preprocessor.git  $HOME/WRF-Hydro/WRF-Hydro-GIS-PreProcessor

############################# WRF HYDRO V5.2.0 #################################
# Version 5.2.0
# Standalone mode
################################################################################
export NETCDF_INC=$DIR/NETCDF/include
export NETCDF_LIB=$DIR/NETCDF/lib


cd $HOME/WRF-Hydro/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/archive/refs/tags/v5.2.0.tar.gz -O WRFHYDRO.5.2.tar.gz
tar -xvzf WRFHYDRO.5.2.tar.gz -C $HOME/WRF-Hydro/Hydro-Basecode


#Modifying WRF-HYDRO Environment
#Echo commands use due to lack of knowledge
cd $HOME/WRF-Hydro/Hydro-Basecode/wrf_hydro_nwm_public-5.2.0/trunk/NDHMS/template

sed -i 's/SPATIAL_SOIL=0/SPATIAL_SOIL=1/g' setEnvar.sh                      # Spatially distributed parameters for NoahMP: 0=Off, 1=On.
sed -i 's/WRF_HYDRO_NUDGING=0/WRF_HYDRO_NUDGING=1/g' setEnvar.sh                     # Streamflow nudging: 0=Off, 1=On.
echo " " >> setEnvar.sh
echo "# Large netcdf file support: 0=Off, 1=On." >> setEnvar.sh
echo "export WRFIO_NCD_LARGE_FILE_SUPPORT=1" >> setEnvar.sh
cp -r setEnvar.sh $HOME/WRF-Hydro/Hydro-Basecode/wrf_hydro_nwm_public-5.2.0/trunk/NDHMS


############################ WRF 4.4  #################################
## WRF v4.4
## Downloaded from git tagged releases
# option 21, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################

cd $HOME/WRF-Hydro/Downloads
wget -c https://github.com/wrf-model/WRF/releases/download/v4.4/v4.4.tar.gz -O WRF-4.4.tar.gz
tar -xvzf WRF-4.4.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro/WRFV4.4
export WRFIO_NCD_LARGE_FILE_SUPPORT=1


cd $HOME/WRF-Hydro/Downloads
wget -c https://github.com/wrf-model/WRF/releases/download/v4.4/v4.4.tar.gz -O WRF-4.4.tar.gz
tar -xvzf WRF-4.4.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro/WRFV4.4

#Replace old version of WRF-Hydro distributed with WRF with updated WRF-Hydro source code
rm -r $HOME/WRF-Hydro/WRFV4.4/hydro/
cp -r $HOME/WRF-Hydro/Hydro-Basecode/wrf_hydro_nwm_public-5.2.0/trunk/NDHMS $HOME/WRF-Hydro/WRFV4.4/hydro

cd $HOME/WRF-Hydro/WRFV4.4/hydro
source setEnvar.sh
cd $HOME/WRF-Hydro/WRFV4.4


./clean
./configure # option 21, option 1 for gfortran/clang and distributed memory w/basic nesting
./compile em_real

export WRF_DIR=$HOME/WRF-Hydro/WRFV4.4


############################WPSV4.4#####################################
## WPS v4.4
## Downloaded from git tagged releases
#Option 3 for gfortran and distributed memory 
########################################################################

cd $HOME/WRF-Hydro/Downloads
wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v4.4.tar.gz -O WPS-4.4.tar.gz
tar -xvzf WPS-4.4.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro/WPS-4.4
./clean -a
./configure #Option 3 for gfortran and distributed memory 
./compile


############################WRFPLUS 4DVAR###############################
## WRFPLUS v4.4 4DVAR
## Downloaded from git tagged releases
## WRFPLUS is built within the WRF git folder
## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice. 
#Option 12 for gfortran/gcc and distribunted memory 
########################################################################

cd $HOME/WRF-Hydro/Downloads
tar -xvzf WRF-4.4.tar.gz -C $HOME/WRF-Hydro/WRFPLUS
cd $HOME/WRF-Hydro/WRFPLUS/WRF-4.4
mv * $HOME/WRF-Hydro/WRFPLUS
cd $HOME/WRF-Hydro/WRFPLUS
rm -r WRFV4.4/
export NETCDF=$DIR/NETCDF
export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
./configure wrfplus  #Option 12 for gfortran/gcc and distribunted memory 
./compile wrfplus   
export WRFPLUS_DIR=$HOME/WRF-Hydro/WRFPLUS




############################WRFDA 4DVAR###############################
## WRFDA v4.4 4DVAR
## Downloaded from git tagged releases
## WRFDA is built within the WRFPLUS folder
## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice. 
#Option 12 for gfortran/clang and distribunted memory
########################################################################

cd $HOME/WRF-Hydro/Downloads
tar -xvzf WRF-4.4.tar.gz -C $HOME/WRF-Hydro/WRFDA
cd $HOME/WRF-Hydro/WRFDA/WRF-4.4
mv * $HOME/WRF-Hydro/WRFDA
cd $HOME/WRF-Hydro/WRFDA
rm -r WRFV4.4/
export NETCDF=$DIR/NETCDF
export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
export WRFPLUS_DIR=$HOME/WRF-Hydro/WRFPLUS
./configure 4dvar #Option 12 for gfortran/gcc and distribunted memory 
./compile all_wrfvar




############################OBSGRID###############################
## OBSGRID
## Downloaded from git tagged releases
## Option #2
########################################################################
cd $HOME/WRF-Hydro/
git clone https://github.com/wrf-model/OBSGRID.git
cd $HOME/WRF-Hydro/OBSGRID

./clean -a
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate ncl_stable


export HOME=`cd;pwd`
export DIR=$HOME/WRF-Hydro/Libs
export NETCDF=$DIR/NETCDF

./configure   #Option 2

sed -i 's/-C -P -traditional/-P -traditional/g' configure.oa
sed -i 's/-lnetcdf -lnetcdff/ -lnetcdff -lnetcdf/g' configure.oa
sed -i 's/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo/-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo -lfontconfig -lpixman-1 -lfreetype -lhdf5 -lhdf5_hl /g' configure.oa


./compile

conda deactivate
conda deactivate



######################## WPS Domain Setup Tools ########################
## DomainWizard

cd $HOME/WRF-Hydro/Downloads
wget http://esrl.noaa.gov/gsd/wrfportal/domainwizard/WRFDomainWizard.zip
mkdir $HOME/WRF-Hydro/WRFDomainWizard
unzip WRFDomainWizard.zip -d $HOME/WRF-Hydro/WRFDomainWizard
chmod +x $HOME/WRF-Hydro/WRFDomainWizard/run_DomainWizard


######################## WPF Portal Setup Tools ########################
## WRFPortal
cd $HOME/WRF-Hydro/Downloads
wget https://esrl.noaa.gov/gsd/wrfportal/portal/wrf-portal.zip
mkdir $HOME/WRF-Hydro/WRFPortal
unzip wrf-portal.zip -d $HOME/WRF-Hydro/WRFPortal
chmod +x $HOME/WRF-Hydro/WRFPortal/runWRFPortal





######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd $HOME/WRF-Hydro/Downloads
mkdir $HOME/WRF-Hydro/GEOG
mkdir $HOME/WRF-Hydro/GEOG/WPS_GEOG

#Mandatory WRF-Hydro Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C $HOME/WRF-Hydro/GEOG/

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C $HOME/WRF-Hydro/GEOG/
mv $HOME/WRF-Hydro/GEOG/WPS_GEOG_LOW_RES/ $HOME/WRF-Hydro/GEOG/WPS_GEOG


# WPS Geographical Input Data Mandatory for Specific Applications
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c  https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2                                                
tar -xvf topobath_30s.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.gz
tar -xvzf gsl_gwd.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG


#Optional WPS Geographical Input Data 


wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_old_than_2000.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG






##########################  Export PATH and LD_LIBRARY_PATH ################################
cd $HOME

echo "export PATH=$DIR/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH" >> ~/.bashrc




#####################################BASH Script Finished##############################
echo "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model verison 4.4."
echo "Thank you for using this script" 
