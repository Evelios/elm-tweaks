.PHONY: test dev

sources := src/*

elm.js: $(sources)
	elm make src/Main.elm --output elm.js

dev:
	elm-live src/Main.elm --open -- --output=elm.js

test:
	elm-test
