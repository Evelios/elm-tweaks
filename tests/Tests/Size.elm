module Tests.Size exposing (..)

import AspectRatio
import Expect
import Pixels
import Size
import Test exposing (Test, describe, test)


scale : Test
scale =
    test "Positive" <|
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


asAspectRatio : Test
asAspectRatio =
    describe "asAspectRatio"
        [ test "Aspect ratio from portrait size" <|
            \_ ->
                let
                    size =
                        Size.size (Pixels.pixels 100) (Pixels.pixels 150)

                    aspectRatio =
                        AspectRatio.aspectRatio 1 1.5
                in
                Size.aspectRatio size
                    |> Expect.equal aspectRatio
        , test "Aspect ratio from landscape size" <|
            \_ ->
                let
                    size =
                        Size.size (Pixels.pixels 150) (Pixels.pixels 100)

                    aspectRatio =
                        AspectRatio.aspectRatio 1.5 1
                in
                Size.aspectRatio size
                    |> Expect.equal aspectRatio
        ]


shrinkToAspectRatio : Test
shrinkToAspectRatio =
    describe "shrinkToAspectRatio"
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
                Size.shrinkToAspectRatio aspectRatio size
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
                Size.shrinkToAspectRatio aspectRatio size
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
                Size.shrinkToAspectRatio aspectRatio size
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
                Size.shrinkToAspectRatio aspectRatio size
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
                Size.shrinkToAspectRatio aspectRatio size
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
                Size.shrinkToAspectRatio aspectRatio size
                    |> Expect.equal expected
        ]
