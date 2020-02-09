module Palette exposing (colors, padding, sizing, spacing)

import Element exposing (rgb255)


colors =
    { background =
        { default = rgb255 20 20 20
        , accent = rgb255 65 65 65
        , light = rgb255 57 57 57
        }
    , backgroundDark = rgb255 20 20 20
    , backgroundDarkAccent = rgb255 32 32 32
    , backgroundLight = rgb255 57 57 57
    , backgroundAccent = rgb255 65 65 65
    , foreground = rgb255 255 215 170
    , foregroundAccent = rgb255 213 162 106
    , yellow = rgb255 170 117 57
    , red = rgb255 162 54 69
    , blue = rgb255 39 86 107
    , green = rgb255 71 144 48
    , white = rgb255 255 255 255
    , black = rgb255 0 0 0
    }


padding =
    { default = 20
    }


spacing =
    { default = 20
    }


sizing =
    { xlarge = Element.px 160
    , large = Element.px 80
    , default = Element.px 40
    , xsmall = Element.px 20
    }
