#Project: Get Weather API call
#Date: March 09, 2021

#A get weather function
Function Get-Weather {
    #advanced functions
    [CmdletBinding()]

     #Cretae a paramter to use citystate, days, and temperature
     param (
         [Parameter (Position=0, Mandatory = $true, HelpMessage="Enter City and State (example: Seattle,WA)", ValueFromPipeline=$true)] 
         $CityAndstate,
         [Parameter (Position=1, Mandatory = $true, HelpMessage="Enter Number of days (1-3)", ValueFromPipeline=$true)]
         $Days,
         [Parameter (Position=2, Mandatory = $true, HelpMessage="Enter celsius (C) or Fahrenheit (F)", ValueFromPipeline=$true)]
         $TemperatureUnit
     )
    
     #Array of location and Days
     $userInputArray = @($CityAndstate,$Days)

     #Foreach loop to validate null or empty of location and Days
     foreach($userInput in $userInputArray)
     {
            if([string]::IsNullOrEmpty($userInput))
            {
                Write-Output("Please enter City/State or Days and try again", $_.Exception.Message) 
                exit
            }
     }

    #Catches webrequest failure and other issues within the try bracket.
    try{        
        #URI for weatherapi
        $Uri = "http://api.weatherapi.com/v1/forecast.json?key=59396ffe92ab460580d235411211802&q=$cityAndstate&days=$days"
        $weatherResult = Invoke-WebRequest -Uri $Uri
       
        #LOG Save the JSON response into current working directory  > weatherJSONFormat.txt file
        $weatherResult | Add-Content -Path .\weatherJSONFormat.txt

        #Convert Json to PS Object
        $WeatherObject = $weatherResult.Content | ConvertFrom-Json
     
        #Calcuting the number of days
        $daysLength = $WeatherObject.forecast.forecastday.Length

        #Creating new Object with number of days return
        $weatherNewObject = New-Object -TypeName 'Object[]' -ArgumentList $daysLength

        #Forloop to display the necessary details for each days
        for($i = 0; $i -lt $daysLength; $i++){
            #variable to store chance of rain, condition, maxwind
            $chanceofRain = $WeatherObject.forecast.forecastday.day.daily_chance_of_rain[$i]
            $weatherCondition = $WeatherObject.forecast.forecastday.day.condition.text[$i]
            $maxWind = $WeatherObject.forecast.forecastday.day.maxwind_mph[$i]

            #For null or empty temperature unit return both C and F
            if([string]::IsNullOrEmpty($temperatureUnit)){
                #Variable for Celsius
                $temperatureUnitC = 'c'
                $maxTempC = "maxtemp_$temperatureUnitC"
                $minTempC = "mintemp_$temperatureUnitC"
                $avgTempC = "avgtemp_$temperatureUnitC"

                #variable to store maximum temperature, min temp, avg temp
                $maxTempCValue = $WeatherObject.forecast.forecastday.day.$maxTempC[$i]
                $minTempCValue = $WeatherObject.forecast.forecastday.day.$minTempC[$i]
                $avgTempCValue = $WeatherObject.forecast.forecastday.day.$avgTempC[$i]
                
                #Variable for Fahrenheit
                $temperatureUnitF = 'f'
                $maxTempF = "maxtemp_$temperatureUnitF"
                $minTempF = "mintemp_$temperatureUnitF"
                $avgTempF = "avgtemp_$temperatureUnitF"

                #variable to store maximum temperature, min temp, avg temp
                $maxTempFValue = $WeatherObject.forecast.forecastday.day.$maxTempF[$i]
                $minTempFValue = $WeatherObject.forecast.forecastday.day.$minTempF[$i]
                $avgTempFValue = $WeatherObject.forecast.forecastday.day.$avgTempF[$i]

                # Adding each object into newly created object
                $weatherNewObject[$i] = [pscustomobject]@{
                    "Date" = $WeatherObject.forecast.forecastday.date[$i];
                    "Max Temperature $temperatureUnitC" = $maxTempCValue.ToString();
                    "Min Temperature $temperatureUnitC" = $minTempCValue.ToString();
                    "Avg Temperature $temperatureUnitC" = $avgTempCValue.ToString();
                    "Max Temperature $temperatureUnitF" = $maxTempFValue.ToString();
                    "Min Temperature $temperatureUnitF" = $minTempFValue.ToString();
                    "Avg Temperature $temperatureUnitF" = $avgTempFValue.ToString();
                    "Max Wind Mph" = $maxWind.ToString();
                    "Chance of rain %" = $chanceofRain.ToString();
                    "Weather Condition" = $weatherCondition.ToString()
                }
            } else {
                #user input temperature unit and creating a variable to match with the response temperature unit      
                $maxTemp = "maxtemp_$temperatureUnit"
                $minTemp = "mintemp_$temperatureUnit"
                $avgTemp = "avgtemp_$temperatureUnit"

                #variable to store maximum temperature, min temp, avg temp
                $maxTempValue = $WeatherObject.forecast.forecastday.day.$maxTemp[$i]
                $minTempValue = $WeatherObject.forecast.forecastday.day.$minTemp[$i]
                $avgTempValue = $WeatherObject.forecast.forecastday.day.$avgTemp[$i]

                # Adding each object into newly created object
                $weatherNewObject[$i] = [pscustomobject]@{
                    "Date" = $WeatherObject.forecast.forecastday.date[$i];
                    "Max Temperature $temperatureUnit" = $maxTempValue.ToString();
                    "Min Temperature $temperatureUnit" = $minTempValue.ToString();
                    "Avg Temperature $temperatureUnit" = $avgTempValue.ToString();
                    "Max Wind Mph" = $maxWind.ToString();
                    "Chance of rain %" = $chanceofRain.ToString();
                    "Weather Condition" = $weatherCondition.ToString()
                 }
            }
        }
        #return object
        return $weatherNewObject
    } catch {
        #Catch any exception from try and display in message form 
        Write-Output("Failed", $_.Exception.Message) | Out-GridView
    }
}

#Get-Weather | Format-Table
#Get-Weather | Format-List
#Get-Weather | Out-GridView