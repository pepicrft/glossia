package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version number of Glossia CLI",
	Long:  "Print the version number of Glossia CLI",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Glossia CLI version %s\n", version)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
