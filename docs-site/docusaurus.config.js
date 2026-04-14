// @ts-check

import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Zegoweb',
  tagline: 'Flutter web plugins for ZEGOCLOUD video SDK',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://creative-blaq-studios.github.io',
  baseUrl: '/zegoweb/',
  organizationName: 'Creative-Blaq-Studios',
  projectName: 'zegoweb',
  onBrokenLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          routeBasePath: '/',
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/Creative-Blaq-Studios/zegoweb/tree/main/docs-site/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'Zegoweb',
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'docs',
            position: 'left',
            label: 'Docs',
          },
          {
            href: '/api/zegoweb/index.html',
            label: 'API Reference',
            position: 'left',
            target: '_blank',
          },
          {
            href: 'https://github.com/Creative-Blaq-Studios/zegoweb',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Packages',
            items: [
              {label: 'zegoweb', to: '/getting-started/installation'},
              {label: 'zegoweb_ui', to: '/guides/zegoweb-ui/call-screen'},
              {label: 'zegoweb_prebuilt', to: '/guides/zegoweb-prebuilt/prebuilt-view'},
            ],
          },
          {
            title: 'API Reference',
            items: [
              {label: 'zegoweb API', href: '/api/zegoweb/index.html'},
              {label: 'zegoweb_ui API', href: '/api/zegoweb_ui/index.html'},
              {label: 'zegoweb_prebuilt API', href: '/api/zegoweb_prebuilt/index.html'},
            ],
          },
          {
            title: 'More',
            items: [
              {label: 'GitHub', href: 'https://github.com/Creative-Blaq-Studios/zegoweb'},
              {label: 'ZEGOCLOUD', href: 'https://www.zegocloud.com'},
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} zegoweb contributors.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['dart', 'yaml', 'bash'],
      },
    }),
};

export default config;
