module Gui exposing
    ( imageButton
    , textbox
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Palette


type alias Textbox =
    { label : String
    , value : String
    , placeholder : String
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
            Input.labelLeft [ Element.centerY ] (Element.text label)
        }


type alias ImageButton =
    { src : String
    , description : String
    }


imageButton : ImageButton -> msg -> Element msg
imageButton { src, description } msg =
    Element.image
        [ Events.onClick msg
        , Element.width Palette.sizing.default
        ]
        { src = src
        , description = description
        }
