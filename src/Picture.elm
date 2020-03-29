module Picture exposing (drawing)

import AspectRatio exposing (AspectRatio)
import Color exposing (Color)
import Pixels exposing (Pixels)
import Svg exposing (Svg)
import TypedSvg
import TypedSvg.Attributes as Attr
import TypedSvg.Attributes.InPx as AttrPx
import TypedSvg.Types as Types exposing (Length(..))


a =
    Color.rgb 0.5 0.25 0.7


b =
    Color.rgb 0.7 0.25 0.5


drawing : AspectRatio -> List (Svg msg)
drawing ratio =
    [ TypedSvg.rect
        [ Attr.width <| Num ratio.x
        , Attr.height <| Num ratio.y
        , Attr.fill <| Types.Paint b
        ]
        []
    , TypedSvg.circle
        [ Attr.cx <| Num <| ratio.x / 2
        , Attr.cy <| Num <| ratio.y / 2
        , Attr.r (Num 0.4)
        , Attr.fill (Types.Paint a)
        ]
        []
    ]
