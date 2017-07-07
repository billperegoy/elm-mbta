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
