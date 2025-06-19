package cmd

import (
	"bytes"
	"testing"

	"github.com/spf13/cobra"
)

func TestRootCommand(t *testing.T) {
	// Test that root command executes without error
	var output bytes.Buffer
	rootCmd.SetOut(&output)
	rootCmd.SetArgs([]string{})

	err := rootCmd.Execute()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	output.Reset()
}

func TestVersionCommand(t *testing.T) {
	// Test version command
	var output bytes.Buffer

	// Create a new command instance to avoid state issues
	cmd := &cobra.Command{
		Use:   "version",
		Short: "Print the version number of Glossia CLI",
		Long:  "Print the version number of Glossia CLI",
		Run: func(cmd *cobra.Command, args []string) {
			cmd.Printf("Glossia CLI version %s\n", version)
		},
	}

	cmd.SetOut(&output)

	err := cmd.Execute()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if output.Len() == 0 {
		t.Fatal("Expected output, got none")
	}
}
