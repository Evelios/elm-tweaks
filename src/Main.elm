port module Main exposing (main)

import AspectRatio exposing (AspectRatio)
import Browser
import Browser.Dom
import Browser.Events
import Debug
import Dict exposing (Dict)
import File.Download as Download
import Html exposing (Html)
import Html.Attributes
import Length exposing (Meters)
import Material.Elevation as Elevation
import Material.IconButton as IconButton exposing (iconButtonConfig)
import Material.LayoutGrid as LayoutGrid
import Material.TopAppBar as TopAppBar
import Material.Typography as Typography
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
    , paper : Orientation -> Size Meters
    , orientation : Orientation
    , inputWidth : String
    , inputHeight : String
    , fileName : String
    }


type Msg
    = GetSvg
    | GotSvg String
    | GotViewport Browser.Dom.Viewport
    | WindowResize ( Float, Float )
    | NewFileName String
    | NewWidth String
    | NewHeight String
    | NewPaperSize (Orientation -> Size Meters)
    | NewOrientation Orientation


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
      , paper = PaperSizes.a4
      , orientation = Landscape
      , inputWidth = "0"
      , inputHeight = "0"
      , fileName = "canvas"
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
            ( { model | paper = size }, Cmd.none )

        NewOrientation orientation ->
            ( { model | orientation = orientation }, Cmd.none )


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
    let
        menu =
            TopAppBar.topAppBar TopAppBar.topAppBarConfig
                [ TopAppBar.row []
                    [ TopAppBar.section [ TopAppBar.alignStart ]
                        [ IconButton.iconButton
                            { iconButtonConfig
                                | additionalAttributes =
                                    [ TopAppBar.navigationIcon ]
                            }
                            "menu"
                        , Html.span [ TopAppBar.title ]
                            [ Html.text "Title" ]
                        ]
                    ]
                ]

        maxHeight =
            Quantity.multiplyBy 0.8 model.view.height
                |> Pixels.inPixels
                |> String.fromFloat
                |> (\px -> px ++ "px")

        center =
            Html.div
                [ TopAppBar.fixedAdjust ]
                [ svg ]

        aspectRatio =
            AspectRatio.fromSize <| model.paper model.orientation

        svg : Html msg
        svg =
            TypedSvg.svg
                [ TypedSvg.Attributes.viewBox 0 0 aspectRatio.x aspectRatio.y
                ]
                (Picture.drawing <| aspectRatio)
    in
    Html.div [ Typography.typography ]
        [ menu
        , center
        ]
