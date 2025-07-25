package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/tobiashort/worker"
)

var tools = []string{
	"append",
	"append-nl",
	"base64",
	"cidr-to-mask",
	"ciphersuite-checker",
	"cols",
	"cutnstitch",
	"ellipsis",
	"ends-with",
	"file-transfer-over-powershell",
	"files-by-ext",
	"from-hex",
	"garlic",
	"git-cleaner",
	"html-decode",
	"html-encode",
	"ip-sort",
	"json-fmt",
	"jwk-rsa-to-der",
	"jwt-decode",
	"jwt-encode",
	"len-sort",
	"mask-to-cidr",
	"pipe-sum",
	"ports-to-port-ranges",
	"prepend",
	"rand-string",
	"raw-deflate",
	"raw-inflate",
	"rfc33392unixtime",
	"riplace",
	"replace-all",
	"starts-with",
	"subnet-to-list",
	"uniqplot",
	"unixtime2rfc3339",
	"url-encode-all",
	"url-path-decode",
	"url-path-encode",
	"url-query-decode",
	"url-query-encode",
}

var homeDir = must2(os.UserHomeDir())
var installDir = filepath.Join(homeDir, ".th-tools")
var binDir = filepath.Join(installDir, "bin")

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func must2[T any](val T, err error) T {
	must(err)
	return val
}

func installTool(tool string) error {
	toolDir := filepath.Join(installDir, tool)

	repo := fmt.Sprintf("https://github.com/tobiashort/%s", tool)

	cmd := exec.Command("git", "clone", repo)
	cmd.Dir = installDir
	out, err := cmd.CombinedOutput()
	if err != nil {
		return errors.New(string(out))
	}

	cmd = exec.Command("go", "run", "./build")
	cmd.Dir = toolDir
	out, err = cmd.CombinedOutput()
	if err != nil {
		return errors.New(string(out))
	}

	bin := filepath.Join(toolDir, "build", tool)
	err = os.Symlink(bin, filepath.Join(binDir, "th-"+tool))
	if err != nil {
		return err
	}

	return nil
}

func main() {
	must(os.RemoveAll(installDir))
	must(os.MkdirAll(binDir, 0755))

	pool := worker.NewPool(5)
	var hasErrors bool
	for _, tool := range tools {
		worker := pool.GetWorker()
		worker.Printf(tool)
		go func() {
			err := installTool(tool)
			if err == nil {
				worker.Logf("[#g{DONE}] %s", tool)
			} else {
				hasErrors = true
				worker.Logf("[#r{ERROR}] %s", tool)
				worker.Logf("%v", err)
			}
			worker.Done()
		}()
	}
	pool.Wait()
	if hasErrors {
		fmt.Println("Oh no! Some tools were not installed successfully.")
		fmt.Println("Check the logs for additional details")

	} else {
		fmt.Println("Great news! All tools have been installed successfully.")
		fmt.Printf("Be sure to include '%s' in your PATH variable.\n", binDir)
	}
}
