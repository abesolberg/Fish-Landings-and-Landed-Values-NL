## Packages.R

## Install Required Packages for Data Collection/Extraction 


packages <- c("tidyverse", "Rcrawler", "rvest", "zoo", "httr" , "jsonlite" , "lubridate") 

new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

rm(packages , new.packages)