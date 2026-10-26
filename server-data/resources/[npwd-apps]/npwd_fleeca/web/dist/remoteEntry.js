let m, T, j;
let __tla = (async () => {
  const g = {}, E = /* @__PURE__ */ new Set([
    "Module",
    "__esModule",
    "default",
    "_export_sfc"
  ]);
  let p = {
    "./config": () => (m([], false, "./config"), y("./__federation_expose_Config-C7ZirGTj.js").then((e) => Object.keys(e).every((o) => E.has(o)) ? () => e.default : () => e))
  };
  let w;
  w = {};
  m = (e, o, l) => {
    const r = import.meta.url;
    if (typeof r > "u") {
      console.warn('The remote style takes effect only when the build.target option in the vite.config.ts file is higher than that of "es2020".');
      return;
    }
    const i = r.substring(0, r.lastIndexOf("remoteEntry.js")), _ = "/";
    "", e.forEach((a) => {
      let n = "";
      const c = _ || i;
      if (c) {
        const s = {
          trailing: (t) => t.endsWith("/") ? t.slice(0, -1) : t,
          leading: (t) => t.startsWith("/") ? t.slice(1) : t
        }, b = (t) => t.startsWith("http") || t.startsWith("//"), d = s.trailing(c), h = s.leading(a), u = s.trailing(i);
        b(c) ? n = [
          d,
          h
        ].filter(Boolean).join("/") : u.includes(d) ? n = [
          u,
          h
        ].filter(Boolean).join("/") : n = [
          u + d,
          h
        ].filter(Boolean).join("/");
      } else n = a;
      if (o) {
        const s = "css__fleeca__" + l;
        window[s] = window[s] || [], window[s].push(n);
        return;
      }
      if (n in w) return;
      w[n] = true;
      const f = document.createElement("link");
      f.rel = "stylesheet", f.href = n, document.head.appendChild(f);
    });
  };
  async function y(e) {
    return g[e] ?? (g[e] = import(e).then(async (m2) => {
      await m2.__tla;
      return m2;
    })), g[e];
  }
  T = (e) => {
    if (!p[e]) throw new Error("Can not find remote module " + e);
    return p[e]();
  };
  j = (e) => {
    globalThis.__federation_shared__ = globalThis.__federation_shared__ || {}, Object.entries(e).forEach(([o, l]) => {
      for (const [r, i] of Object.entries(l)) {
        const _ = i.scope || "default";
        globalThis.__federation_shared__[_] = globalThis.__federation_shared__[_] || {};
        const a = globalThis.__federation_shared__[_];
        (a[o] = a[o] || {})[r] = i;
      }
    });
  };
})();
export {
  __tla,
  m as dynamicLoadingCss,
  T as get,
  j as init
};
