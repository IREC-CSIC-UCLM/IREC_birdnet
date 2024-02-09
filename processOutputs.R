# Project: IREC_birdnet
#
# Author: shevelp (github), sergio.lopez@uclm.es)
# Post processing script
# R dependences:
# library(data.table)
# library(purrr)
# library(dplyr)
# library(lubridate)
# library(hms) 
################################################################################

# Rlibraries
library(data.table)
library(purrr)
library(dplyr)
library(lubridate)
library(hms) 


# Lista de archivos .csv #args: 1) nombre, 2) path, 3) lat, 4) lon 5)path to store the final .csv
args <- commandArgs(trailingOnly = TRUE)
site <- args[1]
path_csvs <- args[2]
lat_arg <- args[3]
long_arg <- args[4]
output_finalcsv <- args[5] #"/home/sergiolp/Desktop/"

output_files <- list.files(path_csvs, pattern = "\\.csv$", full.names = TRUE)

# Revisar que los archivos fueron encontrados
print(output_files)

# Función principal
read_and_augment <- function(file_path, site, lat, long) {
  filename <- basename(file_path)
  components <- strsplit(filename, "_")[[1]]
  id <- sub("\\..*", "", components[1])
  date <- components[2]
  time <- gsub("\\..*", "", components[3])
  filename <- paste0(id, "_", date, "_", time, ".wav")

  # Lectura del archivo
  data <- read.csv(file_path)

  if(nrow(data) == 0){
    data <- data.frame(Start..s. = NA, End..s. = NA, Scientific.name = NA, 
                       Common.name = NA, Confidence = NA, ID = id, Fecha = date, Hora = time, 
                       Audio.file = filename, Site = site, lat = NA, lon = NA)
  } else {
    data <- data %>%
      mutate(ID = id, Fecha = date, Hora = time, Audio.file = filename, Site = site, lat = as.numeric(lat), lon = as.numeric(long))
  }
  
  return(data)
}

# Procesamiento
all_csv <- lapply(output_files, read_and_augment, site = site, lat = lat_arg, long = long_arg)

# Combinar los datos
merged <- do.call(rbind, all_csv)

# Más transformaciones si es necesario
output <- merged %>%
  mutate(
    Fecha = as.Date(Fecha, format="%Y%m%d"),
    Hora = hms::hms(
      hours = as.numeric(substr(Hora, 1, 2)), 
      minutes = as.numeric(substr(Hora, 3, 4)), 
      seconds = as.numeric(substr(Hora, 5, 6))
    )
  )


# Guardar el archivo de salida
output_file_name <- paste0(output_finalcsv, site, "_", unique(output$ID), ".csv")
write.csv(output, output_file_name, row.names = FALSE)

# Imprimir la ruta del archivo guardado
print(paste("Archivo guardado en:", output_file_name))
