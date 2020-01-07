# setup ------------------------------------------------------------------

## load wosr package for pulling from WOS
library(wosr) # https://cran.r-project.org/web/packages/wosr/wosr.pdf
library(tidyverse)
## read in your person WOS keys
key <- read_csv("R/keys.csv") %>% 
  filter(api=="clarivate")

# Save your WoS API username and password in environment variables
Sys.setenv(WOS_USERNAME = key$username,
           WOS_PASSWORD = key$key
             )

# Get session ID
sid <- wosr::auth()

key <- wosr::auth(username = NULL,
           password = NULL)

# define terms and queries -------------------------------------------------------------
TS <- c("bbs", "nabbs", "breeding bird survey", "north american breeding bird survey")
queries <- paste0("TS = ", TS[1], 
                  "(", 
                  , 
                  ")"
                  )


# pull from wos -----------------------------------------------------------
wosr::pull_wos(queries, sid = )
