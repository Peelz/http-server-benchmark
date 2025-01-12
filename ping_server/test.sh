#! /bin/sh

gleam deps download
gleam test
gleam format --check src test
