####################################################################################################
###----------------------------------------------------------------------------------------------###
#                     \    ||   /
#      AA             \    ||   /  MMM    MMM  IIII  PPPPP
#     AAAA            \\   ||   /   MMM  MMM    II   P  PPP
#    AA  AA    ggggg  \\\\ ||  //   M  MM  M    II   PPPPP
#   AAAAAAAA  gg  gg     \\ ////    M      M    II   P
#  AA      AA  ggggg  \\   //      MM      MM  IIII  PPP
#                  g  \\\\     //    
#              gggg      \\ ////     The Agricultural Model Intercomparison and Improvement Project
#                          //
###----------------------------------------------------------------------------------------------###
####################################################################################################
###----------------------------------------------------------------------------------------------###

### AgMIP Regional Integrated Assessments: Pivot-ACMO ##

# This routine takes crop model outputs (ACMO format) and pivots the specified variable to create a table with farms as rows and 30 years of output as columns.
# Created: March 30, 2016
# Last edited: 
# Author: Cheryl Porter, cporter@ufl.edu
# Co-authors: Sonali McDermid
# Routines are not gauranteed, and any help questions should be directed to the authors

# It is suggested that the User read carefully through this routine, and specifically note those lines that contain, or are preceeded by the word "CHANGE" in uppercase. These are areas that the User will need to change the inputs. The program is constructed to minimize the number of changes that the User makes, and can be modified by the User for her/his needs. These "CHANGE" statements can usually be found at the top of each section. 

#Prior to using this routine, the user must Install Package "reshape2" MUST BE INSTALLED FIRST!

library(reshape2)
#----------------------DEFINE VARIABLES OF INTEREST HERE-------------------------#

varnames <- c('HWAH_S','CWAH_S')

#----------------------Start Routine-------------------------#

# Definitions
years <-c(1980:2009) # Assume 30 years (1980-2009) for all simulations

# List all ACMO files
files <- list.files(path=".", full.names=FALSE, recursive=FALSE)

for(f in 1:length(files)) {
  acmo_name <- files[f]
  if (strtrim(acmo_name,5) == "ACMO-") {
    
    farmdata <- read.csv(file=acmo_name,skip = 2, head=TRUE,sep=",") # This is for ACMO files that have a header above column names
    EXNAME_long <- farmdata$EXNAME
    number_of_farms <- length(EXNAME_long)
    exname <- vector(mode="character", length = number_of_farms)
    
    #get rid of the double-underscore and everything after it in the exname
    for (i in 1:number_of_farms) {
      exname[i] <- unlist(strsplit(as.character(EXNAME_long[i]),split='__',fixed=TRUE))[1]
    }

    #write a new pivot table for each combination of variable of interest plus acmo file.
    for (v in 1:length(varnames)) {
      #create a dataframe with only exname, years (1980-2009) and the variable of interest (one at a time)
      farmdata2 <- data.frame(exname, years, farmdata[varnames[v]])
  
      #pivot table - requires library dplyr
      #takes farmdata2, farmname is rows, years is columns, values are the varible of interest
      farmdata3 <- dcast(farmdata2, exname ~ years, value.var = varnames[v])
      
      #file name is concatenation of variable name and acmo file name
      outfile <- paste(varnames[v],acmo_name,sep="-")
    
      #write the file
      write.csv(farmdata3, file=outfile, row.names=FALSE)
    }
  }
}
