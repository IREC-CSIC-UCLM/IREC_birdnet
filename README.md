# IREC_birdnet
Repo for bird-sound automatic classification using birdnet &amp; postprocessing/formating tools (R) 

## Dependences

To run this scripts properly on your local machine you will need to install the dockerized birdNET model. 

So, first, if you don't have installed docker proceed to do is following this instructions: 
https://docs.docker.com/get-docker/

Once you have docker installed you will need to build the image that contains the birdNET model following this steps:

1) Clone the BirdNET repository (https://github.com/kahst/BirdNET-Analyzer/tree/main?tab=readme-ov-file#usage-docker)
2) Cd to the downloaded directory and build the image running this command 

```
docker build -t birdnet .
```

3) Clone this repository or download the Rscripts birdnet.R & processOutputs.R

## Run

To run the scripts you will need to change paths on the VARS section of the birdnet.R script.

Here you can find the explanation of birdNET variables: https://github.com/kahst/BirdNET-Analyzer/tree/main?tab=readme-ov-file#usage-cli

Don't forget to read and check the scripts!

## LICENSE

MIT LICENSE 

## Issues 

Don't hesitate on adding any comment/issue report using the GitHub issues section:

https://github.com/IREC-CSIC-UCLM/IREC_birdnet/issues 

