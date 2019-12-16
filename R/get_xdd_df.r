#' @param files a vector of files to be imported. 

get_xdd_df <- function(files){
  df <- data.frame()

  ## loop over all the filenames
for(i in 1:length(files)){

  # define  the filename for indexing
    fn <- files[i]
  
  # import the json.txt as a json list
    if(exists("json")) rm(json)
    if(exists("json.df")) rm(json.df)
    json.list <- rjson::fromJSON(file = fn) #each list primary element is a single article/publication/product.
     
  # the following line (do.call bind_rows) creates a new row for each entry in json$highlight. this means that there will be redundant records in the json.df. 
    ## the alternative to this is either to cat all the highlights into a single character string, and then convert to a data frame _or_ to remove the highlights completely.
      # alternative #1: keep one row per highlight per record    
           # json.df <- do.call("bind_rows", lapply(json, as.data.frame)) # this method creates a single row for each highlight
      #alternative #2: remove highlight entirely
           # json.df <- do.call("bind_rows", lapply(json, as.data.frame)) %>% dplyr::select(-highlight) %>% distinct() # this method creates a single row for each highlight
      # alternative 3: combine all the highlights into a single string. this is cumbersome so i will go ahead and avoid it....
      
    
    # for each product in the json.list, we need to collapse the "hihglights' column into a single character string, so we can obtain a single row for each product inside the resulting dataframe
    n_prods <- length(json.list)
    
    for(j in 1:n_prods){ # for each product, we want to create a single row for the highlights. we should result in n_prods %>% length() elements.
         if(j==1) highlights<-NULL
         highlights[j] <- paste(json.list[[j]]$highlight, collapse = '; ') 
         }   
    
    # edit the hihglight columns in the list elemnts
    json.list[[i]]$highlight <- NULL # erase the multi-elemtn vector to replace later.
    json.list[[i]]$highlight <- highlights
    # create a data frame out of the list...
    json.df <- do.call("bind_rows", lapply(json.list[[i]], as.data.frame))
           
  # append the associated filename into a new column
    json.df$filename <- fn
    
  # append the associated search phrase into a new column
    ind <- str_remove(fn, paste0(getwd(),"/xdd_json/"))
    ind <- str_remove(ind , ".txt")
    json.df$searchterm <- ind
    
  # bind the rows of the previous and the current json df  
    df <- rbind(df, json.df) # the returned object
    
    
      } # end loop over files (i loop)

  rm(json.list); rm(json.df)
# extract the 4-year date from 
df$coveryear <- str_extract(df$coverDate, '[0-9][0-9][0-9][0-9]') %>% as.integer()

return(df)

} # end function
