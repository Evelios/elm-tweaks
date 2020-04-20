port module Main exposing (main)

import AspectRatio exposing (AspectRatio)
import Browser
import Browser.Dom
import Browser.Events
import Debug
import Dict
import File.Download as Download
import Gui
import Html exposing (Html)
import Html.Attributes
import Length exposing (Meters)
import Material.Drawer as Drawer exposing (dismissibleDrawerConfig)
import Material.Elevation as Elevation
import Material.IconButton as IconButton exposing (iconButtonConfig)
import Material.LayoutGrid as LayoutGrid
import Material.List
import Material.Menu as Menu exposing (menuConfig)
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
    , showSettings : Bool
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
    | ShowSettings


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
      , showSettings = False
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

        ShowSettings ->
            ( { model | showSettings = not model.showSettings }, Cmd.none )


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
    Html.div []
        [ settings model
        , Html.div
            [ Typography.typography
            , Drawer.appContent
            ]
            [ topBar model
            , canvas model
            ]
        ]


settings : Model -> Html Msg
settings model =
    let
        orientationOptions =
            { label = "Orientation"
            , selection =
                Dict.fromList
                    [ ( "Landscape", Landscape )
                    , ( "Portrait", Portrait )
                    ]
            , onChange = NewOrientation
            , value = model.orientation
            , comparison = Nothing
            }

        paperSizeOptions =
            { label = "Paper Size"
            , selection =
                Dict.fromList
                    [ ( "Letter", PaperSizes.letter )
                    , ( "A4", PaperSizes.a4 )
                    , ( "A3", PaperSizes.a3 )
                    , ( "A2", PaperSizes.a2 )
                    , ( "A1", PaperSizes.a1 )
                    , ( "A0", PaperSizes.a0 )
                    ]
            , onChange = NewPaperSize
            , value = model.paper
            , comparison =
                Just
                    (\_ value ->
                        value model.orientation == model.paper model.orientation
                    )
            }

        settingsOptions =
            [ Material.List.listGroupSubheader [] [ Html.text "Settings" ]
            , Material.List.listItemDivider Material.List.listItemDividerConfig
            , Material.List.listItem Material.List.listItemConfig
                [ Gui.inputSelection orientationOptions ]
            , Material.List.listItem Material.List.listItemConfig
                [ Gui.inputSelection paperSizeOptions ]
            ]
    in
    Drawer.dismissibleDrawer
        { dismissibleDrawerConfig
            | open = model.showSettings
        }
        [ Drawer.drawerContent []
            [ Material.List.listGroup []
                [ Material.List.list Material.List.listConfig settingsOptions
                , Material.List.listGroupDivider []
                ]
            ]
        ]


topBar : Model -> Html Msg
topBar model =
    TopAppBar.topAppBar TopAppBar.topAppBarConfig
        [ TopAppBar.row []
            [ TopAppBar.section [ TopAppBar.alignStart ]
                [ IconButton.iconButton
                    { iconButtonConfig
                        | additionalAttributes = [ TopAppBar.navigationIcon ]
                        , onClick = Just ShowSettings
                    }
                    "settings"
                , Html.span [ TopAppBar.title ]
                    [ Html.text model.fileName ]
                ]
            , TopAppBar.section [ TopAppBar.alignEnd ]
                [ IconButton.iconButton
                    { iconButtonConfig
                        | additionalAttributes = [ TopAppBar.actionItem ]
                        , onClick = Just GetSvg
                    }
                    "save_alt"
                ]
            ]
        ]


canvas : Model -> Html Msg
canvas model =
    let
        aspectRatio =
            AspectRatio.fromSize <| model.paper model.orientation

        svg =
            TypedSvg.svg
                [ TypedSvg.Attributes.viewBox 0 0 aspectRatio.x aspectRatio.y
                , TypedSvg.Attributes.height <|
                    TypedSvg.Types.mm <|
                        Length.inMillimeters <|
                            .height (model.paper model.orientation)
                , TypedSvg.Attributes.width <|
                    TypedSvg.Types.mm <|
                        Length.inMillimeters <|
                            .width (model.paper model.orientation)
                ]
                (Picture.drawing <| aspectRatio)
    in
    Html.div
        [ TopAppBar.fixedAdjust
        , Html.Attributes.id "canvas"
        ]
        [ svg ]
