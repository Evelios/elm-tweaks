module Palette exposing (colors, padding, sizing, spacing)

import Element


colors =
    { gray = Element.rgb255 48 48 48
    , grayLight = Element.rgb255 57 57 57
    , yellow = Element.rgb255 170 117 57
    , red = Element.rgb255 162 54 69
    , blue = Element.rgb255 39 86 107
    , green = Element.rgb255 71 144 48
    }


padding =
    { default = 20
    }


spacing =
    { default = 20
    }


sizing =
    { xlarge = 40
    , large = 20
    , default = 10
    , xsmall = 5
    }
