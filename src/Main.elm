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
    Element.layout [] (gui model)


gui : Model -> Element Msg
gui model =
    Element.column []
        [ Gui.slider model.float NewFloat
        , Gui.checkbox model.bool NewBool
        , Gui.textbox model.string NewString
        , Gui.action Action
        ]
