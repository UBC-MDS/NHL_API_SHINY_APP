# NHL API APP README

## Data for App

Please note that this app downloads the data directly from the official NHL API. Due to this, there is no raw folder as the data is downloaded and rendered when initializing the app. 

## App Description

Welcome to the NHL API App. This app is built to help fantasy hockey players dive into and compare stats between selected players in the league. When using the app, you can select 2 players in the NHL with the dropdown menu created. What this app does is allows you to compare the player performance for the first player with the player performance of the second player. This is a handy tool when preparing for your fantasy drafts to be better informed before drafting and picking players. Currently this app is capable of analyzing total goals, assists and points scored over the last 5 years. 

## Installation instructions

Simply open the app.R file in the src folder using R Studio, and click the run app button on the top right to run the app. If you have any issues with missing libraries or packages, on the R Studio console run the code 'install.packages("renv")'. This will make sure that renv is installed on your R studio. After the installation is complete, input in the console 'renv::restore()'. This will import the renv file that is in the src folder. After this all necessary libraries should be installed on your machine and you should be able to access the app. At this stage clicking the run app button on the top right of R Studio should open the app for you. 

## Video Walkthrough

NHL_API_SHINY_APP/img/demo.mp4
