## Regional Fish Landings Webscrape

## Load Libraries & Create Functions ----

source('packages.R')

library(Rcrawler)
library(rvest)
library(tidyverse)
library(zoo)
library(httr)
library(lubridate)

# Function to Rename Variables

str_to_var <- function(x) {
  str_replace_all(x , '([a-z])([A-Z])' , '\\1 \\2') %>% 
    str_to_lower(x) %>% str_trim('both') %>% 
    str_replace_all('[:punct:]' , ' ') %>% 
    str_replace_all('\\s' , '_')
}

# Function to create summary meta-data

fun1 <- function(x){
  cls <- class(df[,x])[1] ; lvl <- levels(df[,x]) 
  if (!is_empty(lvl)) paste0('\t\t' , x , '.' , names(df)[x] , ': <' , cls , '> ' , paste(lvl , collapse = ', ' ) , '\n') else 
    paste0('\t\t' , x , '.' , names(df)[x] , ': <' , cls , '>\n')
}

## Get Links for Webscrape ----

x <- LinkExtractor('http://www.nfl.dfo-mpo.gc.ca/NL/Landings-Values' , 
                   urlregexfilter = '20\\d{2}')

links <- data.frame(link = x$InternalLinks) %>% 
  mutate(year = str_extract(link , '\\d{4}') , 
         year = as.integer(year)) %>% 
  filter(str_detect(link , 'report')) %>% 
  arrange(link , desc(year))

## Scrape Data ----

tf <- data.frame()
meta <- data.frame()

for (i in 1:nrow(links)) {
  
  # Get HTML of Page
  url <- read_html(links$link[i])
  
  # Get Table of Landings
  landings <- html_nodes(url , "table") 
  
  # Get Meta Data for Page, Including Year, Run Date, and Last Data Update
  meta_data <- html_nodes(url , 'p') %>% html_text() %>% 
    as_tibble() %>% rename(x = 1) %>% 
    mutate(value = str_extract_all(x , '(?<=:\\s).+$') , 
           x = str_remove_all(x , ':\\s.+$') , 
           x = str_to_var(x)) %>% 
    filter(!str_detect(value , 'character')) %>% 
    pivot_wider(names_from = x) %>% 
    mutate(meta_id = str_pad(string = paste0(i) , pad =  '0' , width = 4 , side = 'left'))
  
  # Get Table Headings
  family <- html_nodes(url , 'strong')  %>% 
    html_text() %>% as_tibble() %>% 
    rename(x = 1) %>% 
    filter(str_detect(x , 'Total')) %>% 
    mutate(x = str_remove_all(x , '\\sTotal')) 
  
  # Bind Page Meta Data with full Meta Data
  meta <- bind_rows(meta , meta_data)
  
  # Parse and Clean Table(s) of Landings
  for (k in 1:length(landings)) {
    x <- landings[[k]] %>% html_table(fill = T) %>% 
      mutate_at(-1 , str_remove_all , '\\,|\\$') %>% 
      mutate_at(-1 , as.double) %>% 
      rename_all(str_to_var) %>% 
      mutate(species_id = str_extract_all(species , '^\\d+') %>% 
               as.integer() , 
             species = str_remove_all(species , '^d\\+')) %>% 
      filter(!is.na(species_id)) %>% 
      mutate(species = str_remove_all(species , as.character(species_id)) , 
             year = links$year[i] , 
             family = family$x[k] , 
             meta_id = meta_data$meta_id[1]) %>% 
      select(year, family , species_id , everything())
    
    # Bind Page Landings with full Landings
    tf <- bind_rows(tf , x)
  }
  
  if (i %% 5 == 0) cat(paste('Link' , i , 'of' , nrow(links) , 'Complete\n'))
}

# Clean and Reformat Data
df <- tf %>% left_join(meta) %>% 
  rename_all(str_replace_all , 'wtrount' , 'wt_round') %>% 
  mutate(vessel_length = if_else(str_detect(vessel_length_category , 'All') , NA_character_ , 
                                 str_extract(vessel_length_category , '(?<=\\().+(?=\\))' )) , 
         shore_type = if_else(str_detect(vessel_length_category , 'All') , NA_character_ , 
                              str_extract(vessel_length_category , '^.+(?=:)')) , 
         run_date = mdy(run_date) , last_data_update = mdy_hm(last_data_update) , 
         family = str_remove_all(family , '\\n')) %>% 
  mutate_at(vars(names(meta)[!str_detect(names(meta) , 'date')]) , as.character) %>% 
  mutate_at(vars(c(family , species , landing_year , vessel_length , vessel_length_category , 
                   shore_type)) , as_factor)

## Save Data ----

# Create Data folder if it doesn't exist
if(!file.exists('data')) dir.create('data') 

# Save Data Frame as CSV in new folder
write_csv(df , 'data\\data.csv')

## Write Metadata ---- 

# Get DFO Notes for surveys
x <- read_html(links$link[1]) %>% html_nodes('ol') %>% html_text() %>% .[[2]] %>% str_remove_all('\\t|\\n')

# Write Metadata/Description 
# NOTE: May want to go back in and manually write column descriptions 
# NOTE: May also want to go back and re-format with HTML
metadata <- c(
  'Abe Solberg' , 
  'FISH 6002: Final Data Project' , '' , 
  paste('Data Scraped on:' , Sys.Date()) , '' , 
  'Background:' , 
  'This project is for the FISH 6002 Final Project.' , 
  'The data were scraped from the Canadian Department of Fisheries & Oceans (DFO) Regional Statistics: Landings and Landed Values.' , 
  'Data are yearly totals of Fisheries Landings, as reported by the DFO.' , 
  'ALL Data should be considered preliminary and subject to revision' , '' ,
  'Data Sources Include: DMP (Dockside Monitoring Program), Hails, Logs, and Purchase Slips' , 
  paste('Dataset includes landings from' , min(df$year) , 'to' , max(df$year) , 'for' , n_distinct(df$species_id) , 'Species.') , 
  paste('Landings data from the following fisheries:' , paste(unique(df$shore_type[!is.na(df$shore_type)]) , collapse = ', ')) , '' ,
  paste(nrow(df) , 'Observations,' , ncol(df) , 'Variables') , '' ,
  'Variables:\n' , 
  unlist(mapply(fun1 , 1:ncol(df) , SIMPLIFY = T)) , 
  'NOTES FROM DFO:' , 
  str_replace_all(x , '(\\.|\\b)(\\d)' , '\\1\n\t \\2')
)

# Save Metadata ----

fileConn <- file('README.md')
writeLines(metadata , fileConn)
close(fileConn)

## Clean Work Space ----

rm(list = setdiff(ls() , 'df'))




