module Gui exposing
    ( image
    , imageButton
    , textbox
    )

import Element exposing (Element)
import Element.Events as Events
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


type alias Image =
    { src : String
    , description : String
    }


image : Image -> Element msg
image { src, description } =
    Element.image
        [ Element.width Palette.sizing.default
        ]
        { src = src
        , description = description
        }


imageButton : Image -> msg -> Element msg
imageButton { src, description } msg =
    Element.image
        [ Events.onClick msg
        , Element.width Palette.sizing.default
        ]
        { src = src
        , description = description
        }
