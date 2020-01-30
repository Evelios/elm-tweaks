module Gui exposing
    ( Slider
    , Textbox
    , Checkbox
    , slider
    , checkbox
    , textbox
    , action
    , setSliderValue
    , setTextboxValue
    , setCheckboxValue
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input

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


green =
    Element.rgb255 50 168 82


red =
    Element.rgb255 219 70 102


slider : Slider -> (Float -> msg) -> Element msg
slider { label, value, min, max, step } toMsg =
    Input.slider
    [ Element.height (Element.px 30)
    , Element.behindContent
        (Element.el
            [ Element.width Element.fill
            , Element.height (Element.px 2)
            , Element.centerY
            , Background.color red
            , Border.rounded 2
            ]
            Element.none
        )
    ]
    { onChange = toMsg
    , label = Input.labelLeft [ Element.centerY ] <| Element.text label
    , min = min
    , max = max
    , step = step
    , value = value
    , thumb = Input.defaultThumb
    }


checkbox : Checkbox -> (Bool -> msg) -> Element msg
checkbox { label, value } toMsg =
    Input.checkbox []
        { onChange = toMsg
        , icon = Input.defaultCheckbox
        , checked = value
        , label = Input.labelLeft [] <| Element.text label
        }

textbox : Textbox -> (String -> msg) -> Element msg
textbox { label, value, placeholder }  toMsg =
    Input.text []
        { onChange = toMsg
        , text = value
        , placeholder = Just <| Input.placeholder [ Element.centerY ] <| Element.text placeholder
        , label = Input.labelLeft [ Element.centerY ] <| Element.text "Label"
        }

action : msg -> Element msg
action msg =
    Input.button
        [ Background.color green
        , Element.focused
            [ Background.color red ]
        ]
        { onPress = Just msg
        , label = Element.text "Button"
        }
