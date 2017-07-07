module Model exposing (..)

import BusPrediction exposing (..)
import Http


type alias UpcomingBus =
    { busName : String
    , routeName : String
    , waitTime : Int
    }


type alias Model =
    { prediction : Maybe BusPrediction
    , error : Maybe Http.Error
    }


type Msg
    = ProcessBusPredictionGet (Result Http.Error BusPrediction)
    | Update
