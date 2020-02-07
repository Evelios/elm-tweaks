module Gui exposing
    ( Checkbox
    , Slider
    , Textbox
    , action
    , checkbox
    , setCheckboxValue
    , setSliderValue
    , setTextboxValue
    , slider
    , textbox
    , toggle
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Palette


type alias Slider =
    { label : String
    , value : Float
    , min : Float
    , max : Float
    , step : Maybe Float
    }


type alias Textbox =
    { label : String
    , value : String
    , placeholder : String
    }


type alias Checkbox =
    { label : String
    , value : Bool
    }


setSliderValue : Float -> Slider -> Slider
setSliderValue value model =
    { model | value = value }


setTextboxValue : String -> Textbox -> Textbox
setTextboxValue value model =
    { model | value = value }


setCheckboxValue : Bool -> Checkbox -> Checkbox
setCheckboxValue value model =
    { model | value = value }


slider : Slider -> (Float -> msg) -> Element msg
slider { label, value, min, max, step } toMsg =
    let
        input =
            Input.slider
                [ Element.spacing Palette.spacing.default
                , Element.height (Element.px Palette.sizing.default)
                , Element.width Element.fill
                , Element.behindContent
                    (Element.el
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        , Element.centerY
                        , Background.color Palette.colors.red
                        , Border.rounded Palette.sizing.xsmall
                        ]
                        Element.none
                    )
                ]
                { onChange = toMsg
                , label = Input.labelLeft [ Element.centerY ] (Element.text label)
                , min = min
                , max = max
                , step = step
                , value = value
                , thumb =
                    Input.thumb
                        [ Element.height Element.fill
                        , Element.width (Element.px Palette.padding.default)
                        , Element.alignLeft
                        , Border.rounded Palette.sizing.xsmall
                        , Background.color Palette.colors.green
                        ]
                }

        result =
            Element.el [] (Element.text <| String.fromInt <| round value)
    in
    Element.row
        [ Element.width Element.fill
        , Element.spacing Palette.spacing.default
        ]
        [ input
        , result
        ]


checkbox : Checkbox -> (Bool -> msg) -> Element msg
checkbox { label, value } toMsg =
    Input.checkbox
        [ Element.spacing 20
        ]
        { onChange = toMsg
        , icon = Input.defaultCheckbox
        , checked = value
        , label = Input.labelLeft [ Element.centerY ] (Element.text label)
        }


textbox : Textbox -> (String -> msg) -> Element msg
textbox { label, value, placeholder } toMsg =
    Input.text
        [ Element.spacing 20
        ]
        { onChange = toMsg
        , text = value
        , placeholder = Just <| Input.placeholder [ Element.centerY ] <| Element.text placeholder
        , label =
            Input.labelLeft [ Element.centerY ] (Element.text "Label")
        }


action : String -> msg -> Element msg
action label msg =
    Input.button
        [ Element.padding Palette.sizing.default
        , Background.color Palette.colors.green
        , Border.rounded Palette.sizing.xsmall
        , Element.focused
            [ Background.color Palette.colors.red ]
        ]
        { onPress = Just msg
        , label = Element.text label
        }


toggle : msg -> Element msg
toggle msg =
    Input.button
        [ Background.color Palette.colors.backgroundDark
        , Element.width Element.fill
        , Element.padding Palette.sizing.default
        , Element.focused
            [ Background.color Palette.colors.backgroundAccent ]
        ]
        { onPress = Just msg
        , label = Element.text "Toggle"
        }
