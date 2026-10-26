let Te, be, ge;
let __tla = (async () => {
  const S = "[0-9A-Za-z-]+", C = `(?:\\+(${S}(?:\\.${S})*))`, _ = "0|[1-9]\\d*", v = "[0-9]+", k = "\\d*[a-zA-Z-][a-zA-Z0-9-]*", X = `(?:${v}|${k})`, D = `(?:-?(${X}(?:\\.${X})*))`, E = `(?:${_}|${k})`, F = `(?:-(${E}(?:\\.${E})*))`, T = `${_}|x|X|\\*`, d = `[v=\\s]*(${T})(?:\\.(${T})(?:\\.(${T})(?:${F})?${C}?)?)?`, J = `^\\s*(${d})\\s+-\\s+(${d})\\s*$`, Q = `(${v})\\.(${v})\\.(${v})`, W = `[v=\\s]*${Q}${D}?${C}?`, L = "((?:<|>)?=?)", Y = `(\\s*)${L}\\s*(${W}|${d})`, K = "(?:~>?)", j = `(\\s*)${K}\\s+`, B = "(?:\\^)", A = `(\\s*)${B}\\s+`, m = "(<|>)?=?\\s*\\*", ee = `^${B}${d}$`, re = `(${_})\\.(${_})\\.(${_})`, te = `v?${re}${F}?${C}?`, ne = `^${K}${d}$`, se = `^${L}\\s*${d}$`, ie = `^${L}\\s*(${te})$|^$`, ue = "^\\s*>=\\s*0.0.0\\s*$";
  function l(e) {
    return new RegExp(e);
  }
  function c(e) {
    return !e || e.toLowerCase() === "x" || e === "*";
  }
  function G(...e) {
    return (n) => e.reduce((s, r) => r(s), n);
  }
  function U(e) {
    return e.match(l(ie));
  }
  function z(e, n, s, r) {
    const t = `${e}.${n}.${s}`;
    return r ? `${t}-${r}` : t;
  }
  function $e(e) {
    return e.replace(l(J), (n, s, r, t, i, u, $, a, f, o, R, p) => (c(r) ? s = "" : c(t) ? s = `>=${r}.0.0` : c(i) ? s = `>=${r}.${t}.0` : s = `>=${s}`, c(f) ? a = "" : c(o) ? a = `<${+f + 1}.0.0-0` : c(R) ? a = `<${f}.${+o + 1}.0-0` : p ? a = `<=${f}.${o}.${R}-${p}` : a = `<=${a}`, `${s} ${a}`.trim()));
  }
  function ce(e) {
    return e.replace(l(Y), "$1$2$3");
  }
  function ae(e) {
    return e.replace(l(j), "$1~");
  }
  function fe(e) {
    return e.replace(l(A), "$1^");
  }
  function oe(e) {
    return e.trim().split(/\s+/).map((n) => n.replace(l(ee), (s, r, t, i, u) => c(r) ? "" : c(t) ? `>=${r}.0.0 <${+r + 1}.0.0-0` : c(i) ? r === "0" ? `>=${r}.${t}.0 <${r}.${+t + 1}.0-0` : `>=${r}.${t}.0 <${+r + 1}.0.0-0` : u ? r === "0" ? t === "0" ? `>=${r}.${t}.${i}-${u} <${r}.${t}.${+i + 1}-0` : `>=${r}.${t}.${i}-${u} <${r}.${+t + 1}.0-0` : `>=${r}.${t}.${i}-${u} <${+r + 1}.0.0-0` : r === "0" ? t === "0" ? `>=${r}.${t}.${i} <${r}.${t}.${+i + 1}-0` : `>=${r}.${t}.${i} <${r}.${+t + 1}.0-0` : `>=${r}.${t}.${i} <${+r + 1}.0.0-0`)).join(" ");
  }
  function le(e) {
    return e.trim().split(/\s+/).map((n) => n.replace(l(ne), (s, r, t, i, u) => c(r) ? "" : c(t) ? `>=${r}.0.0 <${+r + 1}.0.0-0` : c(i) ? `>=${r}.${t}.0 <${r}.${+t + 1}.0-0` : u ? `>=${r}.${t}.${i}-${u} <${r}.${+t + 1}.0-0` : `>=${r}.${t}.${i} <${r}.${+t + 1}.0-0`)).join(" ");
  }
  function pe(e) {
    return e.split(/\s+/).map((n) => n.trim().replace(l(se), (s, r, t, i, u, $) => {
      const a = c(t), f = a || c(i), o = f || c(u);
      return r === "=" && o && (r = ""), $ = "", a ? r === ">" || r === "<" ? "<0.0.0-0" : "*" : r && o ? (f && (i = 0), u = 0, r === ">" ? (r = ">=", f ? (t = +t + 1, i = 0, u = 0) : (i = +i + 1, u = 0)) : r === "<=" && (r = "<", f ? t = +t + 1 : i = +i + 1), r === "<" && ($ = "-0"), `${r + t}.${i}.${u}${$}`) : f ? `>=${t}.0.0${$} <${+t + 1}.0.0-0` : o ? `>=${t}.${i}.0${$} <${t}.${+i + 1}.0-0` : s;
    })).join(" ");
  }
  function de(e) {
    return e.trim().replace(l(m), "");
  }
  function _e(e) {
    return e.trim().replace(l(ue), "");
  }
  function w(e, n) {
    return e = +e || e, n = +n || n, e > n ? 1 : e === n ? 0 : -1;
  }
  function Re(e, n) {
    const { preRelease: s } = e, { preRelease: r } = n;
    if (s === void 0 && r) return 1;
    if (s && r === void 0) return -1;
    if (s === void 0 && r === void 0) return 0;
    for (let t = 0, i = s.length; t <= i; t++) {
      const u = s[t], $ = r[t];
      if (u !== $) return u === void 0 && $ === void 0 ? 0 : u ? $ ? w(u, $) : -1 : 1;
    }
    return 0;
  }
  function h(e, n) {
    return w(e.major, n.major) || w(e.minor, n.minor) || w(e.patch, n.patch) || Re(e, n);
  }
  function x(e, n) {
    return e.version === n.version;
  }
  function he(e, n) {
    switch (e.operator) {
      case "":
      case "=":
        return x(e, n);
      case ">":
        return h(e, n) < 0;
      case ">=":
        return x(e, n) || h(e, n) < 0;
      case "<":
        return h(e, n) > 0;
      case "<=":
        return x(e, n) || h(e, n) > 0;
      case void 0:
        return true;
      default:
        return false;
    }
  }
  function Ve(e) {
    return G(oe, le, pe, de)(e);
  }
  function ve(e) {
    return G($e, ce, ae, fe)(e.trim()).split(/\s+/).join(" ");
  }
  function we(e, n) {
    if (!e) return false;
    const t = ve(n).split(" ").map((p) => Ve(p)).join(" ").split(/\s+/).map((p) => _e(p)), i = U(e);
    if (!i) return false;
    const [, u, , $, a, f, o] = i, R = {
      version: z($, a, f, o),
      major: $,
      minor: a,
      patch: f,
      preRelease: o == null ? void 0 : o.split(".")
    };
    for (const p of t) {
      const P = U(p);
      if (!P) return false;
      const [, M, , I, O, q, b] = P, N = {
        operator: M,
        version: z(I, O, q, b),
        major: I,
        minor: O,
        patch: q,
        preRelease: b == null ? void 0 : b.split(".")
      };
      if (!he(N, R)) return false;
    }
    return true;
  }
  const Z = {}, y = {
    react: {
      get: () => () => V(new URL("__federation_shared_react-CwfWKCOn.js", import.meta.url).href),
      import: true
    },
    "react-dom": {
      get: () => () => V(new URL("__federation_shared_react-dom--E3j2-QW.js", import.meta.url).href),
      import: true
    },
    "@emotion/react": {
      get: () => () => V(new URL("__federation_shared_@emotion/react-TRvUx6FX.js", import.meta.url).href),
      import: true
    },
    "react-router-dom": {
      get: () => () => V(new URL("__federation_shared_react-router-dom-BQgw2WgZ.js", import.meta.url).href),
      import: true
    }
  }, g = /* @__PURE__ */ Object.create(null);
  Te = async function(e, n = "default") {
    return g[e] ? new Promise((s) => s(g[e])) : await ge(e, n) || be(e);
  };
  async function V(e) {
    return Z[e] ?? (Z[e] = import(e).then(async (m2) => {
      await m2.__tla;
      return m2;
    })), Z[e];
  }
  ge = async function(e, n) {
    var _a, _b, _c;
    let s = null;
    if ((_b = (_a = globalThis == null ? void 0 : globalThis.__federation_shared__) == null ? void 0 : _a[n]) == null ? void 0 : _b[e]) {
      const r = globalThis.__federation_shared__[n][e], t = (_c = y[e]) == null ? void 0 : _c.requiredVersion;
      if (!!t) {
        const u = Object.keys(r).find(($) => we($, t));
        u ? s = await (await r[u].get())() : console.log(`provider support ${e}(${u}) is not satisfied requiredVersion(\${moduleMap[name].requiredVersion})`);
      } else {
        const u = Object.keys(r)[0];
        s = await (await r[u].get())();
      }
    }
    if (s) return H(s, e);
  };
  be = async function(e) {
    var _a;
    if ((_a = y[e]) == null ? void 0 : _a.import) {
      let n = await (await y[e].get())();
      return H(n, e);
    } else console.error("consumer config import=false,so cant use callback shared module");
  };
  function H(e, n) {
    return typeof e.default == "function" ? (Object.keys(e).forEach((s) => {
      s !== "default" && (e.default[s] = e[s]);
    }), g[n] = e.default, e.default) : (e.default && (e = Object.assign({}, e.default, e)), g[n] = e, e);
  }
})();
export {
  __tla,
  Te as importShared,
  be as importSharedLocal,
  ge as importSharedRuntime
};
