package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
)

const PROXY_VERSION = "1.0.0-rc1"

func handle(p *httputil.ReverseProxy, remote *url.URL) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Println(r.URL)
		r.Host = remote.Host
		w.Header().Set("Tdh-Analytic-Proxy", PROXY_VERSION)
		p.ServeHTTP(w, r)
	}
}

func main() {
	listenPort := os.Getenv("LISTEN_PORT")
	forwardProtocol := os.Getenv("FORWARD_PORTOCOL")
	forwardAddr := os.Getenv("FORWARD_ADDR")
	forwardPort := os.Getenv("FORWARD_PORT")

	remote, err := url.Parse(fmt.Sprintf("%v://%v:%v", forwardProtocol, forwardAddr, forwardPort))
	log.Printf("Forwarding to %v\n", remote)
	if err != nil {
		panic(err)
	}

	proxy := httputil.NewSingleHostReverseProxy(remote)
	http.HandleFunc("/", handle(proxy, remote))
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%v", listenPort), nil))
}
