module Picture exposing (drawing)

import Algorithms
import AspectRatio exposing (AspectRatio)
import BoundingBox2d
import Color exposing (Color)
import Pixels exposing (Pixels)
import Point2d
import Quantity
import Random
import Random.Extra
import Svg exposing (Svg)
import TypedSvg
import TypedSvg.Attributes as Attr
import TypedSvg.Attributes.InPx as AttrPx
import TypedSvg.Types as Types exposing (Length(..))


a =
    Color.rgb 0.5 0.25 0.7


b =
    Color.rgb 0.7 0.25 0.5


drawing : AspectRatio -> Random.Generator (List (Svg msg))
drawing ratio =
    let
        density =
            0.1

        radius =
            density / 2

        points =
            Algorithms.poisson
                (Quantity.float 0.5)
                (BoundingBox2d.from
                    Point2d.origin
                    (Point2d.unitless
                        (AspectRatio.x ratio)
                        (AspectRatio.y ratio)
                    )
                )

        pointToCircle point =
            let
                { x, y } =
                    Point2d.toUnitless point
            in
            TypedSvg.circle
                [ Attr.cx <| Num x
                , Attr.cy <| Num y
                , Attr.r <| Num radius
                , Attr.fill (Types.Paint a)
                ]
                []

        circles =
            List.map (Random.map pointToCircle) points

        background =
            Random.constant <|
                TypedSvg.rect
                    [ Attr.width <| Num ratio.x
                    , Attr.height <| Num ratio.y
                    , Attr.fill <| Types.Paint b
                    ]
                    []
    in
    Random.Extra.sequence <| background :: circles
