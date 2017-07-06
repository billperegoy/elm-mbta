module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode
import Json.Decode.Pipeline


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


apiKey =
    "AjxKPBBTD0GvOT0DgnE7yw"


stopId =
    "2825"


get : String -> Cmd Msg
get stopId =
    let
        url =
            "http://realtime.mbta.com/developer/api/v2/predictionsbystop?format=json&api_key=" ++ apiKey ++ "&stop=" ++ stopId
    in
        Http.send ProcessBusPredictionGet (Http.get url busPredictionDecoder)


busAdapter : BusPrediction -> List UpcomingBus
busAdapter prediction =
    case prediction.modes of
        [] ->
            []

        [ mode ] ->
            case mode.routes of
                [] ->
                    []

                [ route ] ->
                    case route.directions of
                        [] ->
                            []

                        [ direction ] ->
                            List.map (\trip -> UpcomingBus route.routeName trip.tripName (trip.preAway |> String.toInt |> Result.withDefault 0)) direction.trips

                        -- FIXME - error case
                        _ ->
                            []

                -- FIXME - error case
                _ ->
                    []

        -- FIXME - error case
        _ ->
            []


type alias UpcomingBus =
    { busName : String
    , routeName : String
    , waitTime : Int
    }


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



-- Model


type alias Model =
    { prediction : Maybe BusPrediction
    , error : Maybe Http.Error
    }


init : ( Model, Cmd Msg )
init =
    Model Nothing Nothing ! [ get stopId ]



-- Update


type Msg
    = ProcessBusPredictionGet (Result Http.Error BusPrediction)
    | Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProcessBusPredictionGet (Ok prediction) ->
            { model
                | error = Nothing
                , prediction = Just prediction
            }
                ! []

        ProcessBusPredictionGet (Err error) ->
            { model
                | error = Just error
                , prediction = Nothing
            }
                ! []

        Update ->
            model ! [ get stopId ]



-- View


singleBus : UpcomingBus -> Html Msg
singleBus elem =
    div []
        [ text
            (elem.busName
                ++ " -> "
                ++ elem.routeName
                ++ "  comes in "
                ++ toString (elem.waitTime // 60)
                ++ " minutes"
            )
        ]


view : Model -> Html Msg
view model =
    case model.prediction of
        Nothing ->
            div []
                [ div [] [ text "No scheduled busses found" ]
                , div [ onClick Update ] [ button [] [ text "Refresh" ] ]
                ]

        Just things ->
            div []
                [ div []
                    (things
                        |> busAdapter
                        |> List.map singleBus
                    )
                , div [ onClick Update ] [ button [] [ text "Refresh" ] ]
                ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
