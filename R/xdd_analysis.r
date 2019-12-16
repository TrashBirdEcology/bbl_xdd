# Import and munge the records returned via script at 'bbs_xdd.ipynb'

# Setup -------------------------------------------------------------------
library(tidyverse)
library(jsonlite)
library(rjson)


# Import the JSON files and munge into a single data frame ----------------
files <- list.files("xdd_json", pattern='.txt', full.names=TRUE)

## loop over all the filenames
for(i in seq_along(files)){
  # create empty df if first file loop
  if(i) bbs_xdd <- data.frame()
  fn <- files[i]
  
  # import the json.txt as a json list
  json <- rjson::fromJSON(file = fn)
  
  # the following line (do.call bind_rows) creates a new row for each entry in json$highlight. this means that there will be redundant records in the json.df. 
    ## the alternative to this is either to cat all the highlights into a single character string, and then convert to a data frame _or_ to remove the highlights completely.
      # alternative #1: keep one row per highlight per record    
      json.df <- do.call("bind_rows", lapply(json, as.data.frame)) # this method creates a single row for each highlight
      #alternative #2: remove highlight entirely
      # json.df <- do.call("bind_rows", lapply(json, as.data.frame)) %>% dplyr::select(-highlight) %>% distinct() # this method creates a single row for each highlight
      #alternative 3: combine all the highlights into a single string. this is cumbersome so i will go ahead and avoid it....

      # append the associated filename into a new column
      json.df$filename <- fn
      # append the associated search phrase into a new column
      json.df$searchterm <- str_remove(fn, "xdd_json/")
      json.df$searchterm <- str_remove(json.df$searchterm , ".txt")
      
      
      # bind the rows of the previous and the current json df  
      bbs_xdd <- bind_rows(bbs_xdd, json.df) # the returned object
        
}

# extract the 4-year date from 
bbs_xdd$coveryear <- str_extract(bbs_xdd$coverDate, '[0-9][0-9][0-9][0-9]') %>% as.integer()

# Add index for the readme.rmd to ignore the sourcing
donotsource=TRUE
