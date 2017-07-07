module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)


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
