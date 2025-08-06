import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Glossia",
  description: "A modern language hub for your organization",
  srcDir: './docs',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Documentation', link: '/index' }
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'What is Glossia?', link: '/index' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/pepicrft/glossia' }
    ]
  }
})
