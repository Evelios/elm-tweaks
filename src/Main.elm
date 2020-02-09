port module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Events
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import File.Download as Download
import Gui
import Html exposing (Html)
import Html.Attributes
import Palette
import Svg exposing (Svg)
import Svg.Attributes
import Task


port getSvg : String -> Cmd msg


port gotSvg : (String -> msg) -> Sub msg


type alias Model =
    { size : Size
    , fileName : String
    }


type Msg
    = GetSvg
    | GotSvg String
    | GotViewport Browser.Dom.Viewport
    | WindowResize Size
    | NewFileName String


type alias Size =
    ( Float, Float )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { size = ( 0.0, 0.0 )
      , fileName = "canvas"
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotViewport { scene, viewport } ->
            ( { model | size = ( viewport.width, viewport.height ) }, Cmd.none )

        WindowResize size ->
            ( { model | size = size }, Cmd.none )

        GetSvg ->
            ( model, getSvg "canvas" )

        GotSvg output ->
            ( model, download model.fileName output )

        NewFileName fileName ->
            ( { model | fileName = fileName }
            , Cmd.none
            )


download : String -> String -> Cmd msg
download fileName svg =
    Download.string (String.append fileName ".svg") "image/svg+xml" svg


subscriptions : model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize (\w h -> WindowResize ( toFloat w, toFloat h ))
        , gotSvg GotSvg
        ]


view : Model -> Html Msg
view model =
    Element.layout
        [ Element.width Element.fill
        , Element.height Element.fill
        ]
        (Element.column
            [ Element.width Element.fill
            , Element.height Element.fill
            ]
            [ gui model
            , sandbox model
            ]
        )


gui : Model -> Element Msg
gui model =
    Element.row
        [ Background.color Palette.colors.backgroundDark
        , Element.width Element.fill
        , Font.color Palette.colors.foreground
        ]
        [ Gui.imageButton
            { src = "img/download.svg"
            , description = "Download"
            }
            GetSvg
        , Gui.textbox
            { label = "File Name"
            , placeholder = "my_drawing"
            , value = model.fileName
            }
            NewFileName
        ]


sandbox : Model -> Element Msg
sandbox model =
    let
        ( width, height ) =
            canvasSize model.size

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
                , Element.htmlAttribute <| Html.Attributes.id "canvas"
                , Element.centerX
                , Element.centerY
                , Element.width <| Element.px <| width
                , Element.height <| Element.px <| height
                , Border.shadow
                    { offset = ( 0.0, 0.0 )
                    , size = 10
                    , blur = 20
                    , color = Palette.colors.black
                    }
                ]
                (Element.html <| drawing ( width, height ))
    in
    background


canvasSize : ( Float, Float ) -> ( Int, Int )
canvasSize ( width, height ) =
    let
        inset =
            0.8
    in
    ( round (width * inset), round (height * inset) )


drawing : ( Int, Int ) -> Svg msg
drawing ( width, height ) =
    Svg.svg
        [ Svg.Attributes.width <| String.fromInt <| width
        , Svg.Attributes.height <| String.fromInt <| height
        ]
        []
