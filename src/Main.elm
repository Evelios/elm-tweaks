module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Events
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Gui
import Html exposing (Html)
import Palette
import Svg
import Svg.Attributes
import Task


type alias Model =
    { float : Gui.Slider
    , string : Gui.Textbox
    , bool : Gui.Checkbox
    , toggle : Bool
    , size : Size
    }


type Msg
    = NewFloat Float
    | NewBool Bool
    | NewString String
    | GuiToggle
    | Action
    | GotViewport Browser.Dom.Viewport
    | WindowResize Size

type alias Size =
    (Float, Float)

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> (Model, Cmd Msg)
init _ =
    (
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
        , toggle = True
        , size = (0.0, 0.0)
        }
    , Task.perform GotViewport Browser.Dom.getViewport
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewFloat value ->
            ({ model | float = Gui.setSliderValue value model.float }, Cmd.none)

        NewBool value ->
            ({ model | bool = Gui.setCheckboxValue value model.bool }, Cmd.none)

        NewString value ->
            ({ model | string = Gui.setTextboxValue value model.string }, Cmd.none)

        GuiToggle ->
            ({ model | toggle = not model.toggle }, Cmd.none)

        Action ->
            (model, Cmd.none)

        GotViewport {scene, viewport} ->
            ({ model | size = (viewport.width, viewport.height) }, Cmd.none)

        WindowResize size ->
            ({ model | size = size }, Cmd.none)


subscriptions : model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize (\w h -> WindowResize (toFloat w, toFloat h))


view : Model -> Html Msg
view model =
    Element.layout
        [ Element.inFront <| gui model ]
        (sandbox model)


gui : Model -> Element Msg
gui model =
    let
        toggle = Gui.toggle GuiToggle

        guiElements =
            if model.toggle then
                [ Gui.slider model.float NewFloat
                , Gui.checkbox model.bool NewBool
                , Gui.textbox model.string NewString
                , Gui.action Action
                ]
            else
                []
    in
    Element.column
        [ Background.color Palette.colors.backgroundDarkAccent
        , Element.alignRight
        , Element.padding Palette.padding.default
        , Element.spacing Palette.spacing.default
        , Font.color Palette.colors.foreground
        , Element.below toggle
        ]
        guiElements


sandbox : Model -> Element Msg
sandbox model =
    let
        (width, height) =
            model.size

        inset =
            0.8

        background =
            Element.el
                [ Background.color Palette.colors.backgroundLight
                , Element.width Element.fill
                , Element.height Element.fill
                ]
                canvas

        canvas =
            Element.el
                [ Background.color Palette.colors.white
                , Element.centerX
                , Element.centerY
                , Element.width <| Element.px <| round (width * inset)
                , Element.height <| Element.px <| round (height * inset)
                , Border.shadow
                    { offset = (0.0, 0.0)
                    , size = 10
                    , blur = 20
                    , color = Palette.colors.black
                    }
                ]
                svg

        svg =
            Element.html <| Svg.svg
                [ Svg.Attributes.width <| String.fromInt <| round <| width * inset
                , Svg.Attributes.height <| String.fromInt <| round <| height * inset
                ]
                []

    in
    background
