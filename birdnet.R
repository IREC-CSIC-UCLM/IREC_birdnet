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

# Switches (to split run, 0 = off, 1 = on)
#-------------------------------------------------------------------------------
switch1 = 1 # prepro and running birdnet
switch2 = 1 # postpro 
  
# VARS section (MANDATORY)
#-------------------------------------------------------------------------------
# SPECIFY ABSOLUTE PATHS!
datadir = "/media/sergiolp/TOSHIBA EXT/GRABACIONES/Puerto del Toro/Irec 14 - PU AUDIO 4/Data2" # Define the data directory with .wav files
resultsdir = "/home/sergiolp/Desktop/results_test" # Don't create the folder, it will be created by birdnet!
postprocessing_script = "/home/sergiolp/Work/IREC/progs/d1.31/birdnetIREC/processOutputs.R" #path to the postpro script

# Other vars used by birdnet and postprocess script, info: https://github.com/kahst/BirdNET-Analyzer/tree/main/docs
lat= 38.99416
lon= -3.92475
site= "Puerto del Toro"
min_conf = 0.1
threads = 4
rtype = "csv"
locale = "es"

##########
#process
#########

if (switch1 = 1) {
  
  # List all .wav files in the working directory
  files <- list.files(datadir, pattern = "\\.wav$", full.names = TRUE)
  
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
        
        # Build the Docker run command
        docker_command <- sprintf("docker run -v '%s:/input' -v '%s:/output' birdnet analyze.py --i '/input/%s' --o '/output/%s.csv' --min_conf %s --threads %d --rtype %s --locale %s --lat '%s' --lon '%s' --week '%s'", datadir, resultsdir, filename, sub("\\.wav$", "", filename), min_conf, threads, rtype, locale, lat, lon, week_num)
        
        # Execute the Docker command
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

if (switch2 = 1) {
  
  postprocessing_command <- sprintf("Rscript %s '%s' '%s' '%s' '%s'", postprocessing_script, site, resultsdir, lat, lon)
  system(postprocessing_command, wait = TRUE)
  
}

