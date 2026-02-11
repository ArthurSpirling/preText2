# Run this script to copy the UK_Manifestos data from the original preText package.
# You need to have the original package's .tar.gz downloaded first.
#
# Option 1: If you can install the archived version temporarily:
#   install.packages("https://cran.r-project.org/src/contrib/Archive/preText/preText_0.6.2.tar.gz",
#                    repos = NULL, type = "source")
#   data("UK_Manifestos", package = "preText")
#   save(UK_Manifestos, file = "data/UK_Manifestos.rda")
#
# Option 2: Download and extract manually:
#   download.file("https://cran.r-project.org/src/contrib/Archive/preText/preText_0.6.2.tar.gz",
#                 "preText_0.6.2.tar.gz")
#   untar("preText_0.6.2.tar.gz")
#   file.copy("preText/data/UK_Manifestos.RData", "data/UK_Manifestos.rda")
