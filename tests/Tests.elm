module Tests exposing (suite)

import AspectRatio
import Expect
import Length
import Pixels
import Size
import Test exposing (..)


suite : Test
suite =
    describe "Size module"
        [ describe "scale"
            [ test "Positive" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 100) (Pixels.pixels 200)

                        expected =
                            Size.size (Pixels.pixels 200) (Pixels.pixels 400)

                        actual =
                            Size.scale 2 size
                    in
                    Expect.equal expected actual
            ]
        , describe "asAspectRatio"
            [ test "Aspect ratio from portrait size" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 100) (Pixels.pixels 150)

                        aspectRatio =
                            AspectRatio.aspectRatio 1 1.5
                    in
                    AspectRatio.fromSize size
                        |> Expect.equal aspectRatio
            , test "Aspect ratio from landscape size" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 150) (Pixels.pixels 100)

                        aspectRatio =
                            AspectRatio.aspectRatio 1.5 1
                    in
                    AspectRatio.fromSize size
                        |> Expect.equal aspectRatio
            ]
        , describe "inAspectRatio"
            [ test "Portrait from square" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 200) (Pixels.pixels 200)

                        aspectRatio =
                            AspectRatio.aspectRatio 1 2

                        expected =
                            Size.size (Pixels.pixels 100) (Pixels.pixels 200)
                    in
                    AspectRatio.inAspectRatio aspectRatio size
                        |> Expect.equal expected
            , test "Landscape from square" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 200) (Pixels.pixels 200)

                        aspectRatio =
                            AspectRatio.aspectRatio 2 1

                        expected =
                            Size.size (Pixels.pixels 200) (Pixels.pixels 100)
                    in
                    AspectRatio.inAspectRatio aspectRatio size
                        |> Expect.equal expected
            , test "Landscape to portrait" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 200) (Pixels.pixels 100)

                        aspectRatio =
                            AspectRatio.aspectRatio 1 2

                        expected =
                            Size.size (Pixels.pixels 50) (Pixels.pixels 100)
                    in
                    AspectRatio.inAspectRatio aspectRatio size
                        |> Expect.equal expected
            , test "Portrait to landscape" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 100) (Pixels.pixels 200)

                        aspectRatio =
                            AspectRatio.aspectRatio 2 1

                        expected =
                            Size.size (Pixels.pixels 100) (Pixels.pixels 50)
                    in
                    AspectRatio.inAspectRatio aspectRatio size
                        |> Expect.equal expected
            , test "Non-normalized aspect ratio portrait to landscape" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 300) (Pixels.pixels 400)

                        aspectRatio =
                            AspectRatio.aspectRatio 3 2

                        expected =
                            Size.size (Pixels.pixels 300) (Pixels.pixels 200)
                    in
                    AspectRatio.inAspectRatio aspectRatio size
                        |> Expect.equal expected
            , test "Non-normalized aspect ratio landscape to portrait" <|
                \_ ->
                    let
                        size =
                            Size.size (Pixels.pixels 400) (Pixels.pixels 300)

                        aspectRatio =
                            AspectRatio.aspectRatio 2 3

                        expected =
                            Size.size (Pixels.pixels 200) (Pixels.pixels 300)
                    in
                    AspectRatio.inAspectRatio aspectRatio size
                        |> Expect.equal expected
            ]
        ]
