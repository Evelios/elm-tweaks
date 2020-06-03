port module Generative exposing (Model, Msg, random)

import AspectRatio exposing (AspectRatio)
import Browser
import Browser.Dom
import Browser.Events
import Dict
import File.Download as Download
import Gui
import Html exposing (Html)
import Html.Attributes
import Length exposing (Meters)
import Material.Drawer as Drawer exposing (dismissibleDrawerConfig)
import Material.Elevation
import Material.Fab as Fab exposing (fabConfig)
import Material.IconButton as IconButton exposing (iconButtonConfig)
import Material.List
import Material.TopAppBar as TopAppBar
import Material.Typography as Typography
import PaperSizes exposing (Orientation(..))
import Pixels exposing (Pixels)
import Quantity
import Random exposing (Generator)
import Size exposing (Size)
import Svg exposing (Svg)
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
    , picture : List (Svg Msg)
    , unit : Unit
    , pictureGenerator : AspectRatio -> Generator (List (Svg Msg))
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
    | GotPicture (List (Svg Msg))
    | NewPicture
    | NewUnit Unit


type Unit
    = Millimeters
    | Centimeters
    | Inches


random : (AspectRatio -> Generator (List (Svg Msg))) -> Program () Model Msg
random pictureGenerator =
    Browser.element
        { init = init pictureGenerator
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : (AspectRatio -> Generator (List (Svg Msg))) -> () -> ( Model, Cmd Msg )
init pictureGenerator _ =
    let
        model =
            { view = Size.size (Pixels.pixels 0) (Pixels.pixels 0)
            , paper = PaperSizes.a4
            , orientation = Landscape
            , inputWidth = "0"
            , inputHeight = "0"
            , fileName = "canvas"
            , showSettings = False
            , picture = []
            , unit = Millimeters
            , pictureGenerator = pictureGenerator
            }
    in
    ( model
    , Cmd.batch
        [ Task.perform GotViewport Browser.Dom.getViewport
        , newPicture model
        ]
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
            { model | paper = size }
                |> update NewPicture

        NewOrientation orientation ->
            { model | orientation = orientation }
                |> update NewPicture

        ShowSettings ->
            ( { model | showSettings = not model.showSettings }, Cmd.none )

        GotPicture picture ->
            ( { model | picture = picture }, Cmd.none )

        NewPicture ->
            ( model, newPicture model )

        NewUnit unit ->
            ( { model | unit = unit }, Cmd.none )


download : String -> String -> Cmd msg
download fileName svg =
    String.replace "style=\"display: none;\"" "" svg
        |> Download.string (String.append fileName ".svg") "image/svg+xml"


newPicture : Model -> Cmd Msg
newPicture model =
    let
        aspectRatio =
            Size.aspectRatio <| model.paper model.orientation
    in
    Random.generate GotPicture (model.pictureGenerator aspectRatio)


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
            , Html.Attributes.style "width" "100%"
            , Html.Attributes.style "height" "100%"
            ]
            [ topBar model
            , canvas model
            ]
        , fab
        ]


fab : Html Msg
fab =
    Fab.fab
        { fabConfig
            | onClick = Just NewPicture
            , additionalAttributes =
                [ Html.Attributes.style "position" "absolute"
                , Html.Attributes.style "bottom" "50px"
                , Html.Attributes.style "right" "50px"
                ]
        }
        "camera"


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

        unitOptions =
            { label = "Units"
            , selection =
                Dict.fromList
                    [ ( "Millimeters", Millimeters )
                    , ( "Centimeters", Centimeters )
                    , ( "Inches", Inches )
                    ]
            , onChange = NewUnit
            , value = model.unit
            , comparison = Nothing
            }

        settingsOptions =
            [ Material.List.listGroupSubheader [] [ Html.text "Settings" ]
            , Material.List.listItemDivider Material.List.listItemDividerConfig
            , Material.List.listItem Material.List.listItemConfig
                [ Gui.inputSelection orientationOptions ]
            , Material.List.listItem Material.List.listItemConfig
                [ Gui.inputSelection unitOptions ]
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
        pixelsToString pixels =
            (String.fromFloat <| Pixels.inPixels pixels) ++ "px"

        paperRatio =
            Size.aspectRatio <| model.paper model.orientation

        topAppBarSize =
            Pixels.pixels 64

        canvasSize =
            let
                shrinkRatio =
                    0.8

                sizeWithoutTopAppBar =
                    Size.height model.view |> Quantity.minus topAppBarSize
            in
            model.view
                |> Size.setHeight sizeWithoutTopAppBar
                |> Size.scale shrinkRatio
                |> Size.shrinkToAspectRatio paperRatio

        heightAdjust =
            Size.height model.view
                |> Quantity.minus (Size.height canvasSize)
                |> Quantity.plus topAppBarSize
                |> Quantity.half

        svg =
            TypedSvg.svg
                [ TypedSvg.Attributes.viewBox 0 0 (AspectRatio.x paperRatio) (AspectRatio.y paperRatio)
                , Html.Attributes.style "width" "100%"
                , Html.Attributes.style "height" "100%"
                ]
                model.picture

        export =
            let
                conversion =
                    case model.unit of
                        Millimeters ->
                            TypedSvg.Types.mm << Length.inMillimeters

                        Centimeters ->
                            TypedSvg.Types.cm << Length.inCentimeters

                        Inches ->
                            TypedSvg.Types.inch << Length.inInches
            in
            TypedSvg.svg
                [ TypedSvg.Attributes.viewBox 0 0 (AspectRatio.x paperRatio) (AspectRatio.y paperRatio)
                , Html.Attributes.style "display" "none"
                , TypedSvg.Attributes.height <| conversion <| Size.height (model.paper model.orientation)
                , TypedSvg.Attributes.width <| conversion <| Size.width (model.paper model.orientation)
                ]
                model.picture
    in
    Html.div
        [ Html.Attributes.style "margin" "auto"
        , Html.Attributes.style "padding-top" <| pixelsToString <| heightAdjust
        , Html.Attributes.style "width" <| pixelsToString <| Size.width canvasSize
        , Html.Attributes.style "height" <| pixelsToString <| Size.height canvasSize
        ]
        [ Html.div
            [ Material.Elevation.z24
            , Html.Attributes.style "width" "100%"
            , Html.Attributes.style "height" "100%"
            ]
            [ svg
            , export
            ]
        ]
