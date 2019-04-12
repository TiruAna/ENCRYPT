library(foreign) # manipulare dbf
library(digest)  # criptare

# setez calea new pentru ca aici fac modificarile
new_path <- "D:/ANA_MARIA/demografie/testare_citire_R/new"
setwd(new_path)

# parcurg toate folderele din folderul new
# citesc toate fisierele dbf din subfolderele folderului new
folders <- dir()
for (i in folders) {
  path <- paste0(getwd(),"/", i)
  setwd(path)
  files <- list.files()
  write_encrypt(path, files)
  setwd(new_path)
  path <- c()
}

write_encrypt <- function (path, files) {
  dbf <- grep(".dbf", files)
  files <- files[dbf]
  dbf_list <- lapply(files, function(x) read.dbf(file=x))
  # transformare in data frame
  for (i in seq(dbf_list)) assign(files[i], dbf_list[[i]])
  # functie de cryptare + functie de curatare pentru fiecare dbf
  
  # scriere din dataframe in dbf
  for (i in files) write.dbf(dataframe = get(files[i]), file = paste0(path, "/", files[i]))
}


encrypt <- function (df) {
  column_names <- names(df)
  pos <- grep("x", tolower(column_names))
  if (length(pos) > 0) df <- df[,-pos] # elimina coloane adaugate in plus
  column_names <- names(df)
  
  cnp <- grep("cnp", tolower(column_names))
  return (df)
}



#testare =================
setwd("D:/ANA_MARIA/demografie/testare_citire_R/new/dem_3B01")

files <- list.files()
dbf <- grep(".dbf", files)
files <- files[dbf]

a = lapply(files, function(x) read.dbf(file=x)) # citire toate fisierele dbf

# citirea datelor: probleme! adauga 8 campuri in plus goale
x1 <- read.dbf("cs_3B01.dbf")
x2 <- read.dbf("dc_3B01.dbf")
x3 <- read.dbf("dv_3B01.dbf")
x4 <- read.dbf("nm_3B01.dbf")
x5 <- read.dbf("nv_3B01.dbf")

# verifica tipurile de date
datetype <- c()
for (i in 1:ncol(x)) {
  datetype <- c(datetype, class(x[,i]))
}

# verifica daca exista x in numele de coloane (8)
length(grep("x", tolower(names(x1))))
length(grep("x", tolower(names(x2))))
length(grep("x", tolower(names(x3))))
length(grep("x", tolower(names(x4))))
length(grep("x", tolower(names(x5))))
# rezultat: mai sunt si alte coloane ce contin x

# warning
tt <- tryCatch(read.dbf("cs_3B01.dbf"),error=function(e) e, warning=function(w) w)
if(is(tt,"warning")) print("KOOKOO")

name <- c(" an ",	"luna",	"nrbul",	"judet_i",	"sector_i",
          "loca_i",	"mediu_i",	"data_i",	"nract_i",	"cnp_m",
          "cnp_f",	"datan_m",	"vcasa_m",	"vcasl_m",	"vcasz_m",
          "datan_f",	"vcasa_f",	"vcasl_f",	"vcasz_f",	"stciv_m",
          "stciv_f",	"nrcas_m",	"nrcas_f",	"activ_m",	"activ_f",	"scoala_m",
          "scoala_f",	"cet_m",	"cet_f",	"nat_m",	"nat_f",	"r", "", "")
mn <- make.names(name, unique = TRUE)
# scrierea datelor: probleme! 
write.dbf(x, "x.dbf")


# criptarea
c1 <- toupper(digest("1740714411519", algo = "sha1", serialize=FALSE))
identical(c1, "F9B2247F88352BCAFFAF66C91295B824C5FA6C76")