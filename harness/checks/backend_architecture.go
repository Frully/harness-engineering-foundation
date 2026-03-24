package main

import (
	"encoding/json"
	"fmt"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"strings"
)

type policy struct {
	Backend struct {
		Layers           map[string][]string   `json:"layers"`
		ForbiddenImports map[string][]string   `json:"forbiddenImports"`
	} `json:"backend"`
}

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintln(os.Stderr, "usage: backend_architecture <root> <policy>")
		os.Exit(1)
	}

	root := os.Args[1]
	policyPath := os.Args[2]

	data, err := os.ReadFile(policyPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "read policy: %v\n", err)
		os.Exit(1)
	}

	var cfg policy
	if err := json.Unmarshal(data, &cfg); err != nil {
		fmt.Fprintf(os.Stderr, "parse policy: %v\n", err)
		os.Exit(1)
	}

	goMod, err := os.ReadFile(filepath.Join(root, "workspace/backend/go.mod"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "read go.mod: %v\n", err)
		os.Exit(1)
	}
	modulePath := ""
	for _, line := range strings.Split(string(goMod), "\n") {
		if strings.HasPrefix(line, "module ") {
			modulePath = strings.TrimSpace(strings.TrimPrefix(line, "module "))
			break
		}
	}
	if modulePath == "" {
		fmt.Fprintln(os.Stderr, "backend module path not found in go.mod")
		os.Exit(1)
	}

	var errors []string
	fileSet := token.NewFileSet()
	sourceRoot := filepath.Join(root, "workspace/backend")

	err = filepath.WalkDir(sourceRoot, func(path string, entry os.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if entry.IsDir() || !strings.HasSuffix(path, ".go") || strings.HasSuffix(path, "_test.go") {
			return nil
		}

		relative, err := filepath.Rel(sourceRoot, path)
		if err != nil {
			return err
		}

		layer := strings.Split(relative, string(os.PathSeparator))[0]
		allowedLayers, tracked := cfg.Backend.Layers[layer]
		if !tracked {
			return nil
		}

		fileNode, err := parser.ParseFile(fileSet, path, nil, parser.ImportsOnly)
		if err != nil {
			errors = append(errors, fmt.Sprintf("%s: parse error: %v", relative, err))
			return nil
		}

		for _, importSpec := range fileNode.Imports {
			importPath := strings.Trim(importSpec.Path.Value, "\"")
			if importsForbidden(importPath, cfg.Backend.ForbiddenImports[layer]) {
				errors = append(errors, fmt.Sprintf("%s imports forbidden package %s", relative, importPath))
			}

			if !strings.HasPrefix(importPath, modulePath+"/") {
				continue
			}

			targetRelative := strings.TrimPrefix(importPath, modulePath+"/")
			targetLayer := strings.Split(targetRelative, "/")[0]
			if targetLayer == layer {
				continue
			}
			if !contains(allowedLayers, targetLayer) {
				errors = append(errors, fmt.Sprintf("%s (%s) imports disallowed backend layer %s", relative, layer, targetLayer))
			}
		}

		return nil
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "walk backend: %v\n", err)
		os.Exit(1)
	}

	if len(errors) > 0 {
		for _, message := range errors {
			fmt.Fprintln(os.Stderr, message)
		}
		os.Exit(1)
	}
}

func contains(values []string, target string) bool {
	for _, value := range values {
		if value == target {
			return true
		}
	}
	return false
}

func importsForbidden(importPath string, forbidden []string) bool {
	for _, target := range forbidden {
		if importPath == target || strings.Contains(importPath, target) {
			return true
		}
	}
	return false
}
