# NextCoronaWave

is a Local Check for Check MK with monitoring the count of new cases with Corona. 

## Installation

https://checkmk.de/cms_localchecks.html

##  Usage

The check is only to use in Germany for one "Landkreis". The example "Landkreis" is "Dresden", please change this to your choice.

Choose under the following web page the objectid for the appropriate county:
https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/917fc37a709542548cc3be077a786c17_0?geometry=-26.087%2C46.269%2C46.994%2C55.886

Attention: When the "Landkreise" have umlauts or special characters, than have to work with the function Replace.

Example: Line 95 $lankreis2 = $objoutput.value2.features.attributes.county -replace ' ','_' -replace 'ß','ss'

Attention: When you need more or less adjoining "Landkreise", than manuell erase or add the lines. In future it give a variable mechanism.

Example: $objectid2 = 360
         $site2 = Invoke-WebRequest "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=%27$objectid2%27&outFields=OBJECTID,BL,county,cases7_per_100k&returnGeometry=false&f=json" -UseBasicParsing
         $lankreis2 = $objoutput.value2.features.attributes.county -replace ' ','_' -replace 'ß','ss'
         $varcount2 = $var2 -replace ',','.'
		 $var2 = „{0:N2}“ –f $var2
		 ...


## Preview

The next step is to create a variable configuration for the adjoining "Landkreisen".

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

see license file
