# Project: IREC_birdnet
#
# Author: shevelp (github), sergio.lopez@uclm.es)
#
# 1) preprocess audio file and run birdnet
# 2) postprocessing outputs
#
# Considerations
# 1) When specify paths you need to use the ABSOLUTE paths!
# 2) You need to have docker and the birdNET docker image pre-installed
# 3) You need to specify all vars that appear on VARS specification section!
# 4) The processing works for files with this format: # FORMAT: ID_Date_Hour.wav, example: (IREC-14_20230330_072002.wav)
# 5) Switches are used to split the prog run (0 = off, 1 = on) in processing and postprocessing
# 6) You need the following R libraries dependencies

# Rlibraries dependencies!
# library(data.table)
# library(purrr)
# library(dplyr)
# library(lubridate)
# library(hms) 
################################################################################

# Switches (to split run, 0 = off, 1 = on)
#-------------------------------------------------------------------------------
switch1 = 1 # prepro and running birdnet
switch2 = 1 # postpro 


# VARS section (MANDATORY)
#-------------------------------------------------------------------------------
# SPECIFY ABSOLUTE PATHS!
datadir = "/media/sergiolp/TOSHIBA EXT/GRABACIONES/Alcornocosas/IREC 2/Data2/" # Define the data directory with .wav files
resultsdir = "/home/sergiolp/Desktop/results_test" # Don't create the folder, it will be created by birdnet!
postprocessing_script = "/home/sergiolp/Work/IREC/progs/d1.31/IREC_birdnet/processOutputs.R" #path to the postpro script
outputSite = "/home/sergiolp/Desktop/" #path for the final .csv by site

# Other vars used by birdnet and postprocess script, info: https://github.com/kahst/BirdNET-Analyzer/tree/main/docs
lat= 38.99416 
lon= -3.92475
site= "Puerto del Toro"
min_conf = 0.01
threads = 4
rtype = "csv"
locale = "es"
audio_format = ".wav" #.mp4/.mp3/.wav

# Identify OS
os_name <- Sys.info()["sysname"]; print(os_name)

##########
#process
#########

if (switch1 == 1) {
  
  # List all .wav files in the working directory
  files <- list.files(datadir, pattern = audio_format, full.names = TRUE)
  files <- files[1:2]

  # Process each file
  # FORMAT: ID_Date_Hour.wav, example: (IREC-14_20230330_072002.wav)
  for (file in files) {
    if (file.exists(file)) {
      filename <- basename(file)
      cat("Processing file:", filename, "\n")
      
      # Extract the date from the file name
      parts <- strsplit(filename, "_")[[1]]
      date_str <- parts[2]
      
      # Format the date
      year <- substr(date_str, 1, 4)
      month <- substr(date_str, 5, 6)
      day <- substr(date_str, 7, 8)
      
      # Construct the date in yyyy-mm-dd format
      formatted_date <- paste(year, month, day, sep = "-")
      
      # Check if the date is valid and get the week number
      if (tryCatch(as.Date(formatted_date), error = function(e) FALSE)) {
        week_num <- format(as.Date(formatted_date), "%V")
        
        # If Windows
        if (os_name == "Windows") {
          docker_command <- sprintf(
            "docker run -v \"%s:/input\" -v \"%s:/output\" birdnet:latest analyze.py --i \"/input/%s\" --o \"/output/%s.csv\" --min_conf %s --threads %d --rtype %s --locale %s --lat \"%s\" --lon \"%s\" --week \"%s\"",
            datadir, resultsdir, filename, sub(audio_format, "", filename), min_conf, threads, rtype, locale, lat, lon, week_num
          )
        } else {
          # If Linux/Mac
          docker_command <- sprintf("docker run -v '%s:/input' -v '%s:/output' birdnet analyze.py --i '/input/%s' --o '/output/%s.csv' --min_conf %s --threads %d --rtype %s --locale %s --lat '%s' --lon '%s' --week '%s'", datadir, resultsdir, filename, sub(audio_format, "", filename), min_conf, threads, rtype, locale, lat, lon, week_num)
        }
        
        # Run docker command
        system(docker_command, wait = TRUE)
        
        cat("File", filename, "analyzed with BirdNet using Docker\n")
      } else {
        cat("Invalid date in file name:", filename, "\n")
      }
    } else {
      cat("File not found:", file, "\n")
    }
  }
  
}


###########
# postpro
###########

if (switch2 == 1) {
  
  if (os_name == "Windows") {
    # Quoting Win routes
    postprocessing_script_win <- shQuote(postprocessing_script)
    resultsdir_win <- shQuote(resultsdir)
    outputSite_win <- shQuote(outputSite)

    # Postpro Windows
    postprocessing_command <- sprintf("Rscript %s %s %s %s %s %s", postprocessing_script_win, shQuote(site), resultsdir_win, shQuote(lat), shQuote(lon), outputSite_win)
  } else {
    # Postpro Unix/Linux/MacOS

    postprocessing_command <- sprintf("Rscript %s '%s' '%s' '%s' '%s' '%s'", postprocessing_script, site, resultsdir, lat, lon, outputSite)
  }
  
  system(postprocessing_command, wait = TRUE)
  
}

