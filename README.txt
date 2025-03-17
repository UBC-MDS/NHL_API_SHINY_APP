NHL API APP README

Welcome to the NHL API App. This app is built to help fantasy hockey players dive into and compare stats between selected players in the league. 

Data for App

Please note that this app downloads the data directly from the official NHL API. Due to this, there is no raw folder as the data is downloaded and rendered when initializing the app. 

To run this app, simply open app.R and render the app. As the data from this app is obtained from the NHL API, all the raw data required to generate the app is downloaded when the app is first initialized. This process is done to optimize the app as we only do one server call and download when initializing the app to make sure we load all the data. Once this step is done all calculations are done on the client side so that no more excessive loading is required. The result is that there may be a slower original initialization time to download and processes the raw data, once this step is done the app should be very fast as there are no calls to the API to download new data. 

How to use the App

Using the app is very straight forward, simply select the player name you wish to learn more about. You can type the name on the dropdown or you can select the name with your mouse. That player's stats should show up on the chart. There are two drop downs available to pick player names. This is done as this dashboard serves as a compare tool to analyze player performance over the last 5 years. Currently the data fields available to view are Points, Goals and Assists over the last 5 years. 

If you have any suggestions to improve on this app, please feel free to leave an issue on the GitHub portal and I will review. 

Thank you and enjoy!