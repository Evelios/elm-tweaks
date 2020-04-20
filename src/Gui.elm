module Gui exposing (InputSelectionOptions, inputSelection)

import Dict exposing (Dict)
import Dict.Extra
import Html exposing (Html)
import Material.Select as Select exposing (selectConfig, selectOptionConfig)


type alias InputSelectionOptions option msg =
    { label : String
    , selection : Dict String option
    , onChange : option -> msg
    , value : option
    }


inputSelection : InputSelectionOptions option msg -> Html msg
inputSelection inputOptions =
    let
        selectionOptions =
            Dict.keys inputOptions.selection
                |> List.map
                    (\name ->
                        Select.selectOption
                            { selectOptionConfig | value = name }
                            [ Html.text name ]
                    )

        newOption str =
            Dict.get str inputOptions.selection
                |> Maybe.withDefault inputOptions.value
                |> inputOptions.onChange
    in
    selectionOptions
        |> Select.filledSelect
            { selectConfig
                | label = inputOptions.label
                , value =
                    inputOptions.selection
                        |> Dict.Extra.find (\_ value -> value == inputOptions.value)
                        |> Maybe.withDefault ( "Unknown", inputOptions.value )
                        |> Tuple.first
                        |> Just
                , onChange = Just newOption
            }
