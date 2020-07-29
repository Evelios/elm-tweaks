module Main exposing (main)

import AspectRatio exposing (AspectRatio)
import Collage exposing (Collage)
import Color
import Generative
import Picture


main : Program () Generative.Model Generative.Msg
main =
    Generative.static picture


picture : AspectRatio -> Collage msg
picture _ =
    Collage.circle 1
        |> Collage.filled (Collage.uniform (Color.rgb255 195 169 222))
