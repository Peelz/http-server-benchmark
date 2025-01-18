#!/bin/sh

export FORWARD_PORTOCOL=http
export FORWARD_ADDR=localhost
export FORWARD_PORT=9000

go run main.go
