module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode
import Json.Decode.Pipeline
import BusPrediction exposing (..)
import BusPrediction.Http exposing (..)
import Model exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init stopId
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : String -> ( Model, Cmd Msg )
init stopId =
    Model Nothing Nothing ! [ BusPrediction.Http.get stopId ]


stopId =
    "2825"


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
            model ! [ BusPrediction.Http.get stopId ]



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
