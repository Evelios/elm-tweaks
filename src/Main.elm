port module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Events
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import File.Download as Download
import Gui
import Html exposing (Html)
import Html.Attributes
import Length exposing (Meters)
import Palette
import Size exposing (AspectRatio, Size)
import Svg exposing (Svg)
import Svg.Attributes
import Task


port getSvg : String -> Cmd msg


port gotSvg : (String -> msg) -> Sub msg


type alias Model =
    { width : Float
    , height : Float
    , inputWidth : String
    , inputHeight : String
    , fileName : String
    , paperSize : Size Meters
    }


type Msg
    = GetSvg
    | GotSvg String
    | GotViewport Browser.Dom.Viewport
    | WindowResize ( Float, Float )
    | NewFileName String
    | NewWidth String
    | NewHeight String
    | NewPaperSize (Size Meters)


paperSizes : Dict String (Size Meters)
paperSizes =
    Dict.fromList
        [ ( "A4", Size.size (Length.millimeters 210) (Length.millimeters 297) )
        , ( "A3", Size.size (Length.millimeters 297) (Length.millimeters 420) )
        , ( "Letter", Size.size (Length.inches 8.5) (Length.inches 11) )
        ]


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
    ( { width = 0
      , height = 0
      , inputWidth = "0"
      , inputHeight = "0"
      , fileName = "canvas"
      , paperSize = Size.size (Length.inches 8.5) (Length.inches 11)
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotViewport { scene, viewport } ->
            ( { model
                | width = viewport.width
                , height = viewport.height
                , inputWidth = String.fromInt <| round <| viewport.width
                , inputHeight = String.fromInt <| round <| viewport.height
              }
            , Cmd.none
            )

        WindowResize ( width, height ) ->
            ( { model
                | width = width
                , height = height
                , inputWidth = String.fromInt <| round <| width
                , inputHeight = String.fromInt <| round <| height
              }
            , Cmd.none
            )

        GetSvg ->
            ( model, getSvg "canvas" )

        GotSvg output ->
            ( model, download model.fileName output )

        NewFileName fileName ->
            ( { model | fileName = fileName }
            , Cmd.none
            )

        NewWidth textWidth ->
            case String.toFloat textWidth of
                Just width ->
                    ( { model
                        | width = width
                        , inputWidth = textWidth
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | inputWidth = textWidth }, Cmd.none )

        NewHeight textHeight ->
            case String.toFloat textHeight of
                Just height ->
                    ( { model
                        | height = height
                        , inputHeight = textHeight
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | inputHeight = textHeight }, Cmd.none )

        NewPaperSize size ->
            ( { model | paperSize = size }, Cmd.none )


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
        [ Background.color Palette.colors.background.default
        , Element.width Element.fill
        , Font.color Palette.colors.foreground.default
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
        , Gui.image
            { src = "img/width.svg"
            , description = "Width"
            }
        , Gui.textbox
            { label = "px"
            , placeholder = "Width"
            , value = model.inputWidth
            }
            NewWidth
        , Gui.image
            { src = "img/height.svg"
            , description = "Height"
            }
        , Gui.textbox
            { label = "px"
            , placeholder = "Height"
            , value = model.inputHeight
            }
            NewHeight
        ]


sandbox : Model -> Element Msg
sandbox model =
    let
        ( width, height ) =
            canvasSize model.width model.height

        background =
            Element.el
                [ Background.color Palette.colors.background.light
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
                , Element.width <| Element.px width
                , Element.height <| Element.px height
                , Border.shadow
                    { offset = ( 0.0, 0.0 )
                    , size = 10
                    , blur = 20
                    , color = Palette.colors.black
                    }
                ]
                (Element.html <| drawing <| canvasSize model.width model.height)
    in
    background


canvasSize : Float -> Float -> ( Int, Int )
canvasSize width height =
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
