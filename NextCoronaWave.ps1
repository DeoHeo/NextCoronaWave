#requires -Version 3.0
<#

    .SYNOPSIS
    This local check helps to know the next Corona Wave is starting.

    .DESCRIPTION
    The local check Next Corona Wave can use for all countys in Germany to see the new cases in 7 days
    per 100,000 inhabitants. When the value is growing up 50, than start the state restrictions.

    .EXAMPLE
    .\NextCoronaWave.ps1
    0 Corona_Warn_App count=;40;50;;  OK -  neue Fälle in den letzten 7 Tage pro 100.000 Einwohner im  
    in.\\nWenn der Schwellwert von 50 überstiegen ist wird es neue Restriktionen geben.
  
    .NOTES
    Author: Deo_Heo
    Last Updated: 13.08.2020
    Version: 0.1 Initial Version
             1.0 Einmonatigen Test
             2.0 Erweiterung Angrenzende Landkreise

    Requires:
    PowerShell

#> 

#Informationen Bundesland
#https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/ef4b445a53c1406892257fe63129a8ea_0?geometry=-28.413%2C46.270%2C44.668%2C55.886

#OBJECTID choose under the following web page for the appropriate county:
#https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/917fc37a709542548cc3be077a786c17_0?geometry=-26.087%2C46.269%2C46.994%2C55.886
$objectid = 357
$objectid2 = 360
$objectid3 = 358
$objectid4 = 361
#set the warn value
$warn = 40
#set the crit value(should be left at 50)
$crit = 50
#set it the service name(it must be a word)
$servicename = "Corona_Warn_App"
#choice the number format, default is english
$ger = $False

$choice = 0
$crashed =''

Function GetContent {
    param(
    $objectid
    )
    #get json content
    try{
    #API
    $site = Invoke-WebRequest "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=%27$objectid%27&outFields=OBJECTID,BL,county,cases7_per_100k&returnGeometry=false&f=json" -UseBasicParsing
    $site2 = Invoke-WebRequest "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=%27$objectid2%27&outFields=OBJECTID,BL,county,cases7_per_100k&returnGeometry=false&f=json" -UseBasicParsing
    $site3 = Invoke-WebRequest "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=%27$objectid3%27&outFields=OBJECTID,BL,county,cases7_per_100k&returnGeometry=false&f=json" -UseBasicParsing
    $site4 = Invoke-WebRequest "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=%27$objectid4%27&outFields=OBJECTID,BL,county,cases7_per_100k&returnGeometry=false&f=json" -UseBasicParsing
    IF ($site.StatusDescription -eq "OK"){
        $objoutput = New-Object -TypeName PSObject -Property @{
            value = $site.Content | ConvertFrom-Json
            value2 = $site2.Content | ConvertFrom-Json
            value3 = $site3.Content | ConvertFrom-Json
            value4 = $site4.Content | ConvertFrom-Json
            status = $true
            }
        }
    ELSE{
        $objoutput = New-Object -TypeName PSObject -Property @{
            value = $site.StatusDescription
            status = $false
            }
        }
    }
    catch{
        $objoutput = New-Object -TypeName PSObject -Property @{
            value = $_
            status = $false
            }

        }
return $objoutput
}


$objoutput = GetContent -objectid $objectid


If ($objoutput.status){
    #attribute call convert in one variable, that it need for use in the SWITCH Output
    $lankreis = $objoutput.value.features.attributes.county -replace ' ','_'
    $lankreis2 = $objoutput.value2.features.attributes.county -replace ' ','_' -replace 'ß','ss'
    $lankreis3 = $objoutput.value3.features.attributes.county -replace ' ','_'
    $lankreis4 = $objoutput.value4.features.attributes.county -replace ' ','_' -replace 'ä','ae'
    $bundesland = $objoutput.value.features.attributes.BL
    $var = $objoutput.value.features.attributes.cases7_per_100k
    $var2 = $objoutput.value2.features.attributes.cases7_per_100k
    $var3 = $objoutput.value3.features.attributes.cases7_per_100k
    $var4 = $objoutput.value4.features.attributes.cases7_per_100k

    IF ($ger){
        #convert the value cases7_per_100k in the germany format
        $varcount = $var -replace ',','.'
        $varcount2 = $var2 -replace ',','.'
        $varcount3 = $var3 -replace ',','.'
        $varcount4 = $var4 -replace ',','.'
        $var = „{0:N2}“ –f $var
        $var2 = „{0:N2}“ –f $var2
        $var3 = „{0:N2}“ –f $var3
        $var4 = „{0:N2}“ –f $var4
        }
    ELSE{
        #convert the value cases7_per_100k in the english format
        $varcount = $var -replace ',','.'
        $varcount2 = $var2 -replace ',','.'
        $varcount3 = $var3 -replace ',','.'
        $varcount4 = $var4 -replace ',','.'
        $var = „{0:N2}“ –f $var -replace ',','.'
        $var2 = „{0:N2}“ –f $var2 -replace ',','.'
        $var3 = „{0:N2}“ –f $var3 -replace ',','.'
        $var4 = „{0:N2}“ –f $var4 -replace ',','.'

        }

    #choice the state
    IF ($var -ge $warn -or $var2 -ge $warn -or $var3 -ge $warn -or $var4 -ge $warn){
        $choice = 1
        }
    IF ($var -ge $crit -or $var2 -ge $crit -or $var3 -ge $crit -or $var4 -ge $crit){
        $choice = 2
        }
    ELSE{
        $choice = 0
        }
    }
ELSE{
    $choice = 3
    $crashed = $objoutput.value
    }



SWITCH ($choice){
    0 {"0 $servicename $lankreis=$varcount;$warn;$crit;;|Angrenzender_$lankreis2=$varcount2;$warn;$crit;;|Angrenzender_$lankreis3=$varcount3;$warn;$crit;;|Angrenzender_$lankreis4=$varcount4;$warn;$crit;;  OK - $var neue Faelle in den letzten 7 Tagen pro 100.000 Einwohner im $lankreis. Wenn der Schwellwert $crit uebersteigt, gibt es neue Restriktionen vom Bundesland $bundesland."}            
    1 {"1 $servicename $lankreis=$varcount;$warn;$crit;;|Angrenzender_$lankreis2=$varcount2;$warn;$crit;;|Angrenzender_$lankreis3=$varcount3;$warn;$crit;;|Angrenzender_$lankreis4=$varcount4;$warn;$crit;;  WARN - $var neue Faelle in den letzten 7 Tagen pro 100.000 Einwohner im $lankreis oder in einem angrenzenden Landkreis. Wenn der Schwellwert $crit uebersteigt, gibt es neue Restriktionen vom Bundesland $bundesland."}            
    2 {"2 $servicename $lankreis=$varcount;$warn;$crit;;|Angrenzender_$lankreis2=$varcount2;$warn;$crit;;|Angrenzender_$lankreis3=$varcount3;$warn;$crit;;|Angrenzender_$lankreis4=$varcount4;$warn;$crit;;  CRIT - $var neue Faelle in den letzten 7 Tagen pro 100.000 Einwohner im $lankreis oder in einem angrenzenden Landkreis. Es wird neue Restriktionen vom Bundesland $bundesland geben."}
    3 {"3 $servicename - UNKNOWN - Der Check hat Probleme genauere Details siehe Long output.\n$crashed"}      
}
