# purescript-google-places
Helper functions for the Google Places API

Has a single main function: Network.HTTP.Google.Places.Autocomplete.query. Takes a record of options, check the Google documentation at https://developers.google.com/places/web-service/autocomplete for what every field means. The QueryResult type is not complete yet, if you need fields that are not supported yet, PR's are welcome.

Uses the Affjax library to do the HTTP call, so if you want to use this in NodeJS, make sure you have xhr2 installed (see Affjax documentation).
