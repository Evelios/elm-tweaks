module Main exposing (main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Gui
import Html exposing (Html)
import Html.Events as Events


palette =
    { gray = Element.rgb255 48 48 48
    , grayLight = Element.rgb255 57 57 57
    , yellow = Element.rgb255 170 117 57
    , red = Element.rgb255 162 54 69
    , blue = Element.rgb255 39 86 107
    , green = Element.rgb255 71 144 48
    }


type alias Model =
    { float : Gui.Slider
    , string : Gui.Textbox
    , bool : Gui.Checkbox
    }


type Msg
    = NewFloat Float
    | NewBool Bool
    | NewString String
    | Action


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }


init : Model
init =
    { float =
        { label = "Float"
        , value = 25.0
        , min = 0.0
        , max = 100.0
        , step = Nothing
        }
    , bool =
        { label = "Checkbox"
        , value = False
        }
    , string =
        { label = "Textbox"
        , value = ""
        , placeholder = "Default Text"
        }
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        NewFloat value ->
            { model | float = Gui.setSliderValue value model.float }

        NewBool value ->
            { model | bool = Gui.setCheckboxValue value model.bool }

        NewString value ->
            { model | string = Gui.setTextboxValue value model.string }

        Action ->
            model


view : Model -> Html Msg
view model =
    Element.layout
        [ Element.inFront <| gui model ]
        (sandbox model)


gui : Model -> Element Msg
gui model =
    Element.column
        [ Background.color palette.grayLight
        , Element.alignRight
        , Element.padding 20
        , Element.spacing 20
        ]
        [ Gui.slider model.float NewFloat
        , Gui.checkbox model.bool NewBool
        , Gui.textbox model.string NewString
        , Gui.action Action
        ]


sandbox : Model -> Element Msg
sandbox _ =
    Element.el
        [ Background.color palette.gray
        , Element.width Element.fill
        , Element.height Element.fill
        , Element.padding 20
        ]
        (Element.text "Sandbox Region")
