package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var version = "dev"

var rootCmd = &cobra.Command{
	Use:   "glossia",
	Short: "Glossia CLI - A modern language hub for your organization",
	Long: `Glossia CLI is a command-line interface for managing translations and language resources
in your organization. It provides tools for extracting, managing, and distributing
translation files across your projects.`,
	Version: version,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Welcome to Glossia CLI!")
		fmt.Println("Use 'glossia --help' to see available commands.")
	},
}

func Execute() error {
	return rootCmd.Execute()
}

func init() {
	rootCmd.SetVersionTemplate("Glossia CLI version {{.Version}}\n")
}
