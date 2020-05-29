module AspectRatio exposing
    ( AspectRatio
    , aspectRatio
    , x
    , y
    )


type AspectRatio
    = AspectRatio Float Float


aspectRatio : Float -> Float -> AspectRatio
aspectRatio xin yin =
    let
        normalize =
            min xin yin
    in
    AspectRatio (xin / normalize) (yin / normalize)


x : AspectRatio -> Float
x (AspectRatio xVal _) =
    xVal


y : AspectRatio -> Float
y (AspectRatio _ yVal) =
    yVal
