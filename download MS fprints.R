##### SCRIPT TO DOWNLOAD DATASETS FROM MICROSOFT'S GLOBAL ML BUILDING FOOTPRINTS  ---------
## https://github.com/microsoft/GlobalMLBuildingFootprints 

## The script filters by country, download and process datasets to get single
## layer to work with on GIS software.
## Luis de la Rua ## May 2023 --------------------------------------------------

## Links to the datasets is available here
## https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv

# Libraries
library(dplyr)
library(terra)
library(downloader)
library(tidyverse)
library(geojsonR)
library(R.utils)

# Data path
dpath <- "C:/GIS/UNFPA GIS/PopGrid/CRI/layers/Bing bfp/"

# Download table with all links (takes a bit be patient)
link_url <- 'https://minedbuildings.blob.core.windows.net/global-buildings/dataset-links.csv'
links <- read.csv(link_url)

# Filter by country 
country <- 'CostaRica'
links_filt <- subset(links,links$Location == country)

# Convert urls into vector (NOT A LIST OTHERWISE the loop wont work)
# urls <- as.vector(links_filt[['Url']]) # this works too using base R
urls <-as.vector(pull(links_filt,Url)) # dplyr

# Downloading (note that MS stored the files as csv but need to change extension to geojson)
downloaded <- lapply(urls,function(url){
  # extract the last part of the url to make the filename
  destination = unlist(strsplit(url, '/'))
  destination = destination[length(destination)]
  destination = paste0 (dpath, destination)
  # download the file
  download.file(url=url,destfile=destination)
  return(destination)
})

# Extract all files 
fn <- list.files(path=dpath,pattern = "*.csv.gz",full.names = T) # file names to loop over
lapply(fn,function(i){
  gunzip(i,remove=T,overwrite=T) 
})

# And change extension into .geojson

oldNames <- list.files(dpath,pattern = "*.csv",full.names = T)

file.rename(oldNames,paste0(oldNames,".geojson"))

# Merge and save as gpkg
#open all the geojson files
fn <- list.files(path=dpath,pattern = "*.geojson",full.names = T)
data <- vect(lapply(fn,vect))

# Export into GPKG format  
writeVector(data,paste0(dpath,"MS_BFP.gpkg"),overwrite=T)  

length(fn)
