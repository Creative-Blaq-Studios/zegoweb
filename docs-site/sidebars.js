/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docs: [
    'introduction',
    {
      type: 'category',
      label: 'Getting Started',
      items: [
        'getting-started/prerequisites',
        'getting-started/installation',
        'getting-started/quick-start',
      ],
    },
    {
      type: 'category',
      label: 'Architecture',
      items: [
        'architecture/package-relationships',
        'architecture/js-interop-bridge',
        'architecture/key-concepts',
      ],
    },
    {
      type: 'category',
      label: 'Guides',
      items: [
        {
          type: 'category',
          label: 'zegoweb (Core)',
          items: [
            'guides/zegoweb/room-stream-lifecycle',
            'guides/zegoweb/device-management',
            'guides/zegoweb/token-handling',
            'guides/zegoweb/event-streams',
            'guides/zegoweb/error-handling',
          ],
        },
        {
          type: 'category',
          label: 'zegoweb_ui (Flutter UI)',
          items: [
            'guides/zegoweb-ui/call-screen',
            'guides/zegoweb-ui/layouts',
            'guides/zegoweb-ui/theming',
            'guides/zegoweb-ui/pre-join-view',
            'guides/zegoweb-ui/controls-bar',
          ],
        },
        {
          type: 'category',
          label: 'zegoweb_prebuilt (UIKit)',
          items: [
            'guides/zegoweb-prebuilt/prebuilt-view',
            'guides/zegoweb-prebuilt/configuration',
            'guides/zegoweb-prebuilt/events',
          ],
        },
      ],
    },
    'troubleshooting',
    'contributing',
  ],
};

export default sidebars;
