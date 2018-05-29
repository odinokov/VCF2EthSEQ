##  The R script for bulk VCF files preprocessing (all fields removal except for GT via bcftools) 
##  and ethnicity analysis (via EthSEQ).

rm(list = ls())

# install.packages('EthSEQ')
# source('http://bioconductor.org/biocLite.R')
# biocLite('gdsfmt')
# biocLite('SNPRelate')

library(EthSEQ)

data.dir <- file.path(normalizePath(tempdir(), winslash = "/"),'EthSEQ_Data/')
out.dir <- file.path(normalizePath(tempdir(), winslash = "/"),'EthSEQ_Analysis/')

## Copy genotype data in VCF format
dir.create(data.dir, showWarnings = FALSE)
dir.create(out.dir, showWarnings = FALSE)

# identify the folders and file to be copied
# from.folder <- 'D:/Dropbox/Veritas Files/'
from.folder <- '/mnt/d/Dropbox/Veritas Files/'

# get the files list
setwd(from.folder)
file.names <- list.files(pattern = "\\.vcf$")

for(i in 1:length(file.names)){
  
  target.filename <- file.names[i]

  fullpath <- list.files(from.folder, target.filename, full.names = TRUE)

  # copy the files to the new folder
  file.copy(fullpath, data.dir)
  target.file <- file.path(data.dir, target.filename)
  output.file <- file.path(data.dir, paste('output_', target.filename, sep=''))
  
  # remove all fields except for GT

  x <- paste('bcftools annotate -x INFO,^FORMAT/GT ', target.file, ' -o ', output.file, sep='')
  system(x)

  ## Perform ethnicity analysis using pre-computed reference model
  ethseq.Analysis(
    target.vcf =  output.file,
    out.dir = out.dir,
    model.available = "SS2.Major",
    model.folder = data.dir,
    verbose=TRUE,
    composite.model.call.rate = 1,
    space = "3D") # Default space is 2D

}

## Delete analysis folder
unlink(data.dir,recursive=TRUE)
unlink(out.dir,recursive=TRUE)
