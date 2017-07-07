module BusPrediction.Http exposing (get)

import Model exposing (..)
import BusPrediction exposing (..)
import Http


apiKey =
    "AjxKPBBTD0GvOT0DgnE7yw"


get : String -> Cmd Msg
get stopId =
    let
        url =
            "http://realtime.mbta.com/developer/api/v2/predictionsbystop?format=json&api_key=" ++ apiKey ++ "&stop=" ++ stopId
    in
        Http.send ProcessBusPredictionGet (Http.get url busPredictionDecoder)
