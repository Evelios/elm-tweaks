module Size exposing
    ( AspectRatio
    , Size
    , asAspectRatio
    , aspectRatio
    , inAspectRatio
    , scale
    , size
    )

import Quantity exposing (Quantity)


type alias Size units =
    { width : Quantity Float units
    , height : Quantity Float units
    }


type alias AspectRatio =
    { x : Float
    , y : Float
    }


size : Quantity Float units -> Quantity Float units -> Size units
size width height =
    Size width height


scale : Float -> Size units -> Size units
scale ammount from =
    size
        (Quantity.multiplyBy ammount from.width)
        (Quantity.multiplyBy ammount from.height)


aspectRatio : Float -> Float -> AspectRatio
aspectRatio x y =
    let
        denom =
            min x y
    in
    AspectRatio (x / denom) (y / denom)


asAspectRatio : Size units -> AspectRatio
asAspectRatio { width, height } =
    let
        largest =
            Quantity.max width height

        xAspect =
            Quantity.ratio largest height

        yAspect =
            Quantity.ratio largest width
    in
    AspectRatio xAspect yAspect


inAspectRatio : AspectRatio -> Size units -> Size units
inAspectRatio { x, y } { width, height } =
    let
        widthNew =
            if y > x then
                Quantity.divideBy y height

            else
                Quantity.divideBy y width

        heightNew =
            if y > x then
                Quantity.divideBy x height

            else
                Quantity.divideBy x width
    in
    size widthNew heightNew
