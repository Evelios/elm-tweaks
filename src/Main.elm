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
import Palette


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
        [ Background.color Palette.colors.grayLight
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
    let
        background =
            Element.row
                [ Background.color Palette.colors.gray
                , Element.width Element.fill
                , Element.height Element.fill
                , Element.padding 20
                ]
                [ buffer
                , canvas
                , buffer
                ]

        canvas =
            Element.el
                [ Background.color Palette.colors.grayLight
                , Element.width <| Element.fillPortion 7
                , Element.height Element.fill
                , Border.shadow
                    { offset = (0.0, 0.0)
                    , size = 10
                    , blur = 10
                    , color = Palette.colors.yellow
                    }
                ]
                (Element.text "Sandbox Region")

        buffer =
            Element.el
                [ Element.width <| Element.fillPortion 1
                ]
                Element.none
    in
    background

