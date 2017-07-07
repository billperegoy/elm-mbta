module BusPrediction exposing (..)

import Http
import Json.Decode
import Json.Decode.Pipeline


type alias BusPrediction =
    { stopId : String
    , stopName : String
    , modes : List Mode
    }


type alias Mode =
    { routeType : String
    , modeName : String
    , routes : List Route
    }


type alias Route =
    { routeId : String
    , routeName : String
    , directions : List Direction
    }


type alias Direction =
    { directionId : String
    , directionName : String
    , trips : List Trip
    }


type alias Trip =
    { tripId : String
    , tripName : String
    , preAway : String
    }


busPredictionDecoder : Json.Decode.Decoder BusPrediction
busPredictionDecoder =
    Json.Decode.Pipeline.decode BusPrediction
        |> Json.Decode.Pipeline.required "stop_id" Json.Decode.string
        |> Json.Decode.Pipeline.required "stop_name" Json.Decode.string
        |> Json.Decode.Pipeline.optional "mode" modeListDecoder []


modeListDecoder : Json.Decode.Decoder (List Mode)
modeListDecoder =
    Json.Decode.list modeDecoder


modeDecoder : Json.Decode.Decoder Mode
modeDecoder =
    Json.Decode.Pipeline.decode Mode
        |> Json.Decode.Pipeline.required "route_type" Json.Decode.string
        |> Json.Decode.Pipeline.required "mode_name" Json.Decode.string
        |> Json.Decode.Pipeline.required "route" routeListDecoder


routeListDecoder : Json.Decode.Decoder (List Route)
routeListDecoder =
    Json.Decode.list routeDecoder


routeDecoder : Json.Decode.Decoder Route
routeDecoder =
    Json.Decode.Pipeline.decode Route
        |> Json.Decode.Pipeline.required "route_id" Json.Decode.string
        |> Json.Decode.Pipeline.required "route_name" Json.Decode.string
        |> Json.Decode.Pipeline.required "direction" directionListDecoder


directionListDecoder : Json.Decode.Decoder (List Direction)
directionListDecoder =
    Json.Decode.list directionDecoder


directionDecoder : Json.Decode.Decoder Direction
directionDecoder =
    Json.Decode.Pipeline.decode Direction
        |> Json.Decode.Pipeline.required "direction_id" Json.Decode.string
        |> Json.Decode.Pipeline.required "direction_name" Json.Decode.string
        |> Json.Decode.Pipeline.required "trip" tripListDecoder


tripListDecoder : Json.Decode.Decoder (List Trip)
tripListDecoder =
    Json.Decode.list tripDecoder


tripDecoder : Json.Decode.Decoder Trip
tripDecoder =
    Json.Decode.Pipeline.decode Trip
        |> Json.Decode.Pipeline.required "trip_id" Json.Decode.string
        |> Json.Decode.Pipeline.required "trip_name" Json.Decode.string
        |> Json.Decode.Pipeline.required "pre_away" Json.Decode.string
