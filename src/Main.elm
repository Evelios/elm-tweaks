module Main exposing (main)

import Generative
import Picture


main : Program () Generative.Model Generative.Msg
main =
    Generative.random Picture.drawing
