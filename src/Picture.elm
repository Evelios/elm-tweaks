module Picture exposing (drawing)

import AspectRatio exposing (AspectRatio)
import Pixels exposing (Pixels)
import Svg exposing (Svg)
import Svg.Attributes


drawing : AspectRatio -> List (Svg msg)
drawing ratio =
    [ Svg.circle
        [ Svg.Attributes.cx <| String.fromFloat (ratio.x / 2)
        , Svg.Attributes.cy <| String.fromFloat (ratio.y / 2)
        , Svg.Attributes.r "0.5"
        ]
        []
    ]
