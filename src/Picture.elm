module Picture exposing (drawing)

import AspectRatio exposing (AspectRatio)
import Pixels exposing (Pixels)
import Svg exposing (Svg)
import TypedSvg
import TypedSvg.Attributes.InPx as Attr


drawing : AspectRatio -> List (Svg msg)
drawing ratio =
    [ TypedSvg.circle
        [ Attr.cx (ratio.x / 2)
        , Attr.cy (ratio.y / 2)
        , Attr.r 0.4
        ]
        []
    ]
