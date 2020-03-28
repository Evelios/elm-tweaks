module Size exposing
    ( Size
    , scale
    , setHeight
    , setWidth
    , size
    )

import Quantity exposing (Quantity)


type alias Size units =
    { width : Quantity Float units
    , height : Quantity Float units
    }


size : Quantity Float units -> Quantity Float units -> Size units
size width height =
    Size width height


setHeight : Quantity Float units -> Size units -> Size units
setHeight height old =
    { old | height = height }


setWidth : Quantity Float units -> Size units -> Size units
setWidth width old =
    { old | width = width }


scale : Float -> Size units -> Size units
scale ammount from =
    size
        (Quantity.multiplyBy ammount from.width)
        (Quantity.multiplyBy ammount from.height)
