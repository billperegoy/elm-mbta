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
import Update
import View
import Subscriptions


main : Program Never Model Msg
main =
    Html.program
        { init = init "2825"
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        }


init : String -> ( Model, Cmd Msg )
init stopId =
    Model Nothing Nothing ! [ BusPrediction.Http.get stopId ]
