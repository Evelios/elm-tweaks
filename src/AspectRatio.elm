module AspectRatio exposing
    ( AspectRatio
    , aspectRatio
    , fromSize
    , inAspectRatio
    , toSizeFromBase
    )

import Quantity exposing (Quantity)
import Size exposing (Size)


type alias AspectRatio =
    { x : Float
    , y : Float
    }


aspectRatio : Float -> Float -> AspectRatio
aspectRatio x y =
    let
        denom =
            min x y
    in
    AspectRatio (x / denom) (y / denom)


fromSize : Size units -> AspectRatio
fromSize { width, height } =
    let
        largest =
            Quantity.max width height

        xAspect =
            Quantity.ratio largest height

        yAspect =
            Quantity.ratio largest width
    in
    AspectRatio xAspect yAspect


toSizeFromBase : Quantity Float units -> AspectRatio -> Size units
toSizeFromBase min aspect =
    Size.size (Quantity.multiplyBy aspect.x min) (Quantity.multiplyBy aspect.y min)


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
    Size.size widthNew heightNew
