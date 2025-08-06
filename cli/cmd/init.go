package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

var initCmd = &cobra.Command{
	Use:   "init [project-name]",
	Short: "Initialize a new Glossia project",
	Long: `Initialize a new Glossia project with the basic configuration files
and directory structure needed for managing translations.`,
	Args: cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		projectName := "glossia-project"
		if len(args) > 0 {
			projectName = args[0]
		}

		fmt.Printf("Initializing Glossia project: %s\n", projectName)

		// Create project directory if it doesn't exist
		if err := os.MkdirAll(projectName, 0755); err != nil {
			fmt.Fprintf(os.Stderr, "Error creating project directory: %v\n", err)
			return
		}

		// Create basic configuration file
		configPath := filepath.Join(projectName, "glossia.yaml")
		configContent := `# Glossia Configuration
name: ` + projectName + `
version: "1.0.0"

# Source directories to scan for translation keys
sources:
  - "src"
  - "lib"

# Output directory for translation files
output: "locales"

# Supported languages
languages:
  - "en"
  - "es"
  - "fr"
  - "de"

# File format for translation files (json, yaml, po)
format: "json"
`

		if err := os.WriteFile(configPath, []byte(configContent), 0644); err != nil {
			fmt.Fprintf(os.Stderr, "Error creating config file: %v\n", err)
			return
		}

		// Create locales directory
		localesDir := filepath.Join(projectName, "locales")
		if err := os.MkdirAll(localesDir, 0755); err != nil {
			fmt.Fprintf(os.Stderr, "Error creating locales directory: %v\n", err)
			return
		}

		fmt.Printf("✓ Created project directory: %s\n", projectName)
		fmt.Printf("✓ Created configuration file: %s\n", configPath)
		fmt.Printf("✓ Created locales directory: %s\n", localesDir)
		fmt.Println("\nNext steps:")
		fmt.Printf("  cd %s\n", projectName)
		fmt.Println("  glossia extract  # Extract translation keys from source code")
		fmt.Println("  glossia generate # Generate translation files")
	},
}

func init() {
	rootCmd.AddCommand(initCmd)
}
