import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import federation from "@originjs/vite-plugin-federation";
import topLevelAwait from "vite-plugin-top-level-await";
import packageJson from "./package.json";
const { name } = packageJson;

// Servidor: same shape as npwd_qbx_garages (already installed, proven to work against this
// server's npwd 3.14.3-beta.0) - the exposed "./config" module is what npwd's core dynamically
// imports at runtime, matching the "apps" entry it's given in npwd's own config.json.
export default defineConfig({
  plugins: [
    react(),
    federation({
      name: name,
      filename: "remoteEntry.js",
      exposes: {
        "./config": "./npwd.config.ts",
      },
      shared: [
        "react",
        "react-dom",
        "@emotion/react",
        "react-router-dom",
      ],
    }),
    // Servidor: vite-plugin-federation's shared-import runtime uses top-level await
    // (`await importShared(...)`), which esbuild refuses to transpile for the default target
    // environments without this plugin - matches npwd_qbx_garages's own vite.config.ts.
    topLevelAwait({
      promiseExportName: "__tla",
      promiseImportName: (i) => `__tla_${i}`,
    }),
  ],
  server: {
    port: 3003,
  },
  build: {
    outDir: "web/dist",
    emptyOutDir: true,
    modulePreload: false,
    assetsDir: '',
  },
});
