port module Main exposing (main)

import AspectRatio exposing (AspectRatio)
import Browser
import Browser.Dom
import Browser.Events
import Debug
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
import PaperSizes exposing (Orientation(..))
import Picture
import Pixels exposing (Pixels)
import Quantity
import Size exposing (Size)
import Task
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Types


port getSvg : String -> Cmd msg


port gotSvg : (String -> msg) -> Sub msg


type alias Model =
    { view : Size Pixels
    , paper : Size Meters
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
    ( { view = Size.size (Pixels.pixels 0) (Pixels.pixels 0)
      , paper = PaperSizes.a4 Landscape
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
                | view =
                    Size.size
                        (Pixels.pixels viewport.width)
                        (Pixels.pixels viewport.height)
                , inputWidth = String.fromInt <| round <| viewport.width
                , inputHeight = String.fromInt <| round <| viewport.height
              }
            , Cmd.none
            )

        WindowResize ( width, height ) ->
            ( { model
                | view =
                    Size.size
                        (Pixels.pixels width)
                        (Pixels.pixels height)
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
                        | view = Size.setWidth (Pixels.pixels width) model.view
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
                        | view = Size.setHeight (Pixels.pixels height) model.view
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
        scale =
            0.8

        aspectRatio =
            AspectRatio.fromSize model.paper

        canvasWidth =
            Size.min model.view
                |> Quantity.multiplyBy (scale * aspectRatio.x)

        canvasHeight =
            Size.min model.view
                |> Quantity.multiplyBy (scale * aspectRatio.y)

        svg =
            Element.html <|
                TypedSvg.svg
                    [ TypedSvg.Attributes.viewBox 0 0 aspectRatio.x aspectRatio.y
                    , TypedSvg.Attributes.height <| TypedSvg.Types.Px <| Pixels.inPixels canvasHeight
                    , TypedSvg.Attributes.width <| TypedSvg.Types.Px <| Pixels.inPixels canvasWidth
                    ]
                    (Picture.drawing <| aspectRatio)

        canvas =
            Element.el
                [ Background.color Palette.colors.white
                , Element.htmlAttribute <| Html.Attributes.id "canvas"
                , Element.centerX
                , Element.centerY
                , Border.shadow
                    { offset = ( 0.0, 0.0 )
                    , size = 10
                    , blur = 20
                    , color = Palette.colors.black
                    }
                ]
                svg
    in
    Element.el
        [ Background.color Palette.colors.background.light
        , Element.centerX
        , Element.centerY
        , Element.height Element.fill
        , Element.width Element.fill
        ]
        canvas
