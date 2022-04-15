## What are these codes?
This is the offical implementation of the published paper. Please cite this work:  
>D. Kodaira, K. Tsukazaki, T. Kure, and J. Kondoh, "[Improving Forecast Reliability for Geographically Distributed Photovoltaic Generations, ](https://www.preprints.org/manuscript/202110.0037/v1)" Energies, vol. 14, no. 21, p. 7340, Nov. 2021.

### Abstract
In this study, a two-step probabilistic forecast scheme is proposed for geographically distributed PV generation forecasting. Each step of the proposed scheme adopts ensemble forecasting based on three different machine-learning methods. When individual PV generation is forecasted, the proposed scheme utilizes surrounding PVs' past data to train the ensemble forecasting model. 

## Required packages
Matlab 2019

## About the author
- [Daisuke Kodaira](https://scholar.google.com/citations?user=dK5dNcoAAAAJ&hl=en), daisuke.kodaira03 AT gmail.com

## Structure of the code
![image](https://user-images.githubusercontent.com/43132698/138842220-19095542-8cda-46dd-bcde-6ba9538686f0.png)  
The proposed model is composed of two part; Singple PV foreacst model and Multiple PV foreacst model as shown above. Codes for the Single PV foreacaset model is **Forecast_BasedOnSiglePVData**.Codes for the Multiple PV foreacaset model is **Forecast_BasedOnMultiplePVData**. These codes work indivudually. The Single PV foreacst generate csv files which contains forecasted results. These csv files are utilized for Multiple OV foreacst model.  

## How to run
### 1. Singole PV foreacaset model
Run from "main.m".  

### 2. Multiple PV foreacaset model
Run from "main.m".  



