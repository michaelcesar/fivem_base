import { _ as b } from "./preload-helper-a4192956.js";
let y, v, j;
let __tla = (async () => {
  const p = {}, w = /* @__PURE__ */ new Set([
    "Module",
    "__esModule",
    "default",
    "_export_sfc"
  ]);
  let m = {
    "./Input": () => (y([], false, "./Input"), I("./assets/__federation_expose_Input-3de07060.js").then((e) => Object.keys(e).every((o) => w.has(o)) ? () => e.default : () => e))
  };
  let g;
  g = {};
  y = (e, o, a) => {
    const r = import.meta.url;
    if (typeof r > "u") {
      console.warn('The remote style takes effect only when the build.target option in the vite.config.ts file is higher than that of "es2020".');
      return;
    }
    const i = r.substring(0, r.lastIndexOf("remoteEntry.js")), _ = "./";
    "assets", e.forEach((l) => {
      let n = "";
      const c = _ || i;
      if (c) {
        const s = {
          trailing: (t) => t.endsWith("/") ? t.slice(0, -1) : t,
          leading: (t) => t.startsWith("/") ? t.slice(1) : t
        }, E = (t) => t.startsWith("http") || t.startsWith("//"), f = s.trailing(c), h = s.leading(l), u = s.trailing(i);
        E(c) ? n = [
          f,
          h
        ].filter(Boolean).join("/") : u.includes(f) ? n = [
          u,
          h
        ].filter(Boolean).join("/") : n = [
          u + f,
          h
        ].filter(Boolean).join("/");
      } else
        n = l;
      if (o) {
        const s = "css__undefined__" + a;
        window[s] = window[s] || [], window[s].push(n);
        return;
      }
      if (n in g)
        return;
      g[n] = true;
      const d = document.createElement("link");
      d.rel = "stylesheet", d.href = n, document.head.appendChild(d);
    });
  };
  async function I(e) {
    return p[e] ?? (p[e] = b(() => import(e).then(async (m2) => {
      await m2.__tla;
      return m2;
    }), [], import.meta.url)), p[e];
  }
  v = (e) => {
    if (!m[e])
      throw new Error("Can not find remote module " + e);
    return m[e]();
  };
  j = (e) => {
    globalThis.__federation_shared__ = globalThis.__federation_shared__ || {}, Object.entries(e).forEach(([o, a]) => {
      for (const [r, i] of Object.entries(a)) {
        const _ = i.scope || "default";
        globalThis.__federation_shared__[_] = globalThis.__federation_shared__[_] || {};
        const l = globalThis.__federation_shared__[_];
        (l[o] = l[o] || {})[r] = i;
      }
    });
  };
})();
export {
  __tla,
  y as dynamicLoadingCss,
  v as get,
  j as init
};
