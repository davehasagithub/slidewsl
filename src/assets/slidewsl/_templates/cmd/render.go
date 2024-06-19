package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

func main() {
	envFilePath := flag.String("env-file", "", "Path to the .env file")
	environment := flag.String("environment", "local", "Environment (e.g., local, build, staging, prod)")
	workspacePath := flag.String("workspace-path", "", "Path to the workspace")

	flag.Parse()

	if *envFilePath == "" || *environment == "" || *workspacePath == "" {
		fmt.Println("Usage: go run render.go --env-file ~/path/to/some.env --environment local --workspace-path ~/path/to/workspace")
		return
	}

	envMap, err := LoadEnv(*envFilePath)
	if err != nil {
		fmt.Printf("Error loading .env file: %v\n", err)
		return
	}
	//fmt.Println("Loaded environment variables:", envMap)

	envMap["ENVIRONMENT"] = *environment

	if stringInSlice(*environment, []string{"local", "build"}) {
		envMap["INCLUDE_BUILD"] = "true"
		if stringInSlice(*environment, []string{"build"}) {
			envMap["FOR_DEPLOYMENT"] = "true"
		}
	} else {
		envMap["FOR_DEPLOYMENT"] = "true"
	}

	templ := template.New("main")
	funcMap := template.FuncMap{
		"merge": merge,
		"dict": func(initial map[string]string, values ...interface{}) (map[string]string, error) {
			return dict(templ, initial, envMap, values...)
		},
		"varOrValue": func(key string, fixedValue string, defaultValue string) string {
			return varOrValue(*environment, key, fixedValue, defaultValue)
		},
	}

	outputFile := generateOutputFilename(*environment, "compose")
	commandString := fmt.Sprintf("go run render.go --env-file %s --environment %s --workspace-path %s", *envFilePath, *environment, *workspacePath)
	fmt.Printf("\nRendering %s.\n", outputFile)

	tmpl, err := templ.Funcs(funcMap).ParseFiles(getAllTemplates(*workspacePath)...)
	if err != nil {
		fmt.Printf("Error parsing templates: %v\n", err)
		return
	}

	err = processTemplate(tmpl, *workspacePath, "compose", outputFile, envMap, commandString)
	if err != nil {
		fmt.Printf("Error processing template: %v\n", err)
		return
	}

	fmt.Printf("Rendered successfully.\n\n")
}

// LoadEnv reads a .env file and sets the environment variables.
func LoadEnv(filePath string) (map[string]string, error) {
	envMap := make(map[string]string)
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer closeFile(file)

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}
		key := parts[0]
		value := parts[1]
		envMap[key] = value
		err := os.Setenv(key, value)
		if err != nil {
			return nil, err
		}
	}

	return envMap, scanner.Err()
}

func generateOutputFilename(environment string, base string) string {
	var outputFile = base + ".yaml"
	//if environment != "local" {
	outputFile = base + "." + environment + ".yaml"
	return outputFile
}

func getAllTemplates(workspacePath string) []string {
	templateDir := filepath.Join(workspacePath, "_templates")
	var templateFiles []string
	err := filepath.Walk(templateDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && filepath.Ext(path) == ".goyaml" {
			templateFiles = append(templateFiles, path)
		}
		return nil
	})
	if err != nil {
		fmt.Printf("Error walking through template files: %v\n", err)
		return nil
	}
	fmt.Printf("Found %d templates.\n", len(templateFiles))
	return templateFiles
}

func closeFile(file *os.File) {
	if err := file.Close(); err != nil {
		fmt.Println("Error closing file:", err)
	}
}

func processTemplate(tmpl *template.Template, workspacePath, templateName, outputFileName string, envMap map[string]string, commandString string) error {
	outputPath := filepath.Join(workspacePath, outputFileName)
	outputFile, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer closeFile(outputFile)

	// Write the auto-generated comment
	_, err = outputFile.WriteString(fmt.Sprintf("# This file is auto-generated. Any changes made to this file will be lost.\n# Generated with the command: %s\n\n", commandString))
	if err != nil {
		return err
	}

	err = tmpl.ExecuteTemplate(outputFile, templateName, envMap)
	if err != nil {
		return err
	}

	return nil
}

// Merge original data with additional values
func merge(data map[string]string, additional map[string]string) map[string]string {
	merged := make(map[string]string)
	for k, v := range data {
		merged[k] = v
	}
	for k, v := range additional {
		merged[k] = v
	}
	return merged
}

// Dict creates a map from a list of key-value pairs with interpolation.
func dict(tmpl *template.Template, dict map[string]string, data map[string]string, values ...interface{}) (map[string]string, error) {
	if len(values)%2 != 0 {
		return nil, fmt.Errorf("invalid dict call, odd number of arguments")
	}
	for i := 0; i < len(values); i += 2 {
		key, ok := values[i].(string)
		if !ok {
			return nil, fmt.Errorf("dict keys must be strings")
		}
		tmplStr, ok := values[i+1].(string)
		if !ok {
			return nil, fmt.Errorf("dict values must be strings")
		}

		// Interpolate template string
		var buf bytes.Buffer
		tmpl, err := tmpl.Clone()
		if err != nil {
			return nil, err
		}
		tmpl, err = tmpl.Parse(tmplStr)
		if err != nil {
			return nil, err
		}
		err = tmpl.Execute(&buf, data)
		if err != nil {
			return nil, err
		}

		dict[key] = buf.String()
	}
	return dict, nil
}

// VarOrValue returns an environment variable value if the environment is "local", otherwise returns the fixed value.
func varOrValue(env string, key string, fixedValue string, defaultValue string) string {
	if env == "local" {
		if defaultValue != "" {
			return fmt.Sprintf("${%s:-%s}", key, defaultValue)
		}
		return fmt.Sprintf("${%s}", key)
	}
	return fixedValue
}

func stringInSlice(str string, list []string) bool {
	for _, v := range list {
		if v == str {
			return true
		}
	}
	return false
}
