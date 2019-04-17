library(foreign) # manipulare dbf
library(digest)  # criptare

# setez calea new pentru ca aici fac modificarile
new_path <- "D:/ANA_MARIA/demografie/testare_citire_R/new"
setwd(new_path)


clean <- function (df) {
  column_names <- names(df)
  pos_new_col <- grep("(^x$|^x.)", tolower(column_names))
  last_col <- as.integer(seq(from=ncol(df)-7, to = ncol(df), by = 1))
  if (identical(pos_new_col, last_col)) df <- df[,-pos_new_col] # elimina coloane adaugate in plus
  return (df)
}

year2to4 <- function (cnp) {
  year <- c()
  for (i in 1:length(cnp)) {
    if (is.na(cnp[i]) | cnp[i] == 0 | nchar(cnp[i]) != 13) {
      year <- c(year, cnp[i])
      next
    }
    first_digit <- as.integer(substr(cnp[i], start = 1, stop = 1))
    if (first_digit == 1 | first_digit == 2) {
      y <- paste0("19", substr(cnp[i], start = 2, stop = 3))
    } else {
      y <- paste0("20", substr(cnp[i], start = 2, stop = 3))
    }
    year <- c(year, y)
  }
  year <- as.integer(year)
  return (year)
}

# SEXCRP, ANCRP, LUNACRP, ZICRP
keep_digits <- function (df) {
  column_names <- names(df)
  cnp <- grep("cnp", tolower(column_names))
  if (length(cnp) == 0) return (df)
  cnp_colname <- column_names[cnp]
  sexcrp <- "SEXCRP"
  ancrp <- "ANCRP"
  lunacrp <- "LUNACRP"
  zicrp <- "ZICRP"
  
  for (i in cnp_colname) {
    df[,i] <- as.character(df[,i])
    if (length(cnp_colname) > 1) {
      F_M <- substr(i, nchar(i)-1, nchar(i))
      sexcrp <- paste0(sexcrp, F_M)
      ancrp <- paste0(ancrp, F_M)
      lunacrp <- paste0(lunacrp, F_M)
      zicrp <- paste0(zicrp, F_M)
    }
    df[,sexcrp] <- as.integer(substr(df[,i], start = 1, stop = 1))
    df[,ancrp] <- year2to4(df[,i])
    df[,lunacrp] <- as.integer(substr(df[,i], start = 4, stop = 5))
    df[,zicrp] <- as.integer(substr(df[,i], start = 6, stop = 7))
  }
  return(df)
}


digest_if <- function (x) {
  if (!is.na(x) && nchar(x) == 13) {
    crypt <- toupper(digest(x, algo = "sha1", serialize=FALSE))
    return (crypt)
  }
  return (x)
}


encrypt <- function (df) {
  df <- clean(df)
  if (nrow(df) == 0) return (df) 
  df <- keep_digits(df)
  column_names <- names(df)
  column_names <- column_names[-grep("dns", tolower(column_names))]
  cnp <- grep("cnp", tolower(column_names))
  cnp_colname <- column_names[cnp] 
  for (i in cnp_colname) {
    df[,i] <- unlist(lapply(df[,i], digest_if))
  }
  return (df)
}


write_encrypt <- function (path, files) {
  dbf <- grep(".dbf", files)
  files <- files[dbf]
  dbf_list <- lapply(files, function(x) read.dbf(file=x))
  for (i in seq(dbf_list)) assign(files[i], dbf_list[[i]]) # transformare in data frame
  for (i in files) assign(i, encrypt(get(i)))  # functie de cryptare + functie de curatare pentru fiecare dbf
  for (i in files) write.dbf(dataframe = get(i), file = paste0(path, "/", i))  # scriere din dataframe in dbf
  return (NULL)
}


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
digest(kd$CNP_F[1:nrow(kd)], algo = "sha1", serialize=FALSE)


lapply(kd$CNP_M, dg)
column_names <- names(x1)
column_names <- column_names[,-grep("dns", tolower(column_names))]
