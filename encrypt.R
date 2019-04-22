# Seteaza calea =========================================================================================================

path <- "D:/ANA_MARIA/demografie/test/"

# =======================================================================================================================

library(foreign) # manipulare dbf
library(digest)  # criptare
library(lubridate)

files <- list.files()
pos <- grep(pattern = "dem_cnp_criptat_", x = files)
files <- files[pos]
min <- 1000000
index <- -1
for (i in 1:length(files)) {
  date_time <- gsub(pattern = "dem_cnp_criptat_", replacement = "", x = files[i])
  time <- strsplit(date_time, split = "_")[[1]][2]
  time <- gsub(pattern = "-", replacement = ":", x = time)
  sec <- period_to_seconds(hms(time))
  systime <- period_to_seconds(hms(format(Sys.time(), "%H:%M:%S")))
  dif <- systime-sec
  if (dif < min) {
    min <- dif
    index <- i
  }
}



new_path <- paste0(path, files[index])
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
      year <- c(year, NA)
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

substr_errors <- function (cnp, start, stop) {
  col <- c()
  cnp <- as.character(cnp)
  for (i in 1:length(cnp)) {
    if (is.na(cnp[i]) | cnp[i] == 0 | nchar(cnp[i]) != 13) {
      col <- c(col, NA)
      next
    }
    col <- c(col, substr(cnp[i], start = start, stop = stop))
  }
  col <- as.integer(col)
  return (col)
}


# SEXCRP, ANCRP, LUNACRP, ZICRP
add_columns <- function (df) {
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
    if (length(cnp_colname) > 1) { # daca exista mai multe coloane cnp
      F_M <- substr(i, nchar(i)-1, nchar(i))
      sexcrp <- paste0("SEXCRP", F_M)
      ancrp <- paste0("ANCRP", F_M)
      lunacrp <- paste0("LUNACRP", F_M)
      zicrp <- paste0("ZICRP", F_M)
    }
    df[,sexcrp] <- substr_errors(df[,i], start = 1, stop = 1)
    df[,ancrp] <- year2to4(df[,i])
    df[,lunacrp] <- substr_errors(df[,i], start = 4, stop = 5)
    df[,zicrp] <- substr_errors(df[,i], start = 6, stop = 7)
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


encrypt2x <- function (df) {
  column_names <- names(df)
  colnamlow <- tolower(column_names)
  isu <- grep("isu", colnamlow)
  if (length(isu) == 0) return (df) 
  isu_colname <- column_names[isu] 
  index <- 1
  for (i in isu_colname) {
    df[,i] <- as.character(df[,i])
    pos_sex <- grep(pattern = "sexcrp", x = colnamlow)[index]
    pos_an <- grep(pattern = "ancrp", x = colnamlow)[index]
    pos_luna <- grep(pattern = "lunacrp", x = colnamlow)[index]
    pos_zi <- grep(pattern = "zicrp", x = colnamlow)[index]
    n <- nrow(df)
    for (j in 1:n) {
      df[j,pos_sex] <- ifelse(is.na(df[j,pos_sex]) & nchar(df[j,i]==13), substr_errors(df[j,i], start = 1, stop = 1), df[j,pos_sex])
      df[j,pos_an] <- ifelse(is.na(df[j,pos_an]) & nchar(df[j,i]==13), year2to4(df[j,i]), df[j,pos_an])
      df[j,pos_luna] <- ifelse(is.na(df[j,pos_luna]) & nchar(df[j,i]==13), substr_errors(df[j,i], start = 4, stop = 5), df[j,pos_luna])
      df[j,pos_zi] <- ifelse(is.na(df[j,pos_zi]) & nchar(df[j,i]==13), substr_errors(df[j,i], start = 6, stop = 7), df[j,pos_zi])
    }
    df[,i] <- unlist(lapply(df[,i], digest_if))
    index <- index + 1
  }
  return (df)
}


encrypt <- function (df) {
  df <- clean(df)
  if (nrow(df) == 0) return (df) 
  column_names <- names(df)
  crp <- grep(pattern = "isu", x = tolower(column_names))
  if (length(crp) > 0) {
    df <- encrypt2x(df)
    return (df)
  }
  df <- add_columns(df)
  column_names <- names(df)
  cnp <- grep("cnp", tolower(column_names))
  if (length(cnp) == 0) return (df) 
  cnp_colname <- column_names[cnp] 
  for (i in cnp_colname) {
    colname <- gsub(pattern = "CNP", replacement = "ISU", x = i, ignore.case = TRUE)
    df[,i] <- unlist(lapply(df[,i], digest_if))
    colnames(df)[which(names(df) == i)] <- colname
  }
  return (df)
}


write_encrypt <- function (path, files) {
  dbf <- grep(".dbf", files)
  files <- files[dbf]
  dbf_list <- lapply(files, function(x) suppressMessages(read.dbf(file=x, as.is = TRUE)))
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


