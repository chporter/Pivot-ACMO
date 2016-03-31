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

# This routine takes crop model outputs (ACMO format) and creates single variable csv files.
#  - Each output file represents a single variable and a single ACMO file.
#  - The table contains 30 columns representing the years 1980-2009 and
#    N rows, one row per farm.
#  - File names are "Variable name"-"ACMO name".csv
# Created: March 30, 2016
# Last edited: 
# Author: Cheryl Porter, cporter@ufl.edu

#---- REQUIRED LIBRARIES -------------------------------------------#
#PRIOR TO USING THIS ROUTINE, THE R PACKAGE "reshape2" MUST BE INSTALLED!

library(reshape2)

#---- DEFINE VARIABLES OF INTEREST HERE ----------------------------#
# The user can cahnge the variable(s) of interest by listing them here. 
#  - Any subset of ACMO variables may be listed. 
#  - A separate file will be created for each variable-ACMO file combination.

varnames <- c('HWAH_S','CWAH_S')

#---- Start Routine ------------------------------------------------#

# Definitions
years <-c(1980:2009) # Assume 30 years (1980-2009) for all simulations

# List all files in the current directory
files <- list.files(path=".", full.names=FALSE, recursive=FALSE)

# loop thru all files in the current directory
for(f in 1:length(files)) {
  acmo_name <- files[f]

  # look for filenames that start with "ACMO-"
  if (strtrim(acmo_name,5) == "ACMO-") {
    
    # This is for ACMO files that have a header above column names
    farmdata <- read.csv(file=acmo_name,skip = 2, head=TRUE,sep=",")
    EXNAME_long <- farmdata$EXNAME
    number_of_farms <- length(EXNAME_long)
    exname <- vector(mode="character", length = number_of_farms)
    
    #get rid of the double-underscore and everything after it in the exname
    for (i in 1:number_of_farms) {
      exname[i] <- unlist(strsplit(as.character(EXNAME_long[i]),split='__',fixed=TRUE))[1]
    }

    #write a new pivot table for each combination of variable of interest + acmo file.
    for (v in 1:length(varnames)) {
      #create a dataframe with only exname, years (1980-2009) and the variable of interest (one at a time)
      farmdata2 <- data.frame(exname, years, farmdata[varnames[v]])
  
      #pivot table - requires library reshape2
      #takes farmdata2, farmname is rows, years is columns, values are the varible of interest
      farmdata3 <- dcast(farmdata2, exname ~ years, value.var = varnames[v])
      
      #file name is concatenation of variable name and acmo file name
      outfile <- paste(varnames[v],acmo_name,sep="-")
    
      #write the file
      write.csv(farmdata3, file=outfile, row.names=FALSE)
    }
  }
}
