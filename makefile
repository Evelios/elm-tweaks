.PHONY: test dev

sources := src/*
tests := tests/*

deploy: elm.js

dev:
	elm-live src/Main.elm --open -- --output=elm.js

test: $(tests)
	elm-test

elm.js: $(sources)
	elm make src/Main.elm --output elm.js
