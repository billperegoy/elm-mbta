module Update exposing (..)

import Model exposing (..)
import BusPrediction.Http


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
            model ! [ BusPrediction.Http.get "2825" ]
