#' @param files a vector of files to be imported. 

get_xdd_df <- function(files){
  
df <- NULL

  ## loop over all the filenames
for(i in 1:length(files)){

  # define  the filename for indexing
    fn <- files[i]
  # remove old files if exist
    if(exists("json")) rm(json)
    if(exists("json.df")) rm(json.df)
  # import the json.txt as a json list
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
         json.list[[j]]$highlight <- NULL # erase the highlights in the list element. we will append the new highlights later..
         
         ## fix missing author names (otherwise it fails when forcing to data frame...annoying!)
         if(is.null(json.list[[j]]$authors)) json.list[[j]]$authors <- NA
         
         # force list element to a data frame
         json.list[[j]] <- as.data.frame(json.list[[j]]) 
         # print(j)
         }   
    
   
    # turn list into a data frame...
    json.df <- do.call("bind_rows", lapply(json.list, as.data.frame))
    
    
  ## MUNGE THE NEW DATA FRAME ## 
    # add the hihglight vector as a column in th enew data frame
      json.df$highlight <- highlights
    # append the associated filename into a new column
      json.df$filename <- fn
    # append the associated search phrase into a new column
      ind <- str_remove(fn, paste0(getwd(),"/xdd_json/"))
      ind <- str_remove(ind , ".txt")
      json.df$searchterm <- ind
    # collect the 4-digital years...
      json.df$coveryear <- str_extract(json.df$coverDate, '[0-9][0-9][0-9][0-9]') %>% as.integer()
    
    
  # add this data frame to a list of dfs..inelegant, yes.
      df <-bind_rows(json.df, df) # the returned object
      rm(json.df)  
  } # end loop over files (i loop)


# one last munge of the data frame for easing plotting efforts

df <-df %>% 
   ## force searchterm, pubname and publishers to factors
    mutate(
      searchterm=as.factor(as.character(searchterm)),
      pubname=as.factor(as.character(pubname)),
      publisher=as.factor(as.character(publisher))
    )

return(df)

} # end function
