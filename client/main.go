package client

import (
	"fmt"
	"net/http"
	"os"
	"pgrok/log"
	"runtime"
	"time"

	"github.com/inconshreveable/mousetrap"

	_ "net/http/pprof"
)

// debug memory profiler $ go tool pprof http://localhost:6060/debug/pprof/heap
func pprof() {
	go func() {
		http.ListenAndServe("localhost:6060", nil)
	}()
}

func init() {
	if runtime.GOOS == "windows" {
		if mousetrap.StartedByExplorer() {
			fmt.Println("Don't double-click pgrok!")
			fmt.Println("You need to open cmd.exe and run it from the command line!")
			time.Sleep(5 * time.Second)
			os.Exit(1)
		}
	}
}

func Main() {
	//run profiler
	//pprof()

	// parse options
	opts, err := ParseArgs()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// set up logging
	log.LogTo(opts.logto, opts.loglevel)

	// read configuration file
	config, err := LoadConfiguration(opts)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	NewController().Run(config)
}
