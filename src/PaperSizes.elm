module PaperSizes exposing (Orientation(Landscape, Portrait), a0, a1, a2, a3, a4)

{-| This library contains a bunch of standard paper format sizes. These
paper sizes are all given according to the orientation of the paper,
either Landscape or Portrait. The paper sizes are given using the units
module so the sizes are independant of any unit system and can be
translated into any unit system you would like.
-}

import Length exposing (Length)
import Quantity
import Size exposing (Size)


type Orientation
    = Landscape
    | Portrait


a0 : Size Meters
a0 =
    inOrientation (Length.millimeters 841) (Length.millimeters 1189)


a1 : Size Meters
a1 =
    inOrientation (Length.millimeters 594) (Length.millimeters 841)


a2 : Size Meters
a2 =
    inOrientation (Length.millimeters 420) (Length.millimeters 594)


a3 : Size Meters
a3 =
    inOrientation (Length.millimeters 297) (Length.millimeters 420)


a4 : Size Meters
a4 =
    inOrientation (Length.millimeters 210) (Length.millimeters 297)


letter : Size Meters
letter =
    inOrientation (Length.inches 8.5) (Length.inches 11)


inOrientation : Orientation -> Length -> Length
inOrientation orientation a b =
    let
        larger =
            Quantity.max a b

        smaller =
            Quantity.min a b
    in
    case orientation of
        Landscape ->
            Size.size larger smaller

        Portrait ->
            Size.size smaller larger
