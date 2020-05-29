module Size exposing
    ( Size
    , aspectRatio
    , height
    , scale
    , setHeight
    , setWidth
    , shrinkToAspectRatio
    , size
    , width
    )

import AspectRatio exposing (AspectRatio)
import Quantity exposing (Quantity)


type Size units
    = Size (Quantity Float units) (Quantity Float units)


size : Quantity Float units -> Quantity Float units -> Size units
size w h =
    Size w h


width : Size units -> Quantity Float units
width (Size theWidth _) =
    theWidth


height : Size units -> Quantity Float units
height (Size _ theHeight) =
    theHeight


setHeight : Quantity Float units -> Size units -> Size units
setHeight theHeight (Size theWidth _) =
    size theWidth theHeight


setWidth : Quantity Float units -> Size units -> Size units
setWidth theWidth (Size _ theHeight) =
    size theWidth theHeight


scale : Float -> Size units -> Size units
scale amount (Size oldWidth oldHeight) =
    size
        (Quantity.multiplyBy amount oldWidth)
        (Quantity.multiplyBy amount oldHeight)


shrinkToAspectRatio : AspectRatio -> Size units -> Size units
shrinkToAspectRatio ratio (Size theWidth theHeight) =
    let
        widthNew =
            if AspectRatio.x ratio < AspectRatio.y ratio then
                Quantity.divideBy (AspectRatio.y ratio) theHeight

            else
                Quantity.divideBy (AspectRatio.y ratio) theWidth

        heightNew =
            if AspectRatio.y ratio > AspectRatio.x ratio then
                Quantity.divideBy (AspectRatio.x ratio) theHeight

            else
                Quantity.divideBy (AspectRatio.x ratio) theWidth
    in
    size widthNew heightNew


aspectRatio : Size units -> AspectRatio
aspectRatio (Size theWidth theHeight) =
    let
        largest =
            Quantity.max theWidth theHeight

        xAspect =
            Quantity.ratio largest theHeight

        yAspect =
            Quantity.ratio largest theWidth
    in
    AspectRatio.aspectRatio xAspect yAspect
