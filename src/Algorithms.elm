module Algorithms exposing (poisson)

import BoundingBox2d exposing (BoundingBox2d)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity)
import Random


{-| Sample a bunch of points within the bounding box that should all be at least
a certain distance apart from eachother. The group of points in the end
should represent a poisson distribution. Some ordered chaos which represents
a blue noise distribution instead of a typical random white noise
distribution.
-}
poisson : Quantity Float units -> BoundingBox2d units coordinates -> List (Random.Generator (Point2d units coordinates))
poisson distance bbox =
    [ randomPoint bbox ]


randomPoint : BoundingBox2d units coordinates -> Random.Generator (Point2d units coordintates)
randomPoint bbox =
    let
        { minX, maxX, minY, maxY } =
            BoundingBox2d.extrema bbox
    in
    Random.map2
        Point2d.xy
        (randomQuantity minX maxX)
        (randomQuantity minY maxY)


randomQuantity : Quantity Float units -> Quantity Float units -> Random.Generator (Quantity Float units)
randomQuantity from to =
    Random.map
        (Quantity.interpolateFrom from to)
        (Random.float 0 1)
