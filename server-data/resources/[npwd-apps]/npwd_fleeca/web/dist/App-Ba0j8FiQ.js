import { importShared as w, __tla as __tla_0 } from "./__federation_fn_import-Bhcw9meP.js";
import { r as Po } from "./index-Dv9Q2FSt.js";
import { _ as h, a as ko } from "./hoist-non-react-statics.cjs-3wE6KoJ0.js";
import { m as Oo, g as Mo, s as Fn, r as jo, u as Bo, i as Ao, c as Io, T as Pr, a as zo, k as Bt, __tla as __tla_1 } from "./emotion-react.browser.esm-CliQl2yW.js";
import { a as Y, _ as Lo } from "./inheritsLoose-G6YR9G09.js";
import { a as Te } from "./_commonjsHelpers-C932wzq6.js";
let lu, at, To, f;
let __tla = Promise.all([
  (() => {
    try {
      return __tla_0;
    } catch {
    }
  })(),
  (() => {
    try {
      return __tla_1;
    } catch {
    }
  })()
]).then(async () => {
  var Wn = {
    exports: {}
  }, At = {};
  var Fo = Po, Wo = Symbol.for("react.element"), No = Symbol.for("react.fragment"), Do = Object.prototype.hasOwnProperty, Ho = Fo.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentOwner, Ko = {
    key: true,
    ref: true,
    __self: true,
    __source: true
  };
  function Nn(e, t, r) {
    var n, o = {}, i = null, s = null;
    r !== void 0 && (i = "" + r), t.key !== void 0 && (i = "" + t.key), t.ref !== void 0 && (s = t.ref);
    for (n in t) Do.call(t, n) && !Ko.hasOwnProperty(n) && (o[n] = t[n]);
    if (e && e.defaultProps) for (n in t = e.defaultProps, t) o[n] === void 0 && (o[n] = t[n]);
    return {
      $$typeof: Wo,
      type: e,
      key: i,
      ref: s,
      props: o,
      _owner: Ho.current
    };
  }
  At.Fragment = No;
  At.jsx = Nn;
  At.jsxs = Nn;
  Wn.exports = At;
  f = Wn.exports;
  const Ie = {
    black: "#000",
    white: "#fff"
  }, Ne = {
    300: "#e57373",
    400: "#ef5350",
    500: "#f44336",
    700: "#d32f2f",
    800: "#c62828"
  }, De = {
    50: "#f3e5f5",
    200: "#ce93d8",
    300: "#ba68c8",
    400: "#ab47bc",
    500: "#9c27b0",
    700: "#7b1fa2"
  }, He = {
    50: "#e3f2fd",
    200: "#90caf9",
    400: "#42a5f5",
    700: "#1976d2",
    800: "#1565c0"
  }, Ke = {
    300: "#4fc3f7",
    400: "#29b6f6",
    500: "#03a9f4",
    700: "#0288d1",
    900: "#01579b"
  }, Ue = {
    300: "#81c784",
    400: "#66bb6a",
    500: "#4caf50",
    700: "#388e3c",
    800: "#2e7d32",
    900: "#1b5e20"
  }, Je = {
    300: "#ffb74d",
    400: "#ffa726",
    500: "#ff9800",
    700: "#f57c00",
    900: "#e65100"
  }, Uo = {
    50: "#fafafa",
    100: "#f5f5f5",
    200: "#eeeeee",
    300: "#e0e0e0",
    400: "#bdbdbd",
    500: "#9e9e9e",
    600: "#757575",
    700: "#616161",
    800: "#424242",
    900: "#212121",
    A100: "#f5f5f5",
    A200: "#eeeeee",
    A400: "#bdbdbd",
    A700: "#616161"
  };
  function rt(e) {
    let t = "https://mui.com/production-error/?code=" + e;
    for (let r = 1; r < arguments.length; r += 1) t += "&args[]=" + encodeURIComponent(arguments[r]);
    return "Minified MUI error #" + e + "; visit " + t + " for the full message.";
  }
  const Vo = Object.freeze(Object.defineProperty({
    __proto__: null,
    default: rt
  }, Symbol.toStringTag, {
    value: "Module"
  })), Pt = "$$material";
  var Yo = /^((children|dangerouslySetInnerHTML|key|ref|autoFocus|defaultValue|defaultChecked|innerHTML|suppressContentEditableWarning|suppressHydrationWarning|valueLink|abbr|accept|acceptCharset|accessKey|action|allow|allowUserMedia|allowPaymentRequest|allowFullScreen|allowTransparency|alt|async|autoComplete|autoPlay|capture|cellPadding|cellSpacing|challenge|charSet|checked|cite|classID|className|cols|colSpan|content|contentEditable|contextMenu|controls|controlsList|coords|crossOrigin|data|dateTime|decoding|default|defer|dir|disabled|disablePictureInPicture|disableRemotePlayback|download|draggable|encType|enterKeyHint|fetchpriority|fetchPriority|form|formAction|formEncType|formMethod|formNoValidate|formTarget|frameBorder|headers|height|hidden|high|href|hrefLang|htmlFor|httpEquiv|id|inputMode|integrity|is|keyParams|keyType|kind|label|lang|list|loading|loop|low|marginHeight|marginWidth|max|maxLength|media|mediaGroup|method|min|minLength|multiple|muted|name|nonce|noValidate|open|optimum|pattern|placeholder|playsInline|popover|popoverTarget|popoverTargetAction|poster|preload|profile|radioGroup|readOnly|referrerPolicy|rel|required|reversed|role|rows|rowSpan|sandbox|scope|scoped|scrolling|seamless|selected|shape|size|sizes|slot|span|spellCheck|src|srcDoc|srcLang|srcSet|start|step|style|summary|tabIndex|target|title|translate|type|useMap|value|width|wmode|wrap|about|datatype|inlist|prefix|property|resource|typeof|vocab|autoCapitalize|autoCorrect|autoSave|color|incremental|fallback|inert|itemProp|itemScope|itemType|itemID|itemRef|on|option|results|security|unselectable|accentHeight|accumulate|additive|alignmentBaseline|allowReorder|alphabetic|amplitude|arabicForm|ascent|attributeName|attributeType|autoReverse|azimuth|baseFrequency|baselineShift|baseProfile|bbox|begin|bias|by|calcMode|capHeight|clip|clipPathUnits|clipPath|clipRule|colorInterpolation|colorInterpolationFilters|colorProfile|colorRendering|contentScriptType|contentStyleType|cursor|cx|cy|d|decelerate|descent|diffuseConstant|direction|display|divisor|dominantBaseline|dur|dx|dy|edgeMode|elevation|enableBackground|end|exponent|externalResourcesRequired|fill|fillOpacity|fillRule|filter|filterRes|filterUnits|floodColor|floodOpacity|focusable|fontFamily|fontSize|fontSizeAdjust|fontStretch|fontStyle|fontVariant|fontWeight|format|from|fr|fx|fy|g1|g2|glyphName|glyphOrientationHorizontal|glyphOrientationVertical|glyphRef|gradientTransform|gradientUnits|hanging|horizAdvX|horizOriginX|ideographic|imageRendering|in|in2|intercept|k|k1|k2|k3|k4|kernelMatrix|kernelUnitLength|kerning|keyPoints|keySplines|keyTimes|lengthAdjust|letterSpacing|lightingColor|limitingConeAngle|local|markerEnd|markerMid|markerStart|markerHeight|markerUnits|markerWidth|mask|maskContentUnits|maskUnits|mathematical|mode|numOctaves|offset|opacity|operator|order|orient|orientation|origin|overflow|overlinePosition|overlineThickness|panose1|paintOrder|pathLength|patternContentUnits|patternTransform|patternUnits|pointerEvents|points|pointsAtX|pointsAtY|pointsAtZ|preserveAlpha|preserveAspectRatio|primitiveUnits|r|radius|refX|refY|renderingIntent|repeatCount|repeatDur|requiredExtensions|requiredFeatures|restart|result|rotate|rx|ry|scale|seed|shapeRendering|slope|spacing|specularConstant|specularExponent|speed|spreadMethod|startOffset|stdDeviation|stemh|stemv|stitchTiles|stopColor|stopOpacity|strikethroughPosition|strikethroughThickness|string|stroke|strokeDasharray|strokeDashoffset|strokeLinecap|strokeLinejoin|strokeMiterlimit|strokeOpacity|strokeWidth|surfaceScale|systemLanguage|tableValues|targetX|targetY|textAnchor|textDecoration|textRendering|textLength|to|transform|u1|u2|underlinePosition|underlineThickness|unicode|unicodeBidi|unicodeRange|unitsPerEm|vAlphabetic|vHanging|vIdeographic|vMathematical|values|vectorEffect|version|vertAdvY|vertOriginX|vertOriginY|viewBox|viewTarget|visibility|widths|wordSpacing|writingMode|x|xHeight|x1|x2|xChannelSelector|xlinkActuate|xlinkArcrole|xlinkHref|xlinkRole|xlinkShow|xlinkTitle|xlinkType|xmlBase|xmlns|xmlnsXlink|xmlLang|xmlSpace|y|y1|y2|yChannelSelector|z|zoomAndPan|for|class|autofocus)|(([Dd][Aa][Tt][Aa]|[Aa][Rr][Ii][Aa]|x)-.*))$/, Go = Oo(function(e) {
    return Yo.test(e) || e.charCodeAt(0) === 111 && e.charCodeAt(1) === 110 && e.charCodeAt(2) < 91;
  });
  const { withEmotionCache: Xo, ThemeContext: qo } = await w("@emotion/react"), Qe = await w("react");
  var Zo = Go, Jo = function(t) {
    return t !== "theme";
  }, Yr = function(t) {
    return typeof t == "string" && t.charCodeAt(0) > 96 ? Zo : Jo;
  }, Gr = function(t, r, n) {
    var o;
    if (r) {
      var i = r.shouldForwardProp;
      o = t.__emotion_forwardProp && i ? function(s) {
        return t.__emotion_forwardProp(s) && i(s);
      } : i;
    }
    return typeof o != "function" && n && (o = t.__emotion_forwardProp), o;
  }, Qo = function(t) {
    var r = t.cache, n = t.serialized, o = t.isStringTag;
    return jo(r, n, o), Bo(function() {
      return Ao(r, n, o);
    }), null;
  }, ei = function e(t, r) {
    var n = t.__emotion_real === t, o = n && t.__emotion_base || t, i, s;
    r !== void 0 && (i = r.label, s = r.target);
    var c = Gr(t, r, n), a = c || Yr(o), l = !a("as");
    return function() {
      var p = arguments, u = n && t.__emotion_styles !== void 0 ? t.__emotion_styles.slice(0) : [];
      if (i !== void 0 && u.push("label:" + i + ";"), p[0] == null || p[0].raw === void 0) u.push.apply(u, p);
      else {
        var d = p[0];
        u.push(d[0]);
        for (var y = p.length, g = 1; g < y; g++) u.push(p[g], d[g]);
      }
      var m = Xo(function(v, T, E) {
        var z = l && v.as || o, C = "", B = [], R = v;
        if (v.theme == null) {
          R = {};
          for (var k in v) R[k] = v[k];
          R.theme = Qe.useContext(qo);
        }
        typeof v.className == "string" ? C = Mo(T.registered, B, v.className) : v.className != null && (C = v.className + " ");
        var W = Fn(u.concat(B), T.registered, R);
        C += T.key + "-" + W.name, s !== void 0 && (C += " " + s);
        var K = l && c === void 0 ? Yr(z) : a, O = {};
        for (var U in v) l && U === "as" || K(U) && (O[U] = v[U]);
        return O.className = C, E && (O.ref = E), Qe.createElement(Qe.Fragment, null, Qe.createElement(Qo, {
          cache: T,
          serialized: W,
          isStringTag: typeof z == "string"
        }), Qe.createElement(z, O));
      });
      return m.displayName = i !== void 0 ? i : "Styled(" + (typeof o == "string" ? o : o.displayName || o.name || "Component") + ")", m.defaultProps = t.defaultProps, m.__emotion_real = m, m.__emotion_base = o, m.__emotion_styles = u, m.__emotion_forwardProp = c, Object.defineProperty(m, "toString", {
        value: function() {
          return "." + s;
        }
      }), m.withComponent = function(v, T) {
        var E = e(v, h({}, r, T, {
          shouldForwardProp: Gr(m, T, true)
        }));
        return E.apply(void 0, u);
      }, m;
    };
  }, ti = [
    "a",
    "abbr",
    "address",
    "area",
    "article",
    "aside",
    "audio",
    "b",
    "base",
    "bdi",
    "bdo",
    "big",
    "blockquote",
    "body",
    "br",
    "button",
    "canvas",
    "caption",
    "cite",
    "code",
    "col",
    "colgroup",
    "data",
    "datalist",
    "dd",
    "del",
    "details",
    "dfn",
    "dialog",
    "div",
    "dl",
    "dt",
    "em",
    "embed",
    "fieldset",
    "figcaption",
    "figure",
    "footer",
    "form",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "head",
    "header",
    "hgroup",
    "hr",
    "html",
    "i",
    "iframe",
    "img",
    "input",
    "ins",
    "kbd",
    "keygen",
    "label",
    "legend",
    "li",
    "link",
    "main",
    "map",
    "mark",
    "marquee",
    "menu",
    "menuitem",
    "meta",
    "meter",
    "nav",
    "noscript",
    "object",
    "ol",
    "optgroup",
    "option",
    "output",
    "p",
    "param",
    "picture",
    "pre",
    "progress",
    "q",
    "rp",
    "rt",
    "ruby",
    "s",
    "samp",
    "script",
    "section",
    "select",
    "small",
    "source",
    "span",
    "strong",
    "style",
    "sub",
    "summary",
    "sup",
    "table",
    "tbody",
    "td",
    "textarea",
    "tfoot",
    "th",
    "thead",
    "time",
    "title",
    "tr",
    "track",
    "u",
    "ul",
    "var",
    "video",
    "wbr",
    "circle",
    "clipPath",
    "defs",
    "ellipse",
    "foreignObject",
    "g",
    "image",
    "line",
    "linearGradient",
    "mask",
    "path",
    "pattern",
    "polygon",
    "polyline",
    "radialGradient",
    "rect",
    "stop",
    "svg",
    "text",
    "tspan"
  ], q = ei.bind(null);
  ti.forEach(function(e) {
    q[e] = q(e);
  });
  const ri = await w("react"), { CacheProvider: ni } = await w("@emotion/react");
  function oi(e, t) {
    const r = Io({
      key: "css",
      prepend: e
    });
    if (t) {
      const n = r.insert;
      r.insert = (...o) => (o[1].styles.match(/^@layer\s+[^{]*$/) || (o[1].styles = `@layer mui {${o[1].styles}}`), n(...o));
    }
    return r;
  }
  const dr = /* @__PURE__ */ new Map();
  function Dn(e) {
    const { injectFirst: t, enableCssLayer: r, children: n } = e, o = ri.useMemo(() => {
      const i = `${t}-${r}`;
      if (typeof document == "object" && dr.has(i)) return dr.get(i);
      const s = oi(t, r);
      return dr.set(i, s), s;
    }, [
      t,
      r
    ]);
    return t || r ? f.jsx(ni, {
      value: o,
      children: n
    }) : n;
  }
  await w("react");
  const { Global: ii } = await w("@emotion/react");
  function si(e) {
    return e == null || Object.keys(e).length === 0;
  }
  function Hn(e) {
    const { styles: t, defaultTheme: r = {} } = e, n = typeof t == "function" ? (o) => t(si(o) ? r : o) : t;
    return f.jsx(ii, {
      styles: n
    });
  }
  function ai(e, t) {
    return q(e, t);
  }
  const li = (e, t) => {
    Array.isArray(e.__emotion_styles) && (e.__emotion_styles = t(e.__emotion_styles));
  }, Xr = [];
  function Kn(e) {
    return Xr[0] = e, Fn(Xr);
  }
  const ci = Object.freeze(Object.defineProperty({
    __proto__: null,
    GlobalStyles: Hn,
    StyledEngineProvider: Dn,
    ThemeContext: Pr,
    css: zo,
    default: ai,
    internal_processStyles: li,
    internal_serializeStyles: Kn,
    keyframes: Bt
  }, Symbol.toStringTag, {
    value: "Module"
  })), Un = await w("react");
  function _e(e) {
    if (typeof e != "object" || e === null) return false;
    const t = Object.getPrototypeOf(e);
    return (t === null || t === Object.prototype || Object.getPrototypeOf(t) === null) && !(Symbol.toStringTag in e) && !(Symbol.iterator in e);
  }
  function Vn(e) {
    if (Un.isValidElement(e) || !_e(e)) return e;
    const t = {};
    return Object.keys(e).forEach((r) => {
      t[r] = Vn(e[r]);
    }), t;
  }
  function ve(e, t, r = {
    clone: true
  }) {
    const n = r.clone ? h({}, e) : e;
    return _e(e) && _e(t) && Object.keys(t).forEach((o) => {
      Un.isValidElement(t[o]) ? n[o] = t[o] : _e(t[o]) && Object.prototype.hasOwnProperty.call(e, o) && _e(e[o]) ? n[o] = ve(e[o], t[o], r) : r.clone ? n[o] = _e(t[o]) ? Vn(t[o]) : t[o] : n[o] = t[o];
    }), n;
  }
  const ui = Object.freeze(Object.defineProperty({
    __proto__: null,
    default: ve,
    isPlainObject: _e
  }, Symbol.toStringTag, {
    value: "Module"
  })), di = [
    "values",
    "unit",
    "step"
  ], fi = (e) => {
    const t = Object.keys(e).map((r) => ({
      key: r,
      val: e[r]
    })) || [];
    return t.sort((r, n) => r.val - n.val), t.reduce((r, n) => h({}, r, {
      [n.key]: n.val
    }), {});
  };
  function Yn(e) {
    const { values: t = {
      xs: 0,
      sm: 600,
      md: 900,
      lg: 1200,
      xl: 1536
    }, unit: r = "px", step: n = 5 } = e, o = Y(e, di), i = fi(t), s = Object.keys(i);
    function c(d) {
      return `@media (min-width:${typeof t[d] == "number" ? t[d] : d}${r})`;
    }
    function a(d) {
      return `@media (max-width:${(typeof t[d] == "number" ? t[d] : d) - n / 100}${r})`;
    }
    function l(d, y) {
      const g = s.indexOf(y);
      return `@media (min-width:${typeof t[d] == "number" ? t[d] : d}${r}) and (max-width:${(g !== -1 && typeof t[s[g]] == "number" ? t[s[g]] : y) - n / 100}${r})`;
    }
    function p(d) {
      return s.indexOf(d) + 1 < s.length ? l(d, s[s.indexOf(d) + 1]) : c(d);
    }
    function u(d) {
      const y = s.indexOf(d);
      return y === 0 ? c(s[1]) : y === s.length - 1 ? a(s[y]) : l(d, s[s.indexOf(d) + 1]).replace("@media", "@media not all and");
    }
    return h({
      keys: s,
      values: i,
      up: c,
      down: a,
      between: l,
      only: p,
      not: u,
      unit: r
    }, o);
  }
  const pi = {
    borderRadius: 4
  };
  function tt(e, t) {
    return t ? ve(e, t, {
      clone: false
    }) : e;
  }
  const kr = {
    xs: 0,
    sm: 600,
    md: 900,
    lg: 1200,
    xl: 1536
  }, qr = {
    keys: [
      "xs",
      "sm",
      "md",
      "lg",
      "xl"
    ],
    up: (e) => `@media (min-width:${kr[e]}px)`
  };
  function Ce(e, t, r) {
    const n = e.theme || {};
    if (Array.isArray(t)) {
      const i = n.breakpoints || qr;
      return t.reduce((s, c, a) => (s[i.up(i.keys[a])] = r(t[a]), s), {});
    }
    if (typeof t == "object") {
      const i = n.breakpoints || qr;
      return Object.keys(t).reduce((s, c) => {
        if (Object.keys(i.values || kr).indexOf(c) !== -1) {
          const a = i.up(c);
          s[a] = r(t[c], c);
        } else {
          const a = c;
          s[a] = t[a];
        }
        return s;
      }, {});
    }
    return r(t);
  }
  function mi(e = {}) {
    var t;
    return ((t = e.keys) == null ? void 0 : t.reduce((n, o) => {
      const i = e.up(o);
      return n[i] = {}, n;
    }, {})) || {};
  }
  function Zr(e, t) {
    return e.reduce((r, n) => {
      const o = r[n];
      return (!o || Object.keys(o).length === 0) && delete r[n], r;
    }, t);
  }
  function Z(e) {
    if (typeof e != "string") throw new Error(rt(7));
    return e.charAt(0).toUpperCase() + e.slice(1);
  }
  const hi = Object.freeze(Object.defineProperty({
    __proto__: null,
    default: Z
  }, Symbol.toStringTag, {
    value: "Module"
  }));
  function It(e, t, r = true) {
    if (!t || typeof t != "string") return null;
    if (e && e.vars && r) {
      const n = `vars.${t}`.split(".").reduce((o, i) => o && o[i] ? o[i] : null, e);
      if (n != null) return n;
    }
    return t.split(".").reduce((n, o) => n && n[o] != null ? n[o] : null, e);
  }
  function kt(e, t, r, n = r) {
    let o;
    return typeof e == "function" ? o = e(r) : Array.isArray(e) ? o = e[r] || n : o = It(e, r) || n, t && (o = t(o, n, e)), o;
  }
  function D(e) {
    const { prop: t, cssProperty: r = e.prop, themeKey: n, transform: o } = e, i = (s) => {
      if (s[t] == null) return null;
      const c = s[t], a = s.theme, l = It(a, n) || {};
      return Ce(s, c, (u) => {
        let d = kt(l, o, u);
        return u === d && typeof u == "string" && (d = kt(l, o, `${t}${u === "default" ? "" : Z(u)}`, u)), r === false ? d : {
          [r]: d
        };
      });
    };
    return i.propTypes = {}, i.filterProps = [
      t
    ], i;
  }
  function gi(e) {
    const t = {};
    return (r) => (t[r] === void 0 && (t[r] = e(r)), t[r]);
  }
  const yi = {
    m: "margin",
    p: "padding"
  }, bi = {
    t: "Top",
    r: "Right",
    b: "Bottom",
    l: "Left",
    x: [
      "Left",
      "Right"
    ],
    y: [
      "Top",
      "Bottom"
    ]
  }, Jr = {
    marginX: "mx",
    marginY: "my",
    paddingX: "px",
    paddingY: "py"
  }, vi = gi((e) => {
    if (e.length > 2) if (Jr[e]) e = Jr[e];
    else return [
      e
    ];
    const [t, r] = e.split(""), n = yi[t], o = bi[r] || "";
    return Array.isArray(o) ? o.map((i) => n + i) : [
      n + o
    ];
  }), Or = [
    "m",
    "mt",
    "mr",
    "mb",
    "ml",
    "mx",
    "my",
    "margin",
    "marginTop",
    "marginRight",
    "marginBottom",
    "marginLeft",
    "marginX",
    "marginY",
    "marginInline",
    "marginInlineStart",
    "marginInlineEnd",
    "marginBlock",
    "marginBlockStart",
    "marginBlockEnd"
  ], Mr = [
    "p",
    "pt",
    "pr",
    "pb",
    "pl",
    "px",
    "py",
    "padding",
    "paddingTop",
    "paddingRight",
    "paddingBottom",
    "paddingLeft",
    "paddingX",
    "paddingY",
    "paddingInline",
    "paddingInlineStart",
    "paddingInlineEnd",
    "paddingBlock",
    "paddingBlockStart",
    "paddingBlockEnd"
  ];
  [
    ...Or,
    ...Mr
  ];
  function nt(e, t, r, n) {
    var o;
    const i = (o = It(e, t, false)) != null ? o : r;
    return typeof i == "number" ? (s) => typeof s == "string" ? s : i * s : Array.isArray(i) ? (s) => typeof s == "string" ? s : i[s] : typeof i == "function" ? i : () => {
    };
  }
  function Gn(e) {
    return nt(e, "spacing", 8);
  }
  function ot(e, t) {
    if (typeof t == "string" || t == null) return t;
    const r = Math.abs(t), n = e(r);
    return t >= 0 ? n : typeof n == "number" ? -n : `-${n}`;
  }
  function xi(e, t) {
    return (r) => e.reduce((n, o) => (n[o] = ot(t, r), n), {});
  }
  function Si(e, t, r, n) {
    if (t.indexOf(r) === -1) return null;
    const o = vi(r), i = xi(o, n), s = e[r];
    return Ce(e, s, i);
  }
  function Xn(e, t) {
    const r = Gn(e.theme);
    return Object.keys(e).map((n) => Si(e, t, n, r)).reduce(tt, {});
  }
  function L(e) {
    return Xn(e, Or);
  }
  L.propTypes = {};
  L.filterProps = Or;
  function F(e) {
    return Xn(e, Mr);
  }
  F.propTypes = {};
  F.filterProps = Mr;
  function wi(e = 8) {
    if (e.mui) return e;
    const t = Gn({
      spacing: e
    }), r = (...n) => (n.length === 0 ? [
      1
    ] : n).map((i) => {
      const s = t(i);
      return typeof s == "number" ? `${s}px` : s;
    }).join(" ");
    return r.mui = true, r;
  }
  function zt(...e) {
    const t = e.reduce((n, o) => (o.filterProps.forEach((i) => {
      n[i] = o;
    }), n), {}), r = (n) => Object.keys(n).reduce((o, i) => t[i] ? tt(o, t[i](n)) : o, {});
    return r.propTypes = {}, r.filterProps = e.reduce((n, o) => n.concat(o.filterProps), []), r;
  }
  function ae(e) {
    return typeof e != "number" ? e : `${e}px solid`;
  }
  function ce(e, t) {
    return D({
      prop: e,
      themeKey: "borders",
      transform: t
    });
  }
  const Ci = ce("border", ae), Ti = ce("borderTop", ae), Ri = ce("borderRight", ae), $i = ce("borderBottom", ae), _i = ce("borderLeft", ae), Ei = ce("borderColor"), Pi = ce("borderTopColor"), ki = ce("borderRightColor"), Oi = ce("borderBottomColor"), Mi = ce("borderLeftColor"), ji = ce("outline", ae), Bi = ce("outlineColor"), Lt = (e) => {
    if (e.borderRadius !== void 0 && e.borderRadius !== null) {
      const t = nt(e.theme, "shape.borderRadius", 4), r = (n) => ({
        borderRadius: ot(t, n)
      });
      return Ce(e, e.borderRadius, r);
    }
    return null;
  };
  Lt.propTypes = {};
  Lt.filterProps = [
    "borderRadius"
  ];
  zt(Ci, Ti, Ri, $i, _i, Ei, Pi, ki, Oi, Mi, Lt, ji, Bi);
  const Ft = (e) => {
    if (e.gap !== void 0 && e.gap !== null) {
      const t = nt(e.theme, "spacing", 8), r = (n) => ({
        gap: ot(t, n)
      });
      return Ce(e, e.gap, r);
    }
    return null;
  };
  Ft.propTypes = {};
  Ft.filterProps = [
    "gap"
  ];
  const Wt = (e) => {
    if (e.columnGap !== void 0 && e.columnGap !== null) {
      const t = nt(e.theme, "spacing", 8), r = (n) => ({
        columnGap: ot(t, n)
      });
      return Ce(e, e.columnGap, r);
    }
    return null;
  };
  Wt.propTypes = {};
  Wt.filterProps = [
    "columnGap"
  ];
  const Nt = (e) => {
    if (e.rowGap !== void 0 && e.rowGap !== null) {
      const t = nt(e.theme, "spacing", 8), r = (n) => ({
        rowGap: ot(t, n)
      });
      return Ce(e, e.rowGap, r);
    }
    return null;
  };
  Nt.propTypes = {};
  Nt.filterProps = [
    "rowGap"
  ];
  const Ai = D({
    prop: "gridColumn"
  }), Ii = D({
    prop: "gridRow"
  }), zi = D({
    prop: "gridAutoFlow"
  }), Li = D({
    prop: "gridAutoColumns"
  }), Fi = D({
    prop: "gridAutoRows"
  }), Wi = D({
    prop: "gridTemplateColumns"
  }), Ni = D({
    prop: "gridTemplateRows"
  }), Di = D({
    prop: "gridTemplateAreas"
  }), Hi = D({
    prop: "gridArea"
  });
  zt(Ft, Wt, Nt, Ai, Ii, zi, Li, Fi, Wi, Ni, Di, Hi);
  function Ye(e, t) {
    return t === "grey" ? t : e;
  }
  const Ki = D({
    prop: "color",
    themeKey: "palette",
    transform: Ye
  }), Ui = D({
    prop: "bgcolor",
    cssProperty: "backgroundColor",
    themeKey: "palette",
    transform: Ye
  }), Vi = D({
    prop: "backgroundColor",
    themeKey: "palette",
    transform: Ye
  });
  zt(Ki, Ui, Vi);
  function re(e) {
    return e <= 1 && e !== 0 ? `${e * 100}%` : e;
  }
  const Yi = D({
    prop: "width",
    transform: re
  }), jr = (e) => {
    if (e.maxWidth !== void 0 && e.maxWidth !== null) {
      const t = (r) => {
        var n, o;
        const i = ((n = e.theme) == null || (n = n.breakpoints) == null || (n = n.values) == null ? void 0 : n[r]) || kr[r];
        return i ? ((o = e.theme) == null || (o = o.breakpoints) == null ? void 0 : o.unit) !== "px" ? {
          maxWidth: `${i}${e.theme.breakpoints.unit}`
        } : {
          maxWidth: i
        } : {
          maxWidth: re(r)
        };
      };
      return Ce(e, e.maxWidth, t);
    }
    return null;
  };
  jr.filterProps = [
    "maxWidth"
  ];
  const Gi = D({
    prop: "minWidth",
    transform: re
  }), Xi = D({
    prop: "height",
    transform: re
  }), qi = D({
    prop: "maxHeight",
    transform: re
  }), Zi = D({
    prop: "minHeight",
    transform: re
  });
  D({
    prop: "size",
    cssProperty: "width",
    transform: re
  });
  D({
    prop: "size",
    cssProperty: "height",
    transform: re
  });
  const Ji = D({
    prop: "boxSizing"
  });
  zt(Yi, jr, Gi, Xi, qi, Zi, Ji);
  const it = {
    border: {
      themeKey: "borders",
      transform: ae
    },
    borderTop: {
      themeKey: "borders",
      transform: ae
    },
    borderRight: {
      themeKey: "borders",
      transform: ae
    },
    borderBottom: {
      themeKey: "borders",
      transform: ae
    },
    borderLeft: {
      themeKey: "borders",
      transform: ae
    },
    borderColor: {
      themeKey: "palette"
    },
    borderTopColor: {
      themeKey: "palette"
    },
    borderRightColor: {
      themeKey: "palette"
    },
    borderBottomColor: {
      themeKey: "palette"
    },
    borderLeftColor: {
      themeKey: "palette"
    },
    outline: {
      themeKey: "borders",
      transform: ae
    },
    outlineColor: {
      themeKey: "palette"
    },
    borderRadius: {
      themeKey: "shape.borderRadius",
      style: Lt
    },
    color: {
      themeKey: "palette",
      transform: Ye
    },
    bgcolor: {
      themeKey: "palette",
      cssProperty: "backgroundColor",
      transform: Ye
    },
    backgroundColor: {
      themeKey: "palette",
      transform: Ye
    },
    p: {
      style: F
    },
    pt: {
      style: F
    },
    pr: {
      style: F
    },
    pb: {
      style: F
    },
    pl: {
      style: F
    },
    px: {
      style: F
    },
    py: {
      style: F
    },
    padding: {
      style: F
    },
    paddingTop: {
      style: F
    },
    paddingRight: {
      style: F
    },
    paddingBottom: {
      style: F
    },
    paddingLeft: {
      style: F
    },
    paddingX: {
      style: F
    },
    paddingY: {
      style: F
    },
    paddingInline: {
      style: F
    },
    paddingInlineStart: {
      style: F
    },
    paddingInlineEnd: {
      style: F
    },
    paddingBlock: {
      style: F
    },
    paddingBlockStart: {
      style: F
    },
    paddingBlockEnd: {
      style: F
    },
    m: {
      style: L
    },
    mt: {
      style: L
    },
    mr: {
      style: L
    },
    mb: {
      style: L
    },
    ml: {
      style: L
    },
    mx: {
      style: L
    },
    my: {
      style: L
    },
    margin: {
      style: L
    },
    marginTop: {
      style: L
    },
    marginRight: {
      style: L
    },
    marginBottom: {
      style: L
    },
    marginLeft: {
      style: L
    },
    marginX: {
      style: L
    },
    marginY: {
      style: L
    },
    marginInline: {
      style: L
    },
    marginInlineStart: {
      style: L
    },
    marginInlineEnd: {
      style: L
    },
    marginBlock: {
      style: L
    },
    marginBlockStart: {
      style: L
    },
    marginBlockEnd: {
      style: L
    },
    displayPrint: {
      cssProperty: false,
      transform: (e) => ({
        "@media print": {
          display: e
        }
      })
    },
    display: {},
    overflow: {},
    textOverflow: {},
    visibility: {},
    whiteSpace: {},
    flexBasis: {},
    flexDirection: {},
    flexWrap: {},
    justifyContent: {},
    alignItems: {},
    alignContent: {},
    order: {},
    flex: {},
    flexGrow: {},
    flexShrink: {},
    alignSelf: {},
    justifyItems: {},
    justifySelf: {},
    gap: {
      style: Ft
    },
    rowGap: {
      style: Nt
    },
    columnGap: {
      style: Wt
    },
    gridColumn: {},
    gridRow: {},
    gridAutoFlow: {},
    gridAutoColumns: {},
    gridAutoRows: {},
    gridTemplateColumns: {},
    gridTemplateRows: {},
    gridTemplateAreas: {},
    gridArea: {},
    position: {},
    zIndex: {
      themeKey: "zIndex"
    },
    top: {},
    right: {},
    bottom: {},
    left: {},
    boxShadow: {
      themeKey: "shadows"
    },
    width: {
      transform: re
    },
    maxWidth: {
      style: jr
    },
    minWidth: {
      transform: re
    },
    height: {
      transform: re
    },
    maxHeight: {
      transform: re
    },
    minHeight: {
      transform: re
    },
    boxSizing: {},
    fontFamily: {
      themeKey: "typography"
    },
    fontSize: {
      themeKey: "typography"
    },
    fontStyle: {
      themeKey: "typography"
    },
    fontWeight: {
      themeKey: "typography"
    },
    letterSpacing: {},
    textTransform: {},
    lineHeight: {},
    textAlign: {},
    typography: {
      cssProperty: false,
      themeKey: "typography"
    }
  };
  function Qi(...e) {
    const t = e.reduce((n, o) => n.concat(Object.keys(o)), []), r = new Set(t);
    return e.every((n) => r.size === Object.keys(n).length);
  }
  function es(e, t) {
    return typeof e == "function" ? e(t) : e;
  }
  function qn() {
    function e(r, n, o, i) {
      const s = {
        [r]: n,
        theme: o
      }, c = i[r];
      if (!c) return {
        [r]: n
      };
      const { cssProperty: a = r, themeKey: l, transform: p, style: u } = c;
      if (n == null) return null;
      if (l === "typography" && n === "inherit") return {
        [r]: n
      };
      const d = It(o, l) || {};
      return u ? u(s) : Ce(s, n, (g) => {
        let m = kt(d, p, g);
        return g === m && typeof g == "string" && (m = kt(d, p, `${r}${g === "default" ? "" : Z(g)}`, g)), a === false ? m : {
          [a]: m
        };
      });
    }
    function t(r) {
      var n;
      const { sx: o, theme: i = {}, nested: s } = r || {};
      if (!o) return null;
      const c = (n = i.unstable_sxConfig) != null ? n : it;
      function a(l) {
        let p = l;
        if (typeof l == "function") p = l(i);
        else if (typeof l != "object") return l;
        if (!p) return null;
        const u = mi(i.breakpoints), d = Object.keys(u);
        let y = u;
        return Object.keys(p).forEach((g) => {
          const m = es(p[g], i);
          if (m != null) if (typeof m == "object") if (c[g]) y = tt(y, e(g, m, i, c));
          else {
            const v = Ce({
              theme: i
            }, m, (T) => ({
              [g]: T
            }));
            Qi(v, m) ? y[g] = t({
              sx: m,
              theme: i,
              nested: true
            }) : y = tt(y, v);
          }
          else y = tt(y, e(g, m, i, c));
        }), !s && i.modularCssLayers ? {
          "@layer sx": Zr(d, y)
        } : Zr(d, y);
      }
      return Array.isArray(o) ? o.map(a) : a(o);
    }
    return t;
  }
  const Dt = qn();
  Dt.filterProps = [
    "sx"
  ];
  function Zn(e, t) {
    const r = this;
    return r.vars && typeof r.getColorSchemeSelector == "function" ? {
      [r.getColorSchemeSelector(e).replace(/(\[[^\]]+\])/, "*:where($1)")]: t
    } : r.palette.mode === e ? t : {};
  }
  const ts = [
    "breakpoints",
    "palette",
    "spacing",
    "shape"
  ];
  function Br(e = {}, ...t) {
    const { breakpoints: r = {}, palette: n = {}, spacing: o, shape: i = {} } = e, s = Y(e, ts), c = Yn(r), a = wi(o);
    let l = ve({
      breakpoints: c,
      direction: "ltr",
      components: {},
      palette: h({
        mode: "light"
      }, n),
      spacing: a,
      shape: h({}, pi, i)
    }, s);
    return l.applyStyles = Zn, l = t.reduce((p, u) => ve(p, u), l), l.unstable_sxConfig = h({}, it, s == null ? void 0 : s.unstable_sxConfig), l.unstable_sx = function(u) {
      return Dt({
        sx: u,
        theme: this
      });
    }, l;
  }
  const rs = Object.freeze(Object.defineProperty({
    __proto__: null,
    default: Br,
    private_createBreakpoints: Yn,
    unstable_applyStyles: Zn
  }, Symbol.toStringTag, {
    value: "Module"
  })), ns = await w("react");
  function os(e) {
    return Object.keys(e).length === 0;
  }
  function Ar(e = null) {
    const t = ns.useContext(Pr);
    return !t || os(t) ? e : t;
  }
  const is = Br();
  function Jn(e = is) {
    return Ar(e);
  }
  await w("react");
  function fr(e) {
    const t = Kn(e);
    return e !== t && t.styles ? (t.styles.match(/^@layer\s+[^{]*$/) || (t.styles = `@layer global{${t.styles}}`), t) : e;
  }
  function ss({ styles: e, themeId: t, defaultTheme: r = {} }) {
    const n = Jn(r), o = t && n[t] || n;
    let i = typeof e == "function" ? e(o) : e;
    return o.modularCssLayers && (Array.isArray(i) ? i = i.map((s) => fr(typeof s == "function" ? s(o) : s)) : i = fr(i)), f.jsx(Hn, {
      styles: i
    });
  }
  const as = [
    "sx"
  ], ls = (e) => {
    var t, r;
    const n = {
      systemProps: {},
      otherProps: {}
    }, o = (t = e == null || (r = e.theme) == null ? void 0 : r.unstable_sxConfig) != null ? t : it;
    return Object.keys(e).forEach((i) => {
      o[i] ? n.systemProps[i] = e[i] : n.otherProps[i] = e[i];
    }), n;
  };
  function Qn(e) {
    const { sx: t } = e, r = Y(e, as), { systemProps: n, otherProps: o } = ls(r);
    let i;
    return Array.isArray(t) ? i = [
      n,
      ...t
    ] : typeof t == "function" ? i = (...s) => {
      const c = t(...s);
      return _e(c) ? h({}, n, c) : n;
    } : i = h({}, n, t), h({}, o, {
      sx: i
    });
  }
  const cs = Object.freeze(Object.defineProperty({
    __proto__: null,
    default: Dt,
    extendSxProp: Qn,
    unstable_createStyleFunctionSx: qn,
    unstable_defaultSxConfig: it
  }, Symbol.toStringTag, {
    value: "Module"
  })), Qr = (e) => e, us = () => {
    let e = Qr;
    return {
      configure(t) {
        e = t;
      },
      generate(t) {
        return e(t);
      },
      reset() {
        e = Qr;
      }
    };
  }, ds = us();
  function eo(e) {
    var t, r, n = "";
    if (typeof e == "string" || typeof e == "number") n += e;
    else if (typeof e == "object") if (Array.isArray(e)) {
      var o = e.length;
      for (t = 0; t < o; t++) e[t] && (r = eo(e[t])) && (n && (n += " "), n += r);
    } else for (r in e) e[r] && (n && (n += " "), n += r);
    return n;
  }
  function I() {
    for (var e, t, r = 0, n = "", o = arguments.length; r < o; r++) (e = arguments[r]) && (t = eo(e)) && (n && (n += " "), n += t);
    return n;
  }
  const fs = {
    active: "active",
    checked: "checked",
    completed: "completed",
    disabled: "disabled",
    error: "error",
    expanded: "expanded",
    focused: "focused",
    focusVisible: "focusVisible",
    open: "open",
    readOnly: "readOnly",
    required: "required",
    selected: "selected"
  };
  function Ee(e, t, r = "Mui") {
    const n = fs[t];
    return n ? `${r}-${n}` : `${ds.generate(e)}-${t}`;
  }
  function Pe(e, t, r = "Mui") {
    const n = {};
    return t.forEach((o) => {
      n[o] = Ee(e, o, r);
    }), n;
  }
  var to = {
    exports: {}
  }, j = {};
  var Ir = Symbol.for("react.transitional.element"), zr = Symbol.for("react.portal"), Ht = Symbol.for("react.fragment"), Kt = Symbol.for("react.strict_mode"), Ut = Symbol.for("react.profiler"), Vt = Symbol.for("react.consumer"), Yt = Symbol.for("react.context"), Gt = Symbol.for("react.forward_ref"), Xt = Symbol.for("react.suspense"), qt = Symbol.for("react.suspense_list"), Zt = Symbol.for("react.memo"), Jt = Symbol.for("react.lazy"), ps = Symbol.for("react.view_transition"), ms = Symbol.for("react.client.reference");
  function ue(e) {
    if (typeof e == "object" && e !== null) {
      var t = e.$$typeof;
      switch (t) {
        case Ir:
          switch (e = e.type, e) {
            case Ht:
            case Ut:
            case Kt:
            case Xt:
            case qt:
            case ps:
              return e;
            default:
              switch (e = e && e.$$typeof, e) {
                case Yt:
                case Gt:
                case Jt:
                case Zt:
                  return e;
                case Vt:
                  return e;
                default:
                  return t;
              }
          }
        case zr:
          return t;
      }
    }
  }
  j.ContextConsumer = Vt;
  j.ContextProvider = Yt;
  j.Element = Ir;
  j.ForwardRef = Gt;
  j.Fragment = Ht;
  j.Lazy = Jt;
  j.Memo = Zt;
  j.Portal = zr;
  j.Profiler = Ut;
  j.StrictMode = Kt;
  j.Suspense = Xt;
  j.SuspenseList = qt;
  j.isContextConsumer = function(e) {
    return ue(e) === Vt;
  };
  j.isContextProvider = function(e) {
    return ue(e) === Yt;
  };
  j.isElement = function(e) {
    return typeof e == "object" && e !== null && e.$$typeof === Ir;
  };
  j.isForwardRef = function(e) {
    return ue(e) === Gt;
  };
  j.isFragment = function(e) {
    return ue(e) === Ht;
  };
  j.isLazy = function(e) {
    return ue(e) === Jt;
  };
  j.isMemo = function(e) {
    return ue(e) === Zt;
  };
  j.isPortal = function(e) {
    return ue(e) === zr;
  };
  j.isProfiler = function(e) {
    return ue(e) === Ut;
  };
  j.isStrictMode = function(e) {
    return ue(e) === Kt;
  };
  j.isSuspense = function(e) {
    return ue(e) === Xt;
  };
  j.isSuspenseList = function(e) {
    return ue(e) === qt;
  };
  j.isValidElementType = function(e) {
    return typeof e == "string" || typeof e == "function" || e === Ht || e === Ut || e === Kt || e === Xt || e === qt || typeof e == "object" && e !== null && (e.$$typeof === Jt || e.$$typeof === Zt || e.$$typeof === Yt || e.$$typeof === Vt || e.$$typeof === Gt || e.$$typeof === ms || e.getModuleId !== void 0);
  };
  j.typeOf = ue;
  to.exports = j;
  var en = to.exports;
  const hs = /^\s*function(?:\s|\s*\/\*.*\*\/\s*)+([^(\s/]*)\s*/;
  function ro(e) {
    const t = `${e}`.match(hs);
    return t && t[1] || "";
  }
  function no(e, t = "") {
    return e.displayName || e.name || ro(e) || t;
  }
  function tn(e, t, r) {
    const n = no(t);
    return e.displayName || (n !== "" ? `${r}(${n})` : r);
  }
  function gs(e) {
    if (e != null) {
      if (typeof e == "string") return e;
      if (typeof e == "function") return no(e, "Component");
      if (typeof e == "object") switch (e.$$typeof) {
        case en.ForwardRef:
          return tn(e, e.render, "ForwardRef");
        case en.Memo:
          return tn(e, e.type, "memo");
        default:
          return;
      }
    }
  }
  const ys = Object.freeze(Object.defineProperty({
    __proto__: null,
    default: gs,
    getFunctionName: ro
  }, Symbol.toStringTag, {
    value: "Module"
  }));
  function Sr(e, t) {
    const r = h({}, t);
    return Object.keys(e).forEach((n) => {
      if (n.toString().match(/^(components|slots)$/)) r[n] = h({}, e[n], r[n]);
      else if (n.toString().match(/^(componentsProps|slotProps)$/)) {
        const o = e[n] || {}, i = t[n];
        r[n] = {}, !i || !Object.keys(i) ? r[n] = o : !o || !Object.keys(o) ? r[n] = i : (r[n] = h({}, i), Object.keys(o).forEach((s) => {
          r[n][s] = Sr(o[s], i[s]);
        }));
      } else r[n] === void 0 && (r[n] = e[n]);
    }), r;
  }
  const rn = await w("react"), Lr = typeof window < "u" ? rn.useLayoutEffect : rn.useEffect;
  function bs(e, t = Number.MIN_SAFE_INTEGER, r = Number.MAX_SAFE_INTEGER) {
    return Math.max(t, Math.min(e, r));
  }
  const vs = Object.freeze(Object.defineProperty({
    __proto__: null,
    default: bs
  }, Symbol.toStringTag, {
    value: "Module"
  }));
  function oo(e, t = 166) {
    let r;
    function n(...o) {
      const i = () => {
        e.apply(this, o);
      };
      clearTimeout(r), r = setTimeout(i, t);
    }
    return n.clear = () => {
      clearTimeout(r);
    }, n;
  }
  function io(e) {
    return e && e.ownerDocument || document;
  }
  function so(e) {
    return io(e).defaultView || window;
  }
  function xs(e, t) {
    typeof e == "function" ? e(t) : e && (e.current = t);
  }
  const wr = await w("react");
  let nn = 0;
  function Ss(e) {
    const [t, r] = wr.useState(e), n = e || t;
    return wr.useEffect(() => {
      t == null && (nn += 1, r(`mui-${nn}`));
    }, [
      t
    ]), n;
  }
  const on = wr.useId;
  function ws(e) {
    return on !== void 0 ? on() : Ss(e);
  }
  const sn = await w("react");
  function Be(e) {
    const t = sn.useRef(e);
    return Lr(() => {
      t.current = e;
    }), sn.useRef((...r) => (0, t.current)(...r)).current;
  }
  const Cs = await w("react");
  function Cr(...e) {
    return Cs.useMemo(() => e.every((t) => t == null) ? null : (t) => {
      e.forEach((r) => {
        xs(r, t);
      });
    }, e);
  }
  const Ts = await w("react"), an = {};
  function Rs(e, t) {
    const r = Ts.useRef(an);
    return r.current === an && (r.current = e(t)), r;
  }
  const $s = await w("react"), _s = [];
  function Es(e) {
    $s.useEffect(e, _s);
  }
  class Qt {
    constructor() {
      this.currentId = null, this.clear = () => {
        this.currentId !== null && (clearTimeout(this.currentId), this.currentId = null);
      }, this.disposeEffect = () => this.clear;
    }
    static create() {
      return new Qt();
    }
    start(t, r) {
      this.clear(), this.currentId = setTimeout(() => {
        this.currentId = null, r();
      }, t);
    }
  }
  function Ps() {
    const e = Rs(Qt.create).current;
    return Es(e.disposeEffect), e;
  }
  const ln = await w("react");
  let er = true, Tr = false;
  const ks = new Qt(), Os = {
    text: true,
    search: true,
    url: true,
    tel: true,
    email: true,
    password: true,
    number: true,
    date: true,
    month: true,
    week: true,
    time: true,
    datetime: true,
    "datetime-local": true
  };
  function Ms(e) {
    const { type: t, tagName: r } = e;
    return !!(r === "INPUT" && Os[t] && !e.readOnly || r === "TEXTAREA" && !e.readOnly || e.isContentEditable);
  }
  function js(e) {
    e.metaKey || e.altKey || e.ctrlKey || (er = true);
  }
  function pr() {
    er = false;
  }
  function Bs() {
    this.visibilityState === "hidden" && Tr && (er = true);
  }
  function As(e) {
    e.addEventListener("keydown", js, true), e.addEventListener("mousedown", pr, true), e.addEventListener("pointerdown", pr, true), e.addEventListener("touchstart", pr, true), e.addEventListener("visibilitychange", Bs, true);
  }
  function Is(e) {
    const { target: t } = e;
    try {
      return t.matches(":focus-visible");
    } catch {
    }
    return er || Ms(t);
  }
  function zs() {
    const e = ln.useCallback((o) => {
      o != null && As(o.ownerDocument);
    }, []), t = ln.useRef(false);
    function r() {
      return t.current ? (Tr = true, ks.start(100, () => {
        Tr = false;
      }), t.current = false, true) : false;
    }
    function n(o) {
      return Is(o) ? (t.current = true, true) : false;
    }
    return {
      isFocusVisibleRef: t,
      onFocus: n,
      onBlur: r,
      ref: e
    };
  }
  let Ve;
  function ao() {
    if (Ve) return Ve;
    const e = document.createElement("div"), t = document.createElement("div");
    return t.style.width = "10px", t.style.height = "1px", e.appendChild(t), e.dir = "rtl", e.style.fontSize = "14px", e.style.width = "4px", e.style.height = "1px", e.style.position = "absolute", e.style.top = "-1000px", e.style.overflow = "scroll", document.body.appendChild(e), Ve = "reverse", e.scrollLeft > 0 ? Ve = "default" : (e.scrollLeft = 1, e.scrollLeft === 0 && (Ve = "negative")), document.body.removeChild(e), Ve;
  }
  function Ls(e, t) {
    const r = e.scrollLeft;
    if (t !== "rtl") return r;
    switch (ao()) {
      case "negative":
        return e.scrollWidth - e.clientWidth + r;
      case "reverse":
        return e.scrollWidth - e.clientWidth - r;
      default:
        return r;
    }
  }
  function ze(e, t, r = void 0) {
    const n = {};
    return Object.keys(e).forEach((o) => {
      n[o] = e[o].reduce((i, s) => {
        if (s) {
          const c = t(s);
          c !== "" && i.push(c), r && r[s] && i.push(r[s]);
        }
        return i;
      }, []).join(" ");
    }), n;
  }
  function Fs(e) {
    return typeof e == "string";
  }
  function Ws(e, t, r) {
    return e === void 0 || Fs(e) ? t : h({}, t, {
      ownerState: h({}, t.ownerState, r)
    });
  }
  function Ns(e, t = []) {
    if (e === void 0) return {};
    const r = {};
    return Object.keys(e).filter((n) => n.match(/^on[A-Z]/) && typeof e[n] == "function" && !t.includes(n)).forEach((n) => {
      r[n] = e[n];
    }), r;
  }
  function cn(e) {
    if (e === void 0) return {};
    const t = {};
    return Object.keys(e).filter((r) => !(r.match(/^on[A-Z]/) && typeof e[r] == "function")).forEach((r) => {
      t[r] = e[r];
    }), t;
  }
  function Ds(e) {
    const { getSlotProps: t, additionalProps: r, externalSlotProps: n, externalForwardedProps: o, className: i } = e;
    if (!t) {
      const y = I(r == null ? void 0 : r.className, i, o == null ? void 0 : o.className, n == null ? void 0 : n.className), g = h({}, r == null ? void 0 : r.style, o == null ? void 0 : o.style, n == null ? void 0 : n.style), m = h({}, r, o, n);
      return y.length > 0 && (m.className = y), Object.keys(g).length > 0 && (m.style = g), {
        props: m,
        internalRef: void 0
      };
    }
    const s = Ns(h({}, o, n)), c = cn(n), a = cn(o), l = t(s), p = I(l == null ? void 0 : l.className, r == null ? void 0 : r.className, i, o == null ? void 0 : o.className, n == null ? void 0 : n.className), u = h({}, l == null ? void 0 : l.style, r == null ? void 0 : r.style, o == null ? void 0 : o.style, n == null ? void 0 : n.style), d = h({}, l, r, a, c);
    return p.length > 0 && (d.className = p), Object.keys(u).length > 0 && (d.style = u), {
      props: d,
      internalRef: l.ref
    };
  }
  function Hs(e, t, r) {
    return typeof e == "function" ? e(t, r) : e;
  }
  const Ks = [
    "elementType",
    "externalSlotProps",
    "ownerState",
    "skipResolvingSlotProps"
  ];
  function Ot(e) {
    var t;
    const { elementType: r, externalSlotProps: n, ownerState: o, skipResolvingSlotProps: i = false } = e, s = Y(e, Ks), c = i ? {} : Hs(n, o), { props: a, internalRef: l } = Ds(h({}, s, {
      externalSlotProps: c
    })), p = Cr(l, c == null ? void 0 : c.ref, (t = e.additionalProps) == null ? void 0 : t.ref);
    return Ws(r, h({}, a, {
      ref: p
    }), o);
  }
  const Us = await w("react"), lo = Us.createContext(null), Vs = await w("react");
  function co() {
    return Vs.useContext(lo);
  }
  const Ys = typeof Symbol == "function" && Symbol.for, Gs = Ys ? Symbol.for("mui.nested") : "__THEME_NESTED__", Xs = await w("react");
  function qs(e, t) {
    return typeof t == "function" ? t(e) : h({}, e, t);
  }
  function Zs(e) {
    const { children: t, theme: r } = e, n = co(), o = Xs.useMemo(() => {
      const i = n === null ? r : qs(n, r);
      return i != null && (i[Gs] = n !== null), i;
    }, [
      r,
      n
    ]);
    return f.jsx(lo.Provider, {
      value: o,
      children: t
    });
  }
  const Js = [
    "value"
  ], uo = await w("react"), fo = uo.createContext();
  function Qs(e) {
    let { value: t } = e, r = Y(e, Js);
    return f.jsx(fo.Provider, h({
      value: t ?? true
    }, r));
  }
  const po = () => {
    const e = uo.useContext(fo);
    return e ?? false;
  }, mo = await w("react"), ho = mo.createContext(void 0);
  function ea({ value: e, children: t }) {
    return f.jsx(ho.Provider, {
      value: e,
      children: t
    });
  }
  function ta(e) {
    const { theme: t, name: r, props: n } = e;
    if (!t || !t.components || !t.components[r]) return n;
    const o = t.components[r];
    return o.defaultProps ? Sr(o.defaultProps, n) : !o.styleOverrides && !o.variants ? Sr(o, n) : n;
  }
  function ra({ props: e, name: t }) {
    const r = mo.useContext(ho);
    return ta({
      props: e,
      name: t,
      theme: {
        components: r
      }
    });
  }
  await w("react");
  function na(e) {
    const t = Ar(), r = ws() || "", { modularCssLayers: n } = e;
    let o = "mui.global, mui.components, mui.theme, mui.custom, mui.sx";
    return !n || t !== null ? o = "" : typeof n == "string" ? o = n.replace(/mui(?!\.)/g, o) : o = `@layer ${o};`, Lr(() => {
      const i = document.querySelector("head");
      if (!i) return;
      const s = i.firstChild;
      if (o) {
        var c;
        if (s && (c = s.hasAttribute) != null && c.call(s, "data-mui-layer-order") && s.getAttribute("data-mui-layer-order") === r) return;
        const l = document.createElement("style");
        l.setAttribute("data-mui-layer-order", r), l.textContent = o, i.prepend(l);
      } else {
        var a;
        (a = i.querySelector(`style[data-mui-layer-order="${r}"]`)) == null || a.remove();
      }
    }, [
      o,
      r
    ]), o ? f.jsx(ss, {
      styles: o
    }) : null;
  }
  const oa = await w("react"), un = {};
  function dn(e, t, r, n = false) {
    return oa.useMemo(() => {
      const o = e && t[e] || t;
      if (typeof r == "function") {
        const i = r(o), s = e ? h({}, t, {
          [e]: i
        }) : i;
        return n ? () => s : s;
      }
      return e ? h({}, t, {
        [e]: r
      }) : h({}, t, r);
    }, [
      e,
      t,
      r,
      n
    ]);
  }
  function ia(e) {
    const { children: t, theme: r, themeId: n } = e, o = Ar(un), i = co() || un, s = dn(n, o, r), c = dn(n, i, r, true), a = s.direction === "rtl", l = na(s);
    return f.jsx(Zs, {
      theme: c,
      children: f.jsx(Pr.Provider, {
        value: s,
        children: f.jsx(Qs, {
          value: a,
          children: f.jsxs(ea, {
            value: s == null ? void 0 : s.components,
            children: [
              l,
              t
            ]
          })
        })
      })
    });
  }
  function sa(e, t) {
    return h({
      toolbar: {
        minHeight: 56,
        [e.up("xs")]: {
          "@media (orientation: landscape)": {
            minHeight: 48
          }
        },
        [e.up("sm")]: {
          minHeight: 64
        }
      }
    }, t);
  }
  var H = {}, go = {
    exports: {}
  };
  (function(e) {
    function t(r) {
      return r && r.__esModule ? r : {
        default: r
      };
    }
    e.exports = t, e.exports.__esModule = true, e.exports.default = e.exports;
  })(go);
  var yo = go.exports;
  const aa = Te(Vo), la = Te(vs);
  var bo = yo;
  Object.defineProperty(H, "__esModule", {
    value: true
  });
  var fn = H.alpha = wo;
  H.blend = Sa;
  H.colorChannel = void 0;
  var ca = H.darken = Wr;
  H.decomposeColor = le;
  H.emphasize = Co;
  var ua = H.getContrastRatio = ga;
  H.getLuminance = Mt;
  H.hexToRgb = vo;
  H.hslToRgb = So;
  var da = H.lighten = Nr;
  H.private_safeAlpha = ya;
  H.private_safeColorChannel = void 0;
  H.private_safeDarken = ba;
  H.private_safeEmphasize = xa;
  H.private_safeLighten = va;
  H.recomposeColor = Ge;
  H.rgbToHex = ha;
  var pn = bo(aa), fa = bo(la);
  function Fr(e, t = 0, r = 1) {
    return (0, fa.default)(e, t, r);
  }
  function vo(e) {
    e = e.slice(1);
    const t = new RegExp(`.{1,${e.length >= 6 ? 2 : 1}}`, "g");
    let r = e.match(t);
    return r && r[0].length === 1 && (r = r.map((n) => n + n)), r ? `rgb${r.length === 4 ? "a" : ""}(${r.map((n, o) => o < 3 ? parseInt(n, 16) : Math.round(parseInt(n, 16) / 255 * 1e3) / 1e3).join(", ")})` : "";
  }
  function pa(e) {
    const t = e.toString(16);
    return t.length === 1 ? `0${t}` : t;
  }
  function le(e) {
    if (e.type) return e;
    if (e.charAt(0) === "#") return le(vo(e));
    const t = e.indexOf("("), r = e.substring(0, t);
    if ([
      "rgb",
      "rgba",
      "hsl",
      "hsla",
      "color"
    ].indexOf(r) === -1) throw new Error((0, pn.default)(9, e));
    let n = e.substring(t + 1, e.length - 1), o;
    if (r === "color") {
      if (n = n.split(" "), o = n.shift(), n.length === 4 && n[3].charAt(0) === "/" && (n[3] = n[3].slice(1)), [
        "srgb",
        "display-p3",
        "a98-rgb",
        "prophoto-rgb",
        "rec-2020"
      ].indexOf(o) === -1) throw new Error((0, pn.default)(10, o));
    } else n = n.split(",");
    return n = n.map((i) => parseFloat(i)), {
      type: r,
      values: n,
      colorSpace: o
    };
  }
  const xo = (e) => {
    const t = le(e);
    return t.values.slice(0, 3).map((r, n) => t.type.indexOf("hsl") !== -1 && n !== 0 ? `${r}%` : r).join(" ");
  };
  H.colorChannel = xo;
  const ma = (e, t) => {
    try {
      return xo(e);
    } catch {
      return e;
    }
  };
  H.private_safeColorChannel = ma;
  function Ge(e) {
    const { type: t, colorSpace: r } = e;
    let { values: n } = e;
    return t.indexOf("rgb") !== -1 ? n = n.map((o, i) => i < 3 ? parseInt(o, 10) : o) : t.indexOf("hsl") !== -1 && (n[1] = `${n[1]}%`, n[2] = `${n[2]}%`), t.indexOf("color") !== -1 ? n = `${r} ${n.join(" ")}` : n = `${n.join(", ")}`, `${t}(${n})`;
  }
  function ha(e) {
    if (e.indexOf("#") === 0) return e;
    const { values: t } = le(e);
    return `#${t.map((r, n) => pa(n === 3 ? Math.round(255 * r) : r)).join("")}`;
  }
  function So(e) {
    e = le(e);
    const { values: t } = e, r = t[0], n = t[1] / 100, o = t[2] / 100, i = n * Math.min(o, 1 - o), s = (l, p = (l + r / 30) % 12) => o - i * Math.max(Math.min(p - 3, 9 - p, 1), -1);
    let c = "rgb";
    const a = [
      Math.round(s(0) * 255),
      Math.round(s(8) * 255),
      Math.round(s(4) * 255)
    ];
    return e.type === "hsla" && (c += "a", a.push(t[3])), Ge({
      type: c,
      values: a
    });
  }
  function Mt(e) {
    e = le(e);
    let t = e.type === "hsl" || e.type === "hsla" ? le(So(e)).values : e.values;
    return t = t.map((r) => (e.type !== "color" && (r /= 255), r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055) ** 2.4)), Number((0.2126 * t[0] + 0.7152 * t[1] + 0.0722 * t[2]).toFixed(3));
  }
  function ga(e, t) {
    const r = Mt(e), n = Mt(t);
    return (Math.max(r, n) + 0.05) / (Math.min(r, n) + 0.05);
  }
  function wo(e, t) {
    return e = le(e), t = Fr(t), (e.type === "rgb" || e.type === "hsl") && (e.type += "a"), e.type === "color" ? e.values[3] = `/${t}` : e.values[3] = t, Ge(e);
  }
  function ya(e, t, r) {
    try {
      return wo(e, t);
    } catch {
      return e;
    }
  }
  function Wr(e, t) {
    if (e = le(e), t = Fr(t), e.type.indexOf("hsl") !== -1) e.values[2] *= 1 - t;
    else if (e.type.indexOf("rgb") !== -1 || e.type.indexOf("color") !== -1) for (let r = 0; r < 3; r += 1) e.values[r] *= 1 - t;
    return Ge(e);
  }
  function ba(e, t, r) {
    try {
      return Wr(e, t);
    } catch {
      return e;
    }
  }
  function Nr(e, t) {
    if (e = le(e), t = Fr(t), e.type.indexOf("hsl") !== -1) e.values[2] += (100 - e.values[2]) * t;
    else if (e.type.indexOf("rgb") !== -1) for (let r = 0; r < 3; r += 1) e.values[r] += (255 - e.values[r]) * t;
    else if (e.type.indexOf("color") !== -1) for (let r = 0; r < 3; r += 1) e.values[r] += (1 - e.values[r]) * t;
    return Ge(e);
  }
  function va(e, t, r) {
    try {
      return Nr(e, t);
    } catch {
      return e;
    }
  }
  function Co(e, t = 0.15) {
    return Mt(e) > 0.5 ? Wr(e, t) : Nr(e, t);
  }
  function xa(e, t, r) {
    try {
      return Co(e, t);
    } catch {
      return e;
    }
  }
  function Sa(e, t, r, n = 1) {
    const o = (a, l) => Math.round((a ** (1 / n) * (1 - r) + l ** (1 / n) * r) ** n), i = le(e), s = le(t), c = [
      o(i.values[0], s.values[0]),
      o(i.values[1], s.values[1]),
      o(i.values[2], s.values[2])
    ];
    return Ge({
      type: "rgb",
      values: c
    });
  }
  const wa = [
    "mode",
    "contrastThreshold",
    "tonalOffset"
  ], mn = {
    text: {
      primary: "rgba(0, 0, 0, 0.87)",
      secondary: "rgba(0, 0, 0, 0.6)",
      disabled: "rgba(0, 0, 0, 0.38)"
    },
    divider: "rgba(0, 0, 0, 0.12)",
    background: {
      paper: Ie.white,
      default: Ie.white
    },
    action: {
      active: "rgba(0, 0, 0, 0.54)",
      hover: "rgba(0, 0, 0, 0.04)",
      hoverOpacity: 0.04,
      selected: "rgba(0, 0, 0, 0.08)",
      selectedOpacity: 0.08,
      disabled: "rgba(0, 0, 0, 0.26)",
      disabledBackground: "rgba(0, 0, 0, 0.12)",
      disabledOpacity: 0.38,
      focus: "rgba(0, 0, 0, 0.12)",
      focusOpacity: 0.12,
      activatedOpacity: 0.12
    }
  }, mr = {
    text: {
      primary: Ie.white,
      secondary: "rgba(255, 255, 255, 0.7)",
      disabled: "rgba(255, 255, 255, 0.5)",
      icon: "rgba(255, 255, 255, 0.5)"
    },
    divider: "rgba(255, 255, 255, 0.12)",
    background: {
      paper: "#121212",
      default: "#121212"
    },
    action: {
      active: Ie.white,
      hover: "rgba(255, 255, 255, 0.08)",
      hoverOpacity: 0.08,
      selected: "rgba(255, 255, 255, 0.16)",
      selectedOpacity: 0.16,
      disabled: "rgba(255, 255, 255, 0.3)",
      disabledBackground: "rgba(255, 255, 255, 0.12)",
      disabledOpacity: 0.38,
      focus: "rgba(255, 255, 255, 0.12)",
      focusOpacity: 0.12,
      activatedOpacity: 0.24
    }
  };
  function hn(e, t, r, n) {
    const o = n.light || n, i = n.dark || n * 1.5;
    e[t] || (e.hasOwnProperty(r) ? e[t] = e[r] : t === "light" ? e.light = da(e.main, o) : t === "dark" && (e.dark = ca(e.main, i)));
  }
  function Ca(e = "light") {
    return e === "dark" ? {
      main: He[200],
      light: He[50],
      dark: He[400]
    } : {
      main: He[700],
      light: He[400],
      dark: He[800]
    };
  }
  function Ta(e = "light") {
    return e === "dark" ? {
      main: De[200],
      light: De[50],
      dark: De[400]
    } : {
      main: De[500],
      light: De[300],
      dark: De[700]
    };
  }
  function Ra(e = "light") {
    return e === "dark" ? {
      main: Ne[500],
      light: Ne[300],
      dark: Ne[700]
    } : {
      main: Ne[700],
      light: Ne[400],
      dark: Ne[800]
    };
  }
  function $a(e = "light") {
    return e === "dark" ? {
      main: Ke[400],
      light: Ke[300],
      dark: Ke[700]
    } : {
      main: Ke[700],
      light: Ke[500],
      dark: Ke[900]
    };
  }
  function _a(e = "light") {
    return e === "dark" ? {
      main: Ue[400],
      light: Ue[300],
      dark: Ue[700]
    } : {
      main: Ue[800],
      light: Ue[500],
      dark: Ue[900]
    };
  }
  function Ea(e = "light") {
    return e === "dark" ? {
      main: Je[400],
      light: Je[300],
      dark: Je[700]
    } : {
      main: "#ed6c02",
      light: Je[500],
      dark: Je[900]
    };
  }
  function Pa(e) {
    const { mode: t = "light", contrastThreshold: r = 3, tonalOffset: n = 0.2 } = e, o = Y(e, wa), i = e.primary || Ca(t), s = e.secondary || Ta(t), c = e.error || Ra(t), a = e.info || $a(t), l = e.success || _a(t), p = e.warning || Ea(t);
    function u(m) {
      return ua(m, mr.text.primary) >= r ? mr.text.primary : mn.text.primary;
    }
    const d = ({ color: m, name: v, mainShade: T = 500, lightShade: E = 300, darkShade: z = 700 }) => {
      if (m = h({}, m), !m.main && m[T] && (m.main = m[T]), !m.hasOwnProperty("main")) throw new Error(rt(11, v ? ` (${v})` : "", T));
      if (typeof m.main != "string") throw new Error(rt(12, v ? ` (${v})` : "", JSON.stringify(m.main)));
      return hn(m, "light", E, n), hn(m, "dark", z, n), m.contrastText || (m.contrastText = u(m.main)), m;
    }, y = {
      dark: mr,
      light: mn
    };
    return ve(h({
      common: h({}, Ie),
      mode: t,
      primary: d({
        color: i,
        name: "primary"
      }),
      secondary: d({
        color: s,
        name: "secondary",
        mainShade: "A400",
        lightShade: "A200",
        darkShade: "A700"
      }),
      error: d({
        color: c,
        name: "error"
      }),
      warning: d({
        color: p,
        name: "warning"
      }),
      info: d({
        color: a,
        name: "info"
      }),
      success: d({
        color: l,
        name: "success"
      }),
      grey: Uo,
      contrastThreshold: r,
      getContrastText: u,
      augmentColor: d,
      tonalOffset: n
    }, y[t]), o);
  }
  const ka = [
    "fontFamily",
    "fontSize",
    "fontWeightLight",
    "fontWeightRegular",
    "fontWeightMedium",
    "fontWeightBold",
    "htmlFontSize",
    "allVariants",
    "pxToRem"
  ];
  function Oa(e) {
    return Math.round(e * 1e5) / 1e5;
  }
  const gn = {
    textTransform: "uppercase"
  }, yn = '"Roboto", "Helvetica", "Arial", sans-serif';
  function Ma(e, t) {
    const r = typeof t == "function" ? t(e) : t, { fontFamily: n = yn, fontSize: o = 14, fontWeightLight: i = 300, fontWeightRegular: s = 400, fontWeightMedium: c = 500, fontWeightBold: a = 700, htmlFontSize: l = 16, allVariants: p, pxToRem: u } = r, d = Y(r, ka), y = o / 14, g = u || ((T) => `${T / l * y}rem`), m = (T, E, z, C, B) => h({
      fontFamily: n,
      fontWeight: T,
      fontSize: g(E),
      lineHeight: z
    }, n === yn ? {
      letterSpacing: `${Oa(C / E)}em`
    } : {}, B, p), v = {
      h1: m(i, 96, 1.167, -1.5),
      h2: m(i, 60, 1.2, -0.5),
      h3: m(s, 48, 1.167, 0),
      h4: m(s, 34, 1.235, 0.25),
      h5: m(s, 24, 1.334, 0),
      h6: m(c, 20, 1.6, 0.15),
      subtitle1: m(s, 16, 1.75, 0.15),
      subtitle2: m(c, 14, 1.57, 0.1),
      body1: m(s, 16, 1.5, 0.15),
      body2: m(s, 14, 1.43, 0.15),
      button: m(c, 14, 1.75, 0.4, gn),
      caption: m(s, 12, 1.66, 0.4),
      overline: m(s, 12, 2.66, 1, gn),
      inherit: {
        fontFamily: "inherit",
        fontWeight: "inherit",
        fontSize: "inherit",
        lineHeight: "inherit",
        letterSpacing: "inherit"
      }
    };
    return ve(h({
      htmlFontSize: l,
      pxToRem: g,
      fontFamily: n,
      fontSize: o,
      fontWeightLight: i,
      fontWeightRegular: s,
      fontWeightMedium: c,
      fontWeightBold: a
    }, v), d, {
      clone: false
    });
  }
  const ja = 0.2, Ba = 0.14, Aa = 0.12;
  function A(...e) {
    return [
      `${e[0]}px ${e[1]}px ${e[2]}px ${e[3]}px rgba(0,0,0,${ja})`,
      `${e[4]}px ${e[5]}px ${e[6]}px ${e[7]}px rgba(0,0,0,${Ba})`,
      `${e[8]}px ${e[9]}px ${e[10]}px ${e[11]}px rgba(0,0,0,${Aa})`
    ].join(",");
  }
  const Ia = [
    "none",
    A(0, 2, 1, -1, 0, 1, 1, 0, 0, 1, 3, 0),
    A(0, 3, 1, -2, 0, 2, 2, 0, 0, 1, 5, 0),
    A(0, 3, 3, -2, 0, 3, 4, 0, 0, 1, 8, 0),
    A(0, 2, 4, -1, 0, 4, 5, 0, 0, 1, 10, 0),
    A(0, 3, 5, -1, 0, 5, 8, 0, 0, 1, 14, 0),
    A(0, 3, 5, -1, 0, 6, 10, 0, 0, 1, 18, 0),
    A(0, 4, 5, -2, 0, 7, 10, 1, 0, 2, 16, 1),
    A(0, 5, 5, -3, 0, 8, 10, 1, 0, 3, 14, 2),
    A(0, 5, 6, -3, 0, 9, 12, 1, 0, 3, 16, 2),
    A(0, 6, 6, -3, 0, 10, 14, 1, 0, 4, 18, 3),
    A(0, 6, 7, -4, 0, 11, 15, 1, 0, 4, 20, 3),
    A(0, 7, 8, -4, 0, 12, 17, 2, 0, 5, 22, 4),
    A(0, 7, 8, -4, 0, 13, 19, 2, 0, 5, 24, 4),
    A(0, 7, 9, -4, 0, 14, 21, 2, 0, 5, 26, 4),
    A(0, 8, 9, -5, 0, 15, 22, 2, 0, 6, 28, 5),
    A(0, 8, 10, -5, 0, 16, 24, 2, 0, 6, 30, 5),
    A(0, 8, 11, -5, 0, 17, 26, 2, 0, 6, 32, 5),
    A(0, 9, 11, -5, 0, 18, 28, 2, 0, 7, 34, 6),
    A(0, 9, 12, -6, 0, 19, 29, 2, 0, 7, 36, 6),
    A(0, 10, 13, -6, 0, 20, 31, 3, 0, 8, 38, 7),
    A(0, 10, 13, -6, 0, 21, 33, 3, 0, 8, 40, 7),
    A(0, 10, 14, -6, 0, 22, 35, 3, 0, 8, 42, 7),
    A(0, 11, 14, -7, 0, 23, 36, 3, 0, 9, 44, 8),
    A(0, 11, 15, -7, 0, 24, 38, 3, 0, 9, 46, 8)
  ], za = [
    "duration",
    "easing",
    "delay"
  ], La = {
    easeInOut: "cubic-bezier(0.4, 0, 0.2, 1)",
    easeOut: "cubic-bezier(0.0, 0, 0.2, 1)",
    easeIn: "cubic-bezier(0.4, 0, 1, 1)",
    sharp: "cubic-bezier(0.4, 0, 0.6, 1)"
  }, Fa = {
    shortest: 150,
    shorter: 200,
    short: 250,
    standard: 300,
    complex: 375,
    enteringScreen: 225,
    leavingScreen: 195
  };
  function bn(e) {
    return `${Math.round(e)}ms`;
  }
  function Wa(e) {
    if (!e) return 0;
    const t = e / 36;
    return Math.round((4 + 15 * t ** 0.25 + t / 5) * 10);
  }
  function Na(e) {
    const t = h({}, La, e.easing), r = h({}, Fa, e.duration);
    return h({
      getAutoHeightDuration: Wa,
      create: (o = [
        "all"
      ], i = {}) => {
        const { duration: s = r.standard, easing: c = t.easeInOut, delay: a = 0 } = i;
        return Y(i, za), (Array.isArray(o) ? o : [
          o
        ]).map((l) => `${l} ${typeof s == "string" ? s : bn(s)} ${c} ${typeof a == "string" ? a : bn(a)}`).join(",");
      }
    }, e, {
      easing: t,
      duration: r
    });
  }
  const Da = {
    mobileStepper: 1e3,
    fab: 1050,
    speedDial: 1050,
    appBar: 1100,
    drawer: 1200,
    modal: 1300,
    snackbar: 1400,
    tooltip: 1500
  }, Ha = [
    "breakpoints",
    "mixins",
    "spacing",
    "palette",
    "transitions",
    "typography",
    "shape"
  ];
  To = function(e = {}, ...t) {
    const { mixins: r = {}, palette: n = {}, transitions: o = {}, typography: i = {} } = e, s = Y(e, Ha);
    if (e.vars && e.generateCssVars === void 0) throw new Error(rt(18));
    const c = Pa(n), a = Br(e);
    let l = ve(a, {
      mixins: sa(a.breakpoints, r),
      palette: c,
      shadows: Ia.slice(),
      typography: Ma(c, i),
      transitions: Na(o),
      zIndex: h({}, Da)
    });
    return l = ve(l, s), l = t.reduce((p, u) => ve(p, u), l), l.unstable_sxConfig = h({}, it, s == null ? void 0 : s.unstable_sxConfig), l.unstable_sx = function(u) {
      return Dt({
        sx: u,
        theme: this
      });
    }, l;
  };
  const Ro = To();
  await w("react");
  function Ka() {
    const e = Jn(Ro);
    return e[Pt] || e;
  }
  var st = {};
  const Ua = Te(ko);
  var hr = {
    exports: {}
  }, vn;
  function Va() {
    return vn || (vn = 1, function(e) {
      function t(r, n) {
        if (r == null) return {};
        var o = {};
        for (var i in r) if ({}.hasOwnProperty.call(r, i)) {
          if (n.indexOf(i) !== -1) continue;
          o[i] = r[i];
        }
        return o;
      }
      e.exports = t, e.exports.__esModule = true, e.exports.default = e.exports;
    }(hr)), hr.exports;
  }
  const Ya = Te(ci), Ga = Te(ui), Xa = Te(hi), qa = Te(ys), Za = Te(rs), Ja = Te(cs);
  var Xe = yo;
  Object.defineProperty(st, "__esModule", {
    value: true
  });
  var Qa = st.default = fl;
  st.shouldForwardProp = Rt;
  st.systemDefaultTheme = void 0;
  var ie = Xe(Ua), Rr = Xe(Va()), jt = sl(Ya), el = Ga;
  Xe(Xa);
  Xe(qa);
  var tl = Xe(Za), rl = Xe(Ja);
  const nl = [
    "ownerState"
  ], ol = [
    "variants"
  ], il = [
    "name",
    "slot",
    "skipVariantsResolver",
    "skipSx",
    "overridesResolver"
  ];
  function $o(e) {
    if (typeof WeakMap != "function") return null;
    var t = /* @__PURE__ */ new WeakMap(), r = /* @__PURE__ */ new WeakMap();
    return ($o = function(n) {
      return n ? r : t;
    })(e);
  }
  function sl(e, t) {
    if (e && e.__esModule) return e;
    if (e === null || typeof e != "object" && typeof e != "function") return {
      default: e
    };
    var r = $o(t);
    if (r && r.has(e)) return r.get(e);
    var n = {
      __proto__: null
    }, o = Object.defineProperty && Object.getOwnPropertyDescriptor;
    for (var i in e) if (i !== "default" && Object.prototype.hasOwnProperty.call(e, i)) {
      var s = o ? Object.getOwnPropertyDescriptor(e, i) : null;
      s && (s.get || s.set) ? Object.defineProperty(n, i, s) : n[i] = e[i];
    }
    return n.default = e, r && r.set(e, n), n;
  }
  function al(e) {
    return Object.keys(e).length === 0;
  }
  function ll(e) {
    return typeof e == "string" && e.charCodeAt(0) > 96;
  }
  function Rt(e) {
    return e !== "ownerState" && e !== "theme" && e !== "sx" && e !== "as";
  }
  function xn(e, t) {
    return t && e && typeof e == "object" && e.styles && !e.styles.startsWith("@layer") && (e.styles = `@layer ${t}{${String(e.styles)}}`), e;
  }
  const cl = st.systemDefaultTheme = (0, tl.default)(), ul = (e) => e && e.charAt(0).toLowerCase() + e.slice(1);
  function xt({ defaultTheme: e, theme: t, themeId: r }) {
    return al(t) ? e : t[r] || t;
  }
  function dl(e) {
    return e ? (t, r) => r[e] : null;
  }
  function $t(e, t, r) {
    let { ownerState: n } = t, o = (0, Rr.default)(t, nl);
    const i = typeof e == "function" ? e((0, ie.default)({
      ownerState: n
    }, o)) : e;
    if (Array.isArray(i)) return i.flatMap((s) => $t(s, (0, ie.default)({
      ownerState: n
    }, o), r));
    if (i && typeof i == "object" && Array.isArray(i.variants)) {
      const { variants: s = [] } = i;
      let a = (0, Rr.default)(i, ol);
      return s.forEach((l) => {
        let p = true;
        if (typeof l.props == "function" ? p = l.props((0, ie.default)({
          ownerState: n
        }, o, n)) : Object.keys(l.props).forEach((u) => {
          (n == null ? void 0 : n[u]) !== l.props[u] && o[u] !== l.props[u] && (p = false);
        }), p) {
          Array.isArray(a) || (a = [
            a
          ]);
          const u = typeof l.style == "function" ? l.style((0, ie.default)({
            ownerState: n
          }, o, n)) : l.style;
          a.push(r ? xn((0, jt.internal_serializeStyles)(u), r) : u);
        }
      }), a;
    }
    return r ? xn((0, jt.internal_serializeStyles)(i), r) : i;
  }
  function fl(e = {}) {
    const { themeId: t, defaultTheme: r = cl, rootShouldForwardProp: n = Rt, slotShouldForwardProp: o = Rt } = e, i = (s) => (0, rl.default)((0, ie.default)({}, s, {
      theme: xt((0, ie.default)({}, s, {
        defaultTheme: r,
        themeId: t
      }))
    }));
    return i.__mui_systemSx = true, (s, c = {}) => {
      (0, jt.internal_processStyles)(s, (R) => R.filter((k) => !(k != null && k.__mui_systemSx)));
      const { name: a, slot: l, skipVariantsResolver: p, skipSx: u, overridesResolver: d = dl(ul(l)) } = c, y = (0, Rr.default)(c, il), g = a && a.startsWith("Mui") || l ? "components" : "custom", m = p !== void 0 ? p : l && l !== "Root" && l !== "root" || false, v = u || false;
      let T, E = Rt;
      l === "Root" || l === "root" ? E = n : l ? E = o : ll(s) && (E = void 0);
      const z = (0, jt.default)(s, (0, ie.default)({
        shouldForwardProp: E,
        label: T
      }, y)), C = (R) => typeof R == "function" && R.__emotion_real !== R || (0, el.isPlainObject)(R) ? (k) => {
        const W = xt({
          theme: k.theme,
          defaultTheme: r,
          themeId: t
        });
        return $t(R, (0, ie.default)({}, k, {
          theme: W
        }), W.modularCssLayers ? g : void 0);
      } : R, B = (R, ...k) => {
        let W = C(R);
        const K = k ? k.map(C) : [];
        a && d && K.push((N) => {
          const $ = xt((0, ie.default)({}, N, {
            defaultTheme: r,
            themeId: t
          }));
          if (!$.components || !$.components[a] || !$.components[a].styleOverrides) return null;
          const M = $.components[a].styleOverrides, X = {};
          return Object.entries(M).forEach(([J, oe]) => {
            X[J] = $t(oe, (0, ie.default)({}, N, {
              theme: $
            }), $.modularCssLayers ? "theme" : void 0);
          }), d(N, X);
        }), a && !m && K.push((N) => {
          var $;
          const M = xt((0, ie.default)({}, N, {
            defaultTheme: r,
            themeId: t
          })), X = M == null || ($ = M.components) == null || ($ = $[a]) == null ? void 0 : $.variants;
          return $t({
            variants: X
          }, (0, ie.default)({}, N, {
            theme: M
          }), M.modularCssLayers ? "theme" : void 0);
        }), v || K.push(i);
        const O = K.length - k.length;
        if (Array.isArray(R) && O > 0) {
          const N = new Array(O).fill("");
          W = [
            ...R,
            ...N
          ], W.raw = [
            ...R.raw,
            ...N
          ];
        }
        const U = z(W, ...K);
        return s.muiName && (U.muiName = s.muiName), U;
      };
      return z.withConfig && (B.withConfig = z.withConfig), B;
    };
  }
  function pl(e) {
    return e !== "ownerState" && e !== "theme" && e !== "sx" && e !== "as";
  }
  const ml = (e) => pl(e) && e !== "classes", ne = Qa({
    themeId: Pt,
    defaultTheme: Ro,
    rootShouldForwardProp: ml
  }), hl = [
    "theme"
  ];
  await w("react");
  function gl(e) {
    let { theme: t } = e, r = Y(e, hl);
    const n = t[Pt];
    let o = n || t;
    return typeof t != "function" && (n && !n.vars ? o = h({}, n, {
      vars: null
    }) : t && !t.vars && (o = h({}, t, {
      vars: null
    }))), f.jsx(ia, h({}, r, {
      themeId: n ? Pt : void 0,
      theme: o
    }));
  }
  await w("react");
  function ke(e) {
    return ra(e);
  }
  function yl(e) {
    return Ee("MuiSvgIcon", e);
  }
  Pe("MuiSvgIcon", [
    "root",
    "colorPrimary",
    "colorSecondary",
    "colorAction",
    "colorError",
    "colorDisabled",
    "fontSizeInherit",
    "fontSizeSmall",
    "fontSizeMedium",
    "fontSizeLarge"
  ]);
  const bl = [
    "children",
    "className",
    "color",
    "component",
    "fontSize",
    "htmlColor",
    "inheritViewBox",
    "titleAccess",
    "viewBox"
  ], Sn = await w("react"), vl = (e) => {
    const { color: t, fontSize: r, classes: n } = e, o = {
      root: [
        "root",
        t !== "inherit" && `color${Z(t)}`,
        `fontSize${Z(r)}`
      ]
    };
    return ze(o, yl, n);
  }, xl = ne("svg", {
    name: "MuiSvgIcon",
    slot: "Root",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        t.root,
        r.color !== "inherit" && t[`color${Z(r.color)}`],
        t[`fontSize${Z(r.fontSize)}`]
      ];
    }
  })(({ theme: e, ownerState: t }) => {
    var r, n, o, i, s, c, a, l, p, u, d, y, g;
    return {
      userSelect: "none",
      width: "1em",
      height: "1em",
      display: "inline-block",
      fill: t.hasSvgAsChild ? void 0 : "currentColor",
      flexShrink: 0,
      transition: (r = e.transitions) == null || (n = r.create) == null ? void 0 : n.call(r, "fill", {
        duration: (o = e.transitions) == null || (o = o.duration) == null ? void 0 : o.shorter
      }),
      fontSize: {
        inherit: "inherit",
        small: ((i = e.typography) == null || (s = i.pxToRem) == null ? void 0 : s.call(i, 20)) || "1.25rem",
        medium: ((c = e.typography) == null || (a = c.pxToRem) == null ? void 0 : a.call(c, 24)) || "1.5rem",
        large: ((l = e.typography) == null || (p = l.pxToRem) == null ? void 0 : p.call(l, 35)) || "2.1875rem"
      }[t.fontSize],
      color: (u = (d = (e.vars || e).palette) == null || (d = d[t.color]) == null ? void 0 : d.main) != null ? u : {
        action: (y = (e.vars || e).palette) == null || (y = y.action) == null ? void 0 : y.active,
        disabled: (g = (e.vars || e).palette) == null || (g = g.action) == null ? void 0 : g.disabled,
        inherit: void 0
      }[t.color]
    };
  }), $r = Sn.forwardRef(function(t, r) {
    const n = ke({
      props: t,
      name: "MuiSvgIcon"
    }), { children: o, className: i, color: s = "inherit", component: c = "svg", fontSize: a = "medium", htmlColor: l, inheritViewBox: p = false, titleAccess: u, viewBox: d = "0 0 24 24" } = n, y = Y(n, bl), g = Sn.isValidElement(o) && o.type === "svg", m = h({}, n, {
      color: s,
      component: c,
      fontSize: a,
      instanceFontSize: t.fontSize,
      inheritViewBox: p,
      viewBox: d,
      hasSvgAsChild: g
    }), v = {};
    p || (v.viewBox = d);
    const T = vl(m);
    return f.jsxs(xl, h({
      as: c,
      className: I(T.root, i),
      focusable: "false",
      color: l,
      "aria-hidden": u ? void 0 : true,
      role: u ? "img" : void 0,
      ref: r
    }, v, y, g && o.props, {
      ownerState: m,
      children: [
        g ? o.props.children : o,
        u ? f.jsx("title", {
          children: u
        }) : null
      ]
    }));
  });
  $r.muiName = "SvgIcon";
  const wn = await w("react");
  at = function(e, t) {
    function r(n, o) {
      return f.jsx($r, h({
        "data-testid": `${t}Icon`,
        ref: o
      }, n, {
        children: e
      }));
    }
    return r.muiName = $r.muiName, wn.memo(wn.forwardRef(r));
  };
  const Sl = await w("react"), Cn = Sl.createContext(null);
  function wl(e) {
    if (e === void 0) throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    return e;
  }
  const { Children: Cl, cloneElement: _t, isValidElement: Et } = await w("react");
  function Dr(e, t) {
    var r = function(i) {
      return t && Et(i) ? t(i) : i;
    }, n = /* @__PURE__ */ Object.create(null);
    return e && Cl.map(e, function(o) {
      return o;
    }).forEach(function(o) {
      n[o.key] = r(o);
    }), n;
  }
  function Tl(e, t) {
    e = e || {}, t = t || {};
    function r(p) {
      return p in t ? t[p] : e[p];
    }
    var n = /* @__PURE__ */ Object.create(null), o = [];
    for (var i in e) i in t ? o.length && (n[i] = o, o = []) : o.push(i);
    var s, c = {};
    for (var a in t) {
      if (n[a]) for (s = 0; s < n[a].length; s++) {
        var l = n[a][s];
        c[n[a][s]] = r(l);
      }
      c[a] = r(a);
    }
    for (s = 0; s < o.length; s++) c[o[s]] = r(o[s]);
    return c;
  }
  function Ae(e, t, r) {
    return r[t] != null ? r[t] : e.props[t];
  }
  function Rl(e, t) {
    return Dr(e.children, function(r) {
      return _t(r, {
        onExited: t.bind(null, r),
        in: true,
        appear: Ae(r, "appear", e),
        enter: Ae(r, "enter", e),
        exit: Ae(r, "exit", e)
      });
    });
  }
  function $l(e, t, r) {
    var n = Dr(e.children), o = Tl(t, n);
    return Object.keys(o).forEach(function(i) {
      var s = o[i];
      if (Et(s)) {
        var c = i in t, a = i in n, l = t[i], p = Et(l) && !l.props.in;
        a && (!c || p) ? o[i] = _t(s, {
          onExited: r.bind(null, s),
          in: true,
          exit: Ae(s, "exit", e),
          enter: Ae(s, "enter", e)
        }) : !a && c && !p ? o[i] = _t(s, {
          in: false
        }) : a && c && Et(l) && (o[i] = _t(s, {
          onExited: r.bind(null, s),
          in: l.props.in,
          exit: Ae(s, "exit", e),
          enter: Ae(s, "enter", e)
        }));
      }
    }), o;
  }
  const St = await w("react");
  var _l = Object.values || function(e) {
    return Object.keys(e).map(function(t) {
      return e[t];
    });
  }, El = {
    component: "div",
    childFactory: function(t) {
      return t;
    }
  }, Hr = function(e) {
    Lo(t, e);
    function t(n, o) {
      var i;
      i = e.call(this, n, o) || this;
      var s = i.handleExited.bind(wl(i));
      return i.state = {
        contextValue: {
          isMounting: true
        },
        handleExited: s,
        firstRender: true
      }, i;
    }
    var r = t.prototype;
    return r.componentDidMount = function() {
      this.mounted = true, this.setState({
        contextValue: {
          isMounting: false
        }
      });
    }, r.componentWillUnmount = function() {
      this.mounted = false;
    }, t.getDerivedStateFromProps = function(o, i) {
      var s = i.children, c = i.handleExited, a = i.firstRender;
      return {
        children: a ? Rl(o, c) : $l(o, s, c),
        firstRender: false
      };
    }, r.handleExited = function(o, i) {
      var s = Dr(this.props.children);
      o.key in s || (o.props.onExited && o.props.onExited(i), this.mounted && this.setState(function(c) {
        var a = h({}, c.children);
        return delete a[o.key], {
          children: a
        };
      }));
    }, r.render = function() {
      var o = this.props, i = o.component, s = o.childFactory, c = Y(o, [
        "component",
        "childFactory"
      ]), a = this.state.contextValue, l = _l(this.state.children).map(s);
      return delete c.appear, delete c.enter, delete c.exit, i === null ? St.createElement(Cn.Provider, {
        value: a
      }, l) : St.createElement(Cn.Provider, {
        value: a
      }, St.createElement(i, c, l));
    }, t;
  }(St.Component);
  Hr.propTypes = {};
  Hr.defaultProps = El;
  const Tn = await w("react");
  function Pl(e) {
    const { className: t, classes: r, pulsate: n = false, rippleX: o, rippleY: i, rippleSize: s, in: c, onExited: a, timeout: l } = e, [p, u] = Tn.useState(false), d = I(t, r.ripple, r.rippleVisible, n && r.ripplePulsate), y = {
      width: s,
      height: s,
      top: -(s / 2) + i,
      left: -(s / 2) + o
    }, g = I(r.child, p && r.childLeaving, n && r.childPulsate);
    return !c && !p && u(true), Tn.useEffect(() => {
      if (!c && a != null) {
        const m = setTimeout(a, l);
        return () => {
          clearTimeout(m);
        };
      }
    }, [
      a,
      c,
      l
    ]), f.jsx("span", {
      className: d,
      style: y,
      children: f.jsx("span", {
        className: g
      })
    });
  }
  const se = Pe("MuiTouchRipple", [
    "root",
    "ripple",
    "rippleVisible",
    "ripplePulsate",
    "child",
    "childLeaving",
    "childPulsate"
  ]), kl = [
    "center",
    "classes",
    "className"
  ];
  let tr = (e) => e, Rn, $n, _n, En;
  const te = await w("react"), _r = 550, Ol = 80, Ml = Bt(Rn || (Rn = tr`
  0% {
    transform: scale(0);
    opacity: 0.1;
  }

  100% {
    transform: scale(1);
    opacity: 0.3;
  }
`)), jl = Bt($n || ($n = tr`
  0% {
    opacity: 1;
  }

  100% {
    opacity: 0;
  }
`)), Bl = Bt(_n || (_n = tr`
  0% {
    transform: scale(1);
  }

  50% {
    transform: scale(0.92);
  }

  100% {
    transform: scale(1);
  }
`)), Al = ne("span", {
    name: "MuiTouchRipple",
    slot: "Root"
  })({
    overflow: "hidden",
    pointerEvents: "none",
    position: "absolute",
    zIndex: 0,
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    borderRadius: "inherit"
  }), Il = ne(Pl, {
    name: "MuiTouchRipple",
    slot: "Ripple"
  })(En || (En = tr`
  opacity: 0;
  position: absolute;

  &.${0} {
    opacity: 0.3;
    transform: scale(1);
    animation-name: ${0};
    animation-duration: ${0}ms;
    animation-timing-function: ${0};
  }

  &.${0} {
    animation-duration: ${0}ms;
  }

  & .${0} {
    opacity: 1;
    display: block;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    background-color: currentColor;
  }

  & .${0} {
    opacity: 0;
    animation-name: ${0};
    animation-duration: ${0}ms;
    animation-timing-function: ${0};
  }

  & .${0} {
    position: absolute;
    /* @noflip */
    left: 0px;
    top: 0;
    animation-name: ${0};
    animation-duration: 2500ms;
    animation-timing-function: ${0};
    animation-iteration-count: infinite;
    animation-delay: 200ms;
  }
`), se.rippleVisible, Ml, _r, ({ theme: e }) => e.transitions.easing.easeInOut, se.ripplePulsate, ({ theme: e }) => e.transitions.duration.shorter, se.child, se.childLeaving, jl, _r, ({ theme: e }) => e.transitions.easing.easeInOut, se.childPulsate, Bl, ({ theme: e }) => e.transitions.easing.easeInOut), zl = te.forwardRef(function(t, r) {
    const n = ke({
      props: t,
      name: "MuiTouchRipple"
    }), { center: o = false, classes: i = {}, className: s } = n, c = Y(n, kl), [a, l] = te.useState([]), p = te.useRef(0), u = te.useRef(null);
    te.useEffect(() => {
      u.current && (u.current(), u.current = null);
    }, [
      a
    ]);
    const d = te.useRef(false), y = Ps(), g = te.useRef(null), m = te.useRef(null), v = te.useCallback((C) => {
      const { pulsate: B, rippleX: R, rippleY: k, rippleSize: W, cb: K } = C;
      l((O) => [
        ...O,
        f.jsx(Il, {
          classes: {
            ripple: I(i.ripple, se.ripple),
            rippleVisible: I(i.rippleVisible, se.rippleVisible),
            ripplePulsate: I(i.ripplePulsate, se.ripplePulsate),
            child: I(i.child, se.child),
            childLeaving: I(i.childLeaving, se.childLeaving),
            childPulsate: I(i.childPulsate, se.childPulsate)
          },
          timeout: _r,
          pulsate: B,
          rippleX: R,
          rippleY: k,
          rippleSize: W
        }, p.current)
      ]), p.current += 1, u.current = K;
    }, [
      i
    ]), T = te.useCallback((C = {}, B = {}, R = () => {
    }) => {
      const { pulsate: k = false, center: W = o || B.pulsate, fakeElement: K = false } = B;
      if ((C == null ? void 0 : C.type) === "mousedown" && d.current) {
        d.current = false;
        return;
      }
      (C == null ? void 0 : C.type) === "touchstart" && (d.current = true);
      const O = K ? null : m.current, U = O ? O.getBoundingClientRect() : {
        width: 0,
        height: 0,
        left: 0,
        top: 0
      };
      let N, $, M;
      if (W || C === void 0 || C.clientX === 0 && C.clientY === 0 || !C.clientX && !C.touches) N = Math.round(U.width / 2), $ = Math.round(U.height / 2);
      else {
        const { clientX: X, clientY: J } = C.touches && C.touches.length > 0 ? C.touches[0] : C;
        N = Math.round(X - U.left), $ = Math.round(J - U.top);
      }
      if (W) M = Math.sqrt((2 * U.width ** 2 + U.height ** 2) / 3), M % 2 === 0 && (M += 1);
      else {
        const X = Math.max(Math.abs((O ? O.clientWidth : 0) - N), N) * 2 + 2, J = Math.max(Math.abs((O ? O.clientHeight : 0) - $), $) * 2 + 2;
        M = Math.sqrt(X ** 2 + J ** 2);
      }
      C != null && C.touches ? g.current === null && (g.current = () => {
        v({
          pulsate: k,
          rippleX: N,
          rippleY: $,
          rippleSize: M,
          cb: R
        });
      }, y.start(Ol, () => {
        g.current && (g.current(), g.current = null);
      })) : v({
        pulsate: k,
        rippleX: N,
        rippleY: $,
        rippleSize: M,
        cb: R
      });
    }, [
      o,
      v,
      y
    ]), E = te.useCallback(() => {
      T({}, {
        pulsate: true
      });
    }, [
      T
    ]), z = te.useCallback((C, B) => {
      if (y.clear(), (C == null ? void 0 : C.type) === "touchend" && g.current) {
        g.current(), g.current = null, y.start(0, () => {
          z(C, B);
        });
        return;
      }
      g.current = null, l((R) => R.length > 0 ? R.slice(1) : R), u.current = B;
    }, [
      y
    ]);
    return te.useImperativeHandle(r, () => ({
      pulsate: E,
      start: T,
      stop: z
    }), [
      E,
      T,
      z
    ]), f.jsx(Al, h({
      className: I(se.root, i.root, s),
      ref: m
    }, c, {
      children: f.jsx(Hr, {
        component: null,
        exit: true,
        children: a
      })
    }));
  });
  function Ll(e) {
    return Ee("MuiButtonBase", e);
  }
  const Fl = Pe("MuiButtonBase", [
    "root",
    "disabled",
    "focusVisible"
  ]), Wl = [
    "action",
    "centerRipple",
    "children",
    "className",
    "component",
    "disabled",
    "disableRipple",
    "disableTouchRipple",
    "focusRipple",
    "focusVisibleClassName",
    "LinkComponent",
    "onBlur",
    "onClick",
    "onContextMenu",
    "onDragLeave",
    "onFocus",
    "onFocusVisible",
    "onKeyDown",
    "onKeyUp",
    "onMouseDown",
    "onMouseLeave",
    "onMouseUp",
    "onTouchEnd",
    "onTouchMove",
    "onTouchStart",
    "tabIndex",
    "TouchRippleProps",
    "touchRippleRef",
    "type"
  ], we = await w("react"), Nl = (e) => {
    const { disabled: t, focusVisible: r, focusVisibleClassName: n, classes: o } = e, s = ze({
      root: [
        "root",
        t && "disabled",
        r && "focusVisible"
      ]
    }, Ll, o);
    return r && n && (s.root += ` ${n}`), s;
  }, Dl = ne("button", {
    name: "MuiButtonBase",
    slot: "Root",
    overridesResolver: (e, t) => t.root
  })({
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    position: "relative",
    boxSizing: "border-box",
    WebkitTapHighlightColor: "transparent",
    backgroundColor: "transparent",
    outline: 0,
    border: 0,
    margin: 0,
    borderRadius: 0,
    padding: 0,
    cursor: "pointer",
    userSelect: "none",
    verticalAlign: "middle",
    MozAppearance: "none",
    WebkitAppearance: "none",
    textDecoration: "none",
    color: "inherit",
    "&::-moz-focus-inner": {
      borderStyle: "none"
    },
    [`&.${Fl.disabled}`]: {
      pointerEvents: "none",
      cursor: "default"
    },
    "@media print": {
      colorAdjust: "exact"
    }
  }), Kr = we.forwardRef(function(t, r) {
    const n = ke({
      props: t,
      name: "MuiButtonBase"
    }), { action: o, centerRipple: i = false, children: s, className: c, component: a = "button", disabled: l = false, disableRipple: p = false, disableTouchRipple: u = false, focusRipple: d = false, LinkComponent: y = "a", onBlur: g, onClick: m, onContextMenu: v, onDragLeave: T, onFocus: E, onFocusVisible: z, onKeyDown: C, onKeyUp: B, onMouseDown: R, onMouseLeave: k, onMouseUp: W, onTouchEnd: K, onTouchMove: O, onTouchStart: U, tabIndex: N = 0, TouchRippleProps: $, touchRippleRef: M, type: X } = n, J = Y(n, Wl), oe = we.useRef(null), ee = we.useRef(null), Oe = Cr(ee, M), { isFocusVisibleRef: he, onFocus: ge, onBlur: nr, ref: or } = zs(), [ye, Le] = we.useState(false);
    l && ye && Le(false), we.useImperativeHandle(o, () => ({
      focusVisible: () => {
        Le(true), oe.current.focus();
      }
    }), []);
    const [de, lt] = we.useState(false);
    we.useEffect(() => {
      lt(true);
    }, []);
    const ct = de && !p && !l;
    we.useEffect(() => {
      ye && d && !p && de && ee.current.pulsate();
    }, [
      p,
      d,
      ye,
      de
    ]);
    function fe(S, qe, We = u) {
      return Be((vt) => (qe && qe(vt), !We && ee.current && ee.current[S](vt), true));
    }
    const ut = fe("start", R), ir = fe("stop", v), dt = fe("stop", T), sr = fe("stop", W), ft = fe("stop", (S) => {
      ye && S.preventDefault(), k && k(S);
    }), ar = fe("start", U), pt = fe("stop", K), pe = fe("stop", O), xe = fe("stop", (S) => {
      nr(S), he.current === false && Le(false), g && g(S);
    }, false), mt = Be((S) => {
      oe.current || (oe.current = S.currentTarget), ge(S), he.current === true && (Le(true), z && z(S)), E && E(S);
    }), Se = () => {
      const S = oe.current;
      return a && a !== "button" && !(S.tagName === "A" && S.href);
    }, Me = we.useRef(false), ht = Be((S) => {
      d && !Me.current && ye && ee.current && S.key === " " && (Me.current = true, ee.current.stop(S, () => {
        ee.current.start(S);
      })), S.target === S.currentTarget && Se() && S.key === " " && S.preventDefault(), C && C(S), S.target === S.currentTarget && Se() && S.key === "Enter" && !l && (S.preventDefault(), m && m(S));
    }), gt = Be((S) => {
      d && S.key === " " && ee.current && ye && !S.defaultPrevented && (Me.current = false, ee.current.stop(S, () => {
        ee.current.pulsate(S);
      })), B && B(S), m && S.target === S.currentTarget && Se() && S.key === " " && !S.defaultPrevented && m(S);
    });
    let Fe = a;
    Fe === "button" && (J.href || J.to) && (Fe = y);
    const je = {};
    Fe === "button" ? (je.type = X === void 0 ? "button" : X, je.disabled = l) : (!J.href && !J.to && (je.role = "button"), l && (je["aria-disabled"] = l));
    const lr = Cr(r, or, oe), yt = h({}, n, {
      centerRipple: i,
      component: a,
      disabled: l,
      disableRipple: p,
      disableTouchRipple: u,
      focusRipple: d,
      tabIndex: N,
      focusVisible: ye
    }), bt = Nl(yt);
    return f.jsxs(Dl, h({
      as: Fe,
      className: I(bt.root, c),
      ownerState: yt,
      onBlur: xe,
      onClick: m,
      onContextMenu: ir,
      onFocus: mt,
      onKeyDown: ht,
      onKeyUp: gt,
      onMouseDown: ut,
      onMouseLeave: ft,
      onMouseUp: sr,
      onDragLeave: dt,
      onTouchEnd: pt,
      onTouchMove: pe,
      onTouchStart: ar,
      ref: lr,
      tabIndex: l ? -1 : N,
      type: X
    }, je, J, {
      children: [
        s,
        ct ? f.jsx(zl, h({
          ref: Oe,
          center: i
        }, $)) : null
      ]
    }));
  });
  function Hl(e) {
    return Ee("MuiIconButton", e);
  }
  const Kl = Pe("MuiIconButton", [
    "root",
    "disabled",
    "colorInherit",
    "colorPrimary",
    "colorSecondary",
    "colorError",
    "colorInfo",
    "colorSuccess",
    "colorWarning",
    "edgeStart",
    "edgeEnd",
    "sizeSmall",
    "sizeMedium",
    "sizeLarge"
  ]), Ul = [
    "edge",
    "children",
    "className",
    "color",
    "disabled",
    "disableFocusRipple",
    "size"
  ], Vl = await w("react"), Yl = (e) => {
    const { classes: t, disabled: r, color: n, edge: o, size: i } = e, s = {
      root: [
        "root",
        r && "disabled",
        n !== "default" && `color${Z(n)}`,
        o && `edge${Z(o)}`,
        `size${Z(i)}`
      ]
    };
    return ze(s, Hl, t);
  }, Gl = ne(Kr, {
    name: "MuiIconButton",
    slot: "Root",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        t.root,
        r.color !== "default" && t[`color${Z(r.color)}`],
        r.edge && t[`edge${Z(r.edge)}`],
        t[`size${Z(r.size)}`]
      ];
    }
  })(({ theme: e, ownerState: t }) => h({
    textAlign: "center",
    flex: "0 0 auto",
    fontSize: e.typography.pxToRem(24),
    padding: 8,
    borderRadius: "50%",
    overflow: "visible",
    color: (e.vars || e).palette.action.active,
    transition: e.transitions.create("background-color", {
      duration: e.transitions.duration.shortest
    })
  }, !t.disableRipple && {
    "&:hover": {
      backgroundColor: e.vars ? `rgba(${e.vars.palette.action.activeChannel} / ${e.vars.palette.action.hoverOpacity})` : fn(e.palette.action.active, e.palette.action.hoverOpacity),
      "@media (hover: none)": {
        backgroundColor: "transparent"
      }
    }
  }, t.edge === "start" && {
    marginLeft: t.size === "small" ? -3 : -12
  }, t.edge === "end" && {
    marginRight: t.size === "small" ? -3 : -12
  }), ({ theme: e, ownerState: t }) => {
    var r;
    const n = (r = (e.vars || e).palette) == null ? void 0 : r[t.color];
    return h({}, t.color === "inherit" && {
      color: "inherit"
    }, t.color !== "inherit" && t.color !== "default" && h({
      color: n == null ? void 0 : n.main
    }, !t.disableRipple && {
      "&:hover": h({}, n && {
        backgroundColor: e.vars ? `rgba(${n.mainChannel} / ${e.vars.palette.action.hoverOpacity})` : fn(n.main, e.palette.action.hoverOpacity)
      }, {
        "@media (hover: none)": {
          backgroundColor: "transparent"
        }
      })
    }), t.size === "small" && {
      padding: 5,
      fontSize: e.typography.pxToRem(18)
    }, t.size === "large" && {
      padding: 12,
      fontSize: e.typography.pxToRem(28)
    }, {
      [`&.${Kl.disabled}`]: {
        backgroundColor: "transparent",
        color: (e.vars || e).palette.action.disabled
      }
    });
  }), Xl = Vl.forwardRef(function(t, r) {
    const n = ke({
      props: t,
      name: "MuiIconButton"
    }), { edge: o = false, children: i, className: s, color: c = "default", disabled: a = false, disableFocusRipple: l = false, size: p = "medium" } = n, u = Y(n, Ul), d = h({}, n, {
      edge: o,
      color: c,
      disabled: a,
      disableFocusRipple: l,
      size: p
    }), y = Yl(d);
    return f.jsx(Gl, h({
      className: I(y.root, s),
      centerRipple: true,
      focusRipple: !l,
      disabled: a,
      ref: r
    }, u, {
      ownerState: d,
      children: i
    }));
  });
  function ql(e) {
    return Ee("MuiTypography", e);
  }
  Pe("MuiTypography", [
    "root",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "subtitle1",
    "subtitle2",
    "body1",
    "body2",
    "inherit",
    "button",
    "caption",
    "overline",
    "alignLeft",
    "alignRight",
    "alignCenter",
    "alignJustify",
    "noWrap",
    "gutterBottom",
    "paragraph"
  ]);
  const Zl = [
    "align",
    "className",
    "component",
    "gutterBottom",
    "noWrap",
    "paragraph",
    "variant",
    "variantMapping"
  ], Jl = await w("react"), Ql = (e) => {
    const { align: t, gutterBottom: r, noWrap: n, paragraph: o, variant: i, classes: s } = e, c = {
      root: [
        "root",
        i,
        e.align !== "inherit" && `align${Z(t)}`,
        r && "gutterBottom",
        n && "noWrap",
        o && "paragraph"
      ]
    };
    return ze(c, ql, s);
  }, ec = ne("span", {
    name: "MuiTypography",
    slot: "Root",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        t.root,
        r.variant && t[r.variant],
        r.align !== "inherit" && t[`align${Z(r.align)}`],
        r.noWrap && t.noWrap,
        r.gutterBottom && t.gutterBottom,
        r.paragraph && t.paragraph
      ];
    }
  })(({ theme: e, ownerState: t }) => h({
    margin: 0
  }, t.variant === "inherit" && {
    font: "inherit"
  }, t.variant !== "inherit" && e.typography[t.variant], t.align !== "inherit" && {
    textAlign: t.align
  }, t.noWrap && {
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap"
  }, t.gutterBottom && {
    marginBottom: "0.35em"
  }, t.paragraph && {
    marginBottom: 16
  })), Pn = {
    h1: "h1",
    h2: "h2",
    h3: "h3",
    h4: "h4",
    h5: "h5",
    h6: "h6",
    subtitle1: "h6",
    subtitle2: "h6",
    body1: "p",
    body2: "p",
    inherit: "p"
  }, tc = {
    primary: "primary.main",
    textPrimary: "text.primary",
    secondary: "secondary.main",
    textSecondary: "text.secondary",
    error: "error.main"
  }, rc = (e) => tc[e] || e, me = Jl.forwardRef(function(t, r) {
    const n = ke({
      props: t,
      name: "MuiTypography"
    }), o = rc(n.color), i = Qn(h({}, n, {
      color: o
    })), { align: s = "inherit", className: c, component: a, gutterBottom: l = false, noWrap: p = false, paragraph: u = false, variant: d = "body1", variantMapping: y = Pn } = i, g = Y(i, Zl), m = h({}, i, {
      align: s,
      color: o,
      className: c,
      component: a,
      gutterBottom: l,
      noWrap: p,
      paragraph: u,
      variant: d,
      variantMapping: y
    }), v = a || (u ? "p" : y[d] || Pn[d]) || "span", T = Ql(m);
    return f.jsx(ec, h({
      as: v,
      ref: r,
      ownerState: m,
      className: I(T.root, c)
    }, g));
  });
  function nc(e) {
    return Ee("MuiTab", e);
  }
  const $e = Pe("MuiTab", [
    "root",
    "labelIcon",
    "textColorInherit",
    "textColorPrimary",
    "textColorSecondary",
    "selected",
    "disabled",
    "fullWidth",
    "wrapped",
    "iconWrapper"
  ]), oc = [
    "className",
    "disabled",
    "disableFocusRipple",
    "fullWidth",
    "icon",
    "iconPosition",
    "indicator",
    "label",
    "onChange",
    "onClick",
    "onFocus",
    "selected",
    "selectionFollowsFocus",
    "textColor",
    "value",
    "wrapped"
  ], et = await w("react"), ic = (e) => {
    const { classes: t, textColor: r, fullWidth: n, wrapped: o, icon: i, label: s, selected: c, disabled: a } = e, l = {
      root: [
        "root",
        i && s && "labelIcon",
        `textColor${Z(r)}`,
        n && "fullWidth",
        o && "wrapped",
        c && "selected",
        a && "disabled"
      ],
      iconWrapper: [
        "iconWrapper"
      ]
    };
    return ze(l, nc, t);
  }, sc = ne(Kr, {
    name: "MuiTab",
    slot: "Root",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        t.root,
        r.label && r.icon && t.labelIcon,
        t[`textColor${Z(r.textColor)}`],
        r.fullWidth && t.fullWidth,
        r.wrapped && t.wrapped,
        {
          [`& .${$e.iconWrapper}`]: t.iconWrapper
        }
      ];
    }
  })(({ theme: e, ownerState: t }) => h({}, e.typography.button, {
    maxWidth: 360,
    minWidth: 90,
    position: "relative",
    minHeight: 48,
    flexShrink: 0,
    padding: "12px 16px",
    overflow: "hidden",
    whiteSpace: "normal",
    textAlign: "center"
  }, t.label && {
    flexDirection: t.iconPosition === "top" || t.iconPosition === "bottom" ? "column" : "row"
  }, {
    lineHeight: 1.25
  }, t.icon && t.label && {
    minHeight: 72,
    paddingTop: 9,
    paddingBottom: 9,
    [`& > .${$e.iconWrapper}`]: h({}, t.iconPosition === "top" && {
      marginBottom: 6
    }, t.iconPosition === "bottom" && {
      marginTop: 6
    }, t.iconPosition === "start" && {
      marginRight: e.spacing(1)
    }, t.iconPosition === "end" && {
      marginLeft: e.spacing(1)
    })
  }, t.textColor === "inherit" && {
    color: "inherit",
    opacity: 0.6,
    [`&.${$e.selected}`]: {
      opacity: 1
    },
    [`&.${$e.disabled}`]: {
      opacity: (e.vars || e).palette.action.disabledOpacity
    }
  }, t.textColor === "primary" && {
    color: (e.vars || e).palette.text.secondary,
    [`&.${$e.selected}`]: {
      color: (e.vars || e).palette.primary.main
    },
    [`&.${$e.disabled}`]: {
      color: (e.vars || e).palette.text.disabled
    }
  }, t.textColor === "secondary" && {
    color: (e.vars || e).palette.text.secondary,
    [`&.${$e.selected}`]: {
      color: (e.vars || e).palette.secondary.main
    },
    [`&.${$e.disabled}`]: {
      color: (e.vars || e).palette.text.disabled
    }
  }, t.fullWidth && {
    flexShrink: 1,
    flexGrow: 1,
    flexBasis: 0,
    maxWidth: "none"
  }, t.wrapped && {
    fontSize: e.typography.pxToRem(12)
  })), ac = et.forwardRef(function(t, r) {
    const n = ke({
      props: t,
      name: "MuiTab"
    }), { className: o, disabled: i = false, disableFocusRipple: s = false, fullWidth: c, icon: a, iconPosition: l = "top", indicator: p, label: u, onChange: d, onClick: y, onFocus: g, selected: m, selectionFollowsFocus: v, textColor: T = "inherit", value: E, wrapped: z = false } = n, C = Y(n, oc), B = h({}, n, {
      disabled: i,
      disableFocusRipple: s,
      selected: m,
      icon: !!a,
      iconPosition: l,
      label: !!u,
      fullWidth: c,
      textColor: T,
      wrapped: z
    }), R = ic(B), k = a && u && et.isValidElement(a) ? et.cloneElement(a, {
      className: I(R.iconWrapper, a.props.className)
    }) : a, W = (O) => {
      !m && d && d(O, E), y && y(O);
    }, K = (O) => {
      v && !m && d && d(O, E), g && g(O);
    };
    return f.jsxs(sc, h({
      focusRipple: !s,
      className: I(R.root, o),
      ref: r,
      role: "tab",
      "aria-selected": m,
      disabled: i,
      onClick: W,
      onFocus: K,
      ownerState: B,
      tabIndex: m ? 0 : -1
    }, C, {
      children: [
        l === "top" || l === "start" ? f.jsxs(et.Fragment, {
          children: [
            k,
            u
          ]
        }) : f.jsxs(et.Fragment, {
          children: [
            u,
            k
          ]
        }),
        p
      ]
    }));
  });
  await w("react");
  const lc = at(f.jsx("path", {
    d: "M15.41 16.09l-4.58-4.59 4.58-4.59L14 5.5l-6 6 6 6z"
  }), "KeyboardArrowLeft");
  await w("react");
  const cc = at(f.jsx("path", {
    d: "M8.59 16.34l4.58-4.59-4.58-4.59L10 5.75l6 6-6 6z"
  }), "KeyboardArrowRight");
  function uc(e) {
    return (1 + Math.sin(Math.PI * e - Math.PI / 2)) / 2;
  }
  function dc(e, t, r, n = {}, o = () => {
  }) {
    const { ease: i = uc, duration: s = 300 } = n;
    let c = null;
    const a = t[e];
    let l = false;
    const p = () => {
      l = true;
    }, u = (d) => {
      if (l) {
        o(new Error("Animation cancelled"));
        return;
      }
      c === null && (c = d);
      const y = Math.min(1, (d - c) / s);
      if (t[e] = i(y) * (r - a) + a, y >= 1) {
        requestAnimationFrame(() => {
          o(null);
        });
        return;
      }
      requestAnimationFrame(u);
    };
    return a === r ? (o(new Error("Element already at target position")), p) : (requestAnimationFrame(u), p);
  }
  const fc = [
    "onChange"
  ], gr = await w("react"), pc = {
    width: 99,
    height: 99,
    position: "absolute",
    top: -9999,
    overflow: "scroll"
  };
  function mc(e) {
    const { onChange: t } = e, r = Y(e, fc), n = gr.useRef(), o = gr.useRef(null), i = () => {
      n.current = o.current.offsetHeight - o.current.clientHeight;
    };
    return Lr(() => {
      const s = oo(() => {
        const a = n.current;
        i(), a !== n.current && t(n.current);
      }), c = so(o.current);
      return c.addEventListener("resize", s), () => {
        s.clear(), c.removeEventListener("resize", s);
      };
    }, [
      t
    ]), gr.useEffect(() => {
      i(), t(n.current);
    }, [
      t
    ]), f.jsx("div", h({
      style: pc
    }, r, {
      ref: o
    }));
  }
  function hc(e) {
    return Ee("MuiTabScrollButton", e);
  }
  const gc = Pe("MuiTabScrollButton", [
    "root",
    "vertical",
    "horizontal",
    "disabled"
  ]), yc = [
    "className",
    "slots",
    "slotProps",
    "direction",
    "orientation",
    "disabled"
  ], bc = await w("react"), vc = (e) => {
    const { classes: t, orientation: r, disabled: n } = e;
    return ze({
      root: [
        "root",
        r,
        n && "disabled"
      ]
    }, hc, t);
  }, xc = ne(Kr, {
    name: "MuiTabScrollButton",
    slot: "Root",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        t.root,
        r.orientation && t[r.orientation]
      ];
    }
  })(({ ownerState: e }) => h({
    width: 40,
    flexShrink: 0,
    opacity: 0.8,
    [`&.${gc.disabled}`]: {
      opacity: 0
    }
  }, e.orientation === "vertical" && {
    width: "100%",
    height: 40,
    "& svg": {
      transform: `rotate(${e.isRtl ? -90 : 90}deg)`
    }
  })), Sc = bc.forwardRef(function(t, r) {
    var n, o;
    const i = ke({
      props: t,
      name: "MuiTabScrollButton"
    }), { className: s, slots: c = {}, slotProps: a = {}, direction: l } = i, p = Y(i, yc), u = po(), d = h({
      isRtl: u
    }, i), y = vc(d), g = (n = c.StartScrollButtonIcon) != null ? n : lc, m = (o = c.EndScrollButtonIcon) != null ? o : cc, v = Ot({
      elementType: g,
      externalSlotProps: a.startScrollButtonIcon,
      additionalProps: {
        fontSize: "small"
      },
      ownerState: d
    }), T = Ot({
      elementType: m,
      externalSlotProps: a.endScrollButtonIcon,
      additionalProps: {
        fontSize: "small"
      },
      ownerState: d
    });
    return f.jsx(xc, h({
      component: "div",
      className: I(y.root, s),
      ref: r,
      role: null,
      ownerState: d,
      tabIndex: null
    }, p, {
      children: l === "left" ? f.jsx(g, h({}, v)) : f.jsx(m, h({}, T))
    }));
  });
  function wc(e) {
    return Ee("MuiTabs", e);
  }
  const yr = Pe("MuiTabs", [
    "root",
    "vertical",
    "flexContainer",
    "flexContainerVertical",
    "centered",
    "scroller",
    "fixed",
    "scrollableX",
    "scrollableY",
    "hideScrollbar",
    "scrollButtons",
    "scrollButtonsHideMobile",
    "indicator"
  ]), Cc = [
    "aria-label",
    "aria-labelledby",
    "action",
    "centered",
    "children",
    "className",
    "component",
    "allowScrollButtonsMobile",
    "indicatorColor",
    "onChange",
    "orientation",
    "ScrollButtonComponent",
    "scrollButtons",
    "selectionFollowsFocus",
    "slots",
    "slotProps",
    "TabIndicatorProps",
    "TabScrollButtonProps",
    "textColor",
    "value",
    "variant",
    "visibleScrollbar"
  ], G = await w("react"), kn = (e, t) => e === t ? e.firstChild : t && t.nextElementSibling ? t.nextElementSibling : e.firstChild, On = (e, t) => e === t ? e.lastChild : t && t.previousElementSibling ? t.previousElementSibling : e.lastChild, wt = (e, t, r) => {
    let n = false, o = r(e, t);
    for (; o; ) {
      if (o === e.firstChild) {
        if (n) return;
        n = true;
      }
      const i = o.disabled || o.getAttribute("aria-disabled") === "true";
      if (!o.hasAttribute("tabindex") || i) o = r(e, o);
      else {
        o.focus();
        return;
      }
    }
  }, Tc = (e) => {
    const { vertical: t, fixed: r, hideScrollbar: n, scrollableX: o, scrollableY: i, centered: s, scrollButtonsHideMobile: c, classes: a } = e;
    return ze({
      root: [
        "root",
        t && "vertical"
      ],
      scroller: [
        "scroller",
        r && "fixed",
        n && "hideScrollbar",
        o && "scrollableX",
        i && "scrollableY"
      ],
      flexContainer: [
        "flexContainer",
        t && "flexContainerVertical",
        s && "centered"
      ],
      indicator: [
        "indicator"
      ],
      scrollButtons: [
        "scrollButtons",
        c && "scrollButtonsHideMobile"
      ],
      scrollableX: [
        o && "scrollableX"
      ],
      hideScrollbar: [
        n && "hideScrollbar"
      ]
    }, wc, a);
  }, Rc = ne("div", {
    name: "MuiTabs",
    slot: "Root",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        {
          [`& .${yr.scrollButtons}`]: t.scrollButtons
        },
        {
          [`& .${yr.scrollButtons}`]: r.scrollButtonsHideMobile && t.scrollButtonsHideMobile
        },
        t.root,
        r.vertical && t.vertical
      ];
    }
  })(({ ownerState: e, theme: t }) => h({
    overflow: "hidden",
    minHeight: 48,
    WebkitOverflowScrolling: "touch",
    display: "flex"
  }, e.vertical && {
    flexDirection: "column"
  }, e.scrollButtonsHideMobile && {
    [`& .${yr.scrollButtons}`]: {
      [t.breakpoints.down("sm")]: {
        display: "none"
      }
    }
  })), $c = ne("div", {
    name: "MuiTabs",
    slot: "Scroller",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        t.scroller,
        r.fixed && t.fixed,
        r.hideScrollbar && t.hideScrollbar,
        r.scrollableX && t.scrollableX,
        r.scrollableY && t.scrollableY
      ];
    }
  })(({ ownerState: e }) => h({
    position: "relative",
    display: "inline-block",
    flex: "1 1 auto",
    whiteSpace: "nowrap"
  }, e.fixed && {
    overflowX: "hidden",
    width: "100%"
  }, e.hideScrollbar && {
    scrollbarWidth: "none",
    "&::-webkit-scrollbar": {
      display: "none"
    }
  }, e.scrollableX && {
    overflowX: "auto",
    overflowY: "hidden"
  }, e.scrollableY && {
    overflowY: "auto",
    overflowX: "hidden"
  })), _c = ne("div", {
    name: "MuiTabs",
    slot: "FlexContainer",
    overridesResolver: (e, t) => {
      const { ownerState: r } = e;
      return [
        t.flexContainer,
        r.vertical && t.flexContainerVertical,
        r.centered && t.centered
      ];
    }
  })(({ ownerState: e }) => h({
    display: "flex"
  }, e.vertical && {
    flexDirection: "column"
  }, e.centered && {
    justifyContent: "center"
  })), Ec = ne("span", {
    name: "MuiTabs",
    slot: "Indicator",
    overridesResolver: (e, t) => t.indicator
  })(({ ownerState: e, theme: t }) => h({
    position: "absolute",
    height: 2,
    bottom: 0,
    width: "100%",
    transition: t.transitions.create()
  }, e.indicatorColor === "primary" && {
    backgroundColor: (t.vars || t).palette.primary.main
  }, e.indicatorColor === "secondary" && {
    backgroundColor: (t.vars || t).palette.secondary.main
  }, e.vertical && {
    height: "100%",
    width: 2,
    right: 0
  })), Pc = ne(mc)({
    overflowX: "auto",
    overflowY: "hidden",
    scrollbarWidth: "none",
    "&::-webkit-scrollbar": {
      display: "none"
    }
  }), Mn = {}, kc = G.forwardRef(function(t, r) {
    const n = ke({
      props: t,
      name: "MuiTabs"
    }), o = Ka(), i = po(), { "aria-label": s, "aria-labelledby": c, action: a, centered: l = false, children: p, className: u, component: d = "div", allowScrollButtonsMobile: y = false, indicatorColor: g = "primary", onChange: m, orientation: v = "horizontal", ScrollButtonComponent: T = Sc, scrollButtons: E = "auto", selectionFollowsFocus: z, slots: C = {}, slotProps: B = {}, TabIndicatorProps: R = {}, TabScrollButtonProps: k = {}, textColor: W = "primary", value: K, variant: O = "standard", visibleScrollbar: U = false } = n, N = Y(n, Cc), $ = O === "scrollable", M = v === "vertical", X = M ? "scrollTop" : "scrollLeft", J = M ? "top" : "left", oe = M ? "bottom" : "right", ee = M ? "clientHeight" : "clientWidth", Oe = M ? "height" : "width", he = h({}, n, {
      component: d,
      allowScrollButtonsMobile: y,
      indicatorColor: g,
      orientation: v,
      vertical: M,
      scrollButtons: E,
      textColor: W,
      variant: O,
      visibleScrollbar: U,
      fixed: !$,
      hideScrollbar: $ && !U,
      scrollableX: $ && !M,
      scrollableY: $ && M,
      centered: l && !$,
      scrollButtonsHideMobile: !y
    }), ge = Tc(he), nr = Ot({
      elementType: C.StartScrollButtonIcon,
      externalSlotProps: B.startScrollButtonIcon,
      ownerState: he
    }), or = Ot({
      elementType: C.EndScrollButtonIcon,
      externalSlotProps: B.endScrollButtonIcon,
      ownerState: he
    }), [ye, Le] = G.useState(false), [de, lt] = G.useState(Mn), [ct, fe] = G.useState(false), [ut, ir] = G.useState(false), [dt, sr] = G.useState(false), [ft, ar] = G.useState({
      overflow: "hidden",
      scrollbarWidth: 0
    }), pt = /* @__PURE__ */ new Map(), pe = G.useRef(null), xe = G.useRef(null), mt = () => {
      const b = pe.current;
      let x;
      if (b) {
        const _ = b.getBoundingClientRect();
        x = {
          clientWidth: b.clientWidth,
          scrollLeft: b.scrollLeft,
          scrollTop: b.scrollTop,
          scrollLeftNormalized: Ls(b, i ? "rtl" : "ltr"),
          scrollWidth: b.scrollWidth,
          top: _.top,
          bottom: _.bottom,
          left: _.left,
          right: _.right
        };
      }
      let P;
      if (b && K !== false) {
        const _ = xe.current.children;
        if (_.length > 0) {
          const V = _[pt.get(K)];
          P = V ? V.getBoundingClientRect() : null;
        }
      }
      return {
        tabsMeta: x,
        tabMeta: P
      };
    }, Se = Be(() => {
      const { tabsMeta: b, tabMeta: x } = mt();
      let P = 0, _;
      if (M) _ = "top", x && b && (P = x.top - b.top + b.scrollTop);
      else if (_ = i ? "right" : "left", x && b) {
        const Q = i ? b.scrollLeftNormalized + b.clientWidth - b.scrollWidth : b.scrollLeft;
        P = (i ? -1 : 1) * (x[_] - b[_] + Q);
      }
      const V = {
        [_]: P,
        [Oe]: x ? x[Oe] : 0
      };
      if (isNaN(de[_]) || isNaN(de[Oe])) lt(V);
      else {
        const Q = Math.abs(de[_] - V[_]), be = Math.abs(de[Oe] - V[Oe]);
        (Q >= 1 || be >= 1) && lt(V);
      }
    }), Me = (b, { animation: x = true } = {}) => {
      x ? dc(X, pe.current, b, {
        duration: o.transitions.duration.standard
      }) : pe.current[X] = b;
    }, ht = (b) => {
      let x = pe.current[X];
      M ? x += b : (x += b * (i ? -1 : 1), x *= i && ao() === "reverse" ? -1 : 1), Me(x);
    }, gt = () => {
      const b = pe.current[ee];
      let x = 0;
      const P = Array.from(xe.current.children);
      for (let _ = 0; _ < P.length; _ += 1) {
        const V = P[_];
        if (x + V[ee] > b) {
          _ === 0 && (x = b);
          break;
        }
        x += V[ee];
      }
      return x;
    }, Fe = () => {
      ht(-1 * gt());
    }, je = () => {
      ht(gt());
    }, lr = G.useCallback((b) => {
      ar({
        overflow: null,
        scrollbarWidth: b
      });
    }, []), yt = () => {
      const b = {};
      b.scrollbarSizeListener = $ ? f.jsx(Pc, {
        onChange: lr,
        className: I(ge.scrollableX, ge.hideScrollbar)
      }) : null;
      const P = $ && (E === "auto" && (ct || ut) || E === true);
      return b.scrollButtonStart = P ? f.jsx(T, h({
        slots: {
          StartScrollButtonIcon: C.StartScrollButtonIcon
        },
        slotProps: {
          startScrollButtonIcon: nr
        },
        orientation: v,
        direction: i ? "right" : "left",
        onClick: Fe,
        disabled: !ct
      }, k, {
        className: I(ge.scrollButtons, k.className)
      })) : null, b.scrollButtonEnd = P ? f.jsx(T, h({
        slots: {
          EndScrollButtonIcon: C.EndScrollButtonIcon
        },
        slotProps: {
          endScrollButtonIcon: or
        },
        orientation: v,
        direction: i ? "left" : "right",
        onClick: je,
        disabled: !ut
      }, k, {
        className: I(ge.scrollButtons, k.className)
      })) : null, b;
    }, bt = Be((b) => {
      const { tabsMeta: x, tabMeta: P } = mt();
      if (!(!P || !x)) {
        if (P[J] < x[J]) {
          const _ = x[X] + (P[J] - x[J]);
          Me(_, {
            animation: b
          });
        } else if (P[oe] > x[oe]) {
          const _ = x[X] + (P[oe] - x[oe]);
          Me(_, {
            animation: b
          });
        }
      }
    }), S = Be(() => {
      $ && E !== false && sr(!dt);
    });
    G.useEffect(() => {
      const b = oo(() => {
        pe.current && Se();
      });
      let x;
      const P = (Q) => {
        Q.forEach((be) => {
          be.removedNodes.forEach((Ze) => {
            var Re;
            (Re = x) == null || Re.unobserve(Ze);
          }), be.addedNodes.forEach((Ze) => {
            var Re;
            (Re = x) == null || Re.observe(Ze);
          });
        }), b(), S();
      }, _ = so(pe.current);
      _.addEventListener("resize", b);
      let V;
      return typeof ResizeObserver < "u" && (x = new ResizeObserver(b), Array.from(xe.current.children).forEach((Q) => {
        x.observe(Q);
      })), typeof MutationObserver < "u" && (V = new MutationObserver(P), V.observe(xe.current, {
        childList: true
      })), () => {
        var Q, be;
        b.clear(), _.removeEventListener("resize", b), (Q = V) == null || Q.disconnect(), (be = x) == null || be.disconnect();
      };
    }, [
      Se,
      S
    ]), G.useEffect(() => {
      const b = Array.from(xe.current.children), x = b.length;
      if (typeof IntersectionObserver < "u" && x > 0 && $ && E !== false) {
        const P = b[0], _ = b[x - 1], V = {
          root: pe.current,
          threshold: 0.99
        }, Q = (ur) => {
          fe(!ur[0].isIntersecting);
        }, be = new IntersectionObserver(Q, V);
        be.observe(P);
        const Ze = (ur) => {
          ir(!ur[0].isIntersecting);
        }, Re = new IntersectionObserver(Ze, V);
        return Re.observe(_), () => {
          be.disconnect(), Re.disconnect();
        };
      }
    }, [
      $,
      E,
      dt,
      p == null ? void 0 : p.length
    ]), G.useEffect(() => {
      Le(true);
    }, []), G.useEffect(() => {
      Se();
    }), G.useEffect(() => {
      bt(Mn !== de);
    }, [
      bt,
      de
    ]), G.useImperativeHandle(a, () => ({
      updateIndicator: Se,
      updateScrollButtons: S
    }), [
      Se,
      S
    ]);
    const qe = f.jsx(Ec, h({}, R, {
      className: I(ge.indicator, R.className),
      ownerState: he,
      style: h({}, de, R.style)
    }));
    let We = 0;
    const vt = G.Children.map(p, (b) => {
      if (!G.isValidElement(b)) return null;
      const x = b.props.value === void 0 ? We : b.props.value;
      pt.set(x, We);
      const P = x === K;
      return We += 1, G.cloneElement(b, h({
        fullWidth: O === "fullWidth",
        indicator: P && !ye && qe,
        selected: P,
        selectionFollowsFocus: z,
        onChange: m,
        textColor: W,
        value: x
      }, We === 1 && K === false && !b.props.tabIndex ? {
        tabIndex: 0
      } : {}));
    }), Vr = (b) => {
      const x = xe.current, P = io(x).activeElement;
      if (P.getAttribute("role") !== "tab") return;
      let V = v === "horizontal" ? "ArrowLeft" : "ArrowUp", Q = v === "horizontal" ? "ArrowRight" : "ArrowDown";
      switch (v === "horizontal" && i && (V = "ArrowRight", Q = "ArrowLeft"), b.key) {
        case V:
          b.preventDefault(), wt(x, P, On);
          break;
        case Q:
          b.preventDefault(), wt(x, P, kn);
          break;
        case "Home":
          b.preventDefault(), wt(x, null, kn);
          break;
        case "End":
          b.preventDefault(), wt(x, null, On);
          break;
      }
    }, cr = yt();
    return f.jsxs(Rc, h({
      className: I(ge.root, u),
      ownerState: he,
      ref: r,
      as: d
    }, N, {
      children: [
        cr.scrollButtonStart,
        cr.scrollbarSizeListener,
        f.jsxs($c, {
          className: ge.scroller,
          ownerState: he,
          style: {
            overflow: ft.overflow,
            [M ? `margin${i ? "Left" : "Right"}` : "marginBottom"]: U ? void 0 : -ft.scrollbarWidth
          },
          ref: pe,
          children: [
            f.jsx(_c, {
              "aria-label": s,
              "aria-labelledby": c,
              "aria-orientation": v === "vertical" ? "vertical" : null,
              className: ge.flexContainer,
              ownerState: he,
              onKeyDown: Vr,
              ref: xe,
              role: "tablist",
              children: vt
            }),
            ye && qe
          ]
        }),
        cr.scrollButtonEnd
      ]
    }));
  }), Oc = q("div")({
    width: "100%",
    justifyContent: "flex-start",
    display: "flex",
    alignItems: "center",
    gap: 20,
    marginBottom: 20
  }), Mc = at(f.jsx("path", {
    d: "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20z"
  }), "ArrowBack"), jc = at(f.jsx("path", {
    d: "m20 12-1.41-1.41L13 16.17V4h-2v12.17l-5.58-5.59L4 12l8 8z"
  }), "ArrowDownward"), Bc = at(f.jsx("path", {
    d: "m4 12 1.41 1.41L11 7.83V20h2V7.83l5.58 5.59L20 12l-8-8z"
  }), "ArrowUpward"), rr = "#16a84f", Ur = "#0d7a38", _o = "#d64545", Eo = "#a3312f", jn = Ie.white, Bn = Ie.black, Ac = {
    palette: {
      mode: "light",
      primary: {
        main: rr,
        dark: Ur,
        light: "#4cc27a",
        contrastText: jn
      },
      secondary: {
        main: _o,
        light: "#e37373",
        dark: Eo,
        contrastText: jn
      }
    }
  }, Ic = {
    palette: {
      mode: "dark",
      primary: {
        main: rr,
        dark: Ur,
        light: "#4cc27a",
        contrastText: Bn
      },
      secondary: {
        main: _o,
        light: "#e37373",
        dark: Eo,
        contrastText: Bn
      }
    }
  }, zc = {
    light: Ac,
    dark: Ic
  }, Lc = ({ children: e, mode: t }) => {
    const r = zc[t], n = To(r);
    return f.jsx(gl, {
      theme: n,
      children: e
    });
  }, Er = (e) => `R$ ${Math.round(e || 0).toLocaleString("pt-BR")}`, Fc = q.div`
  background: linear-gradient(135deg, ${rr} 0%, ${Ur} 100%);
  border-radius: 18px;
  padding: 1.4rem 1.6rem;
  color: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
`, Wc = ({ account: e }) => f.jsxs(Fc, {
    children: [
      f.jsx(me, {
        fontSize: 13,
        sx: {
          opacity: 0.85
        },
        children: e.type
      }),
      f.jsx(me, {
        fontSize: 17,
        fontWeight: 700,
        children: e.name
      }),
      f.jsx(me, {
        fontSize: 30,
        fontWeight: 800,
        sx: {
          mt: 1
        },
        children: Er(e.amount)
      }),
      typeof e.cash == "number" && f.jsxs(me, {
        fontSize: 13,
        sx: {
          opacity: 0.85
        },
        children: [
          "Dinheiro: ",
          Er(e.cash)
        ]
      })
    ]
  }), { useState: Ct } = await w("react"), Nc = q.div`
  display: flex;
  gap: 0.7rem;
  margin: 1.1rem 0;
`, Dc = q.button`
  flex: 1;
  border: none;
  border-radius: 12px;
  padding: 0.9rem 0.4rem;
  color: #ffffff;
  font-weight: 700;
  font-size: 0.85rem;
  cursor: pointer;
  background: linear-gradient(135deg, ${({ gradientFrom: e }) => e} 0%, ${({ gradientTo: e }) => e} 100%);
`, Hc = q.div`
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.55);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1300;
`, Kc = q.div`
  width: 88%;
  max-width: 21rem;
  background: #ffffff;
  border-radius: 6px;
  padding: 1.6rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.18);
`, Uc = q.h3`
  font-size: 1.15rem;
  margin-bottom: 1.2rem;
  color: #1a201c;
`, br = q.div`
  margin-bottom: 1rem;
`, vr = q.label`
  display: block;
  font-size: 0.8rem;
  font-weight: 600;
  color: #6b7a72;
  margin-bottom: 0.35rem;
`, xr = q.input`
  width: 100%;
  background: #f4f6f5;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 3px;
  padding: 0.75rem 0.9rem;
  font-size: 0.95rem;
  color: #1a201c;
  font-family: inherit;

  &:focus {
    outline: none;
    border-color: ${rr};
  }
`, Vc = q.div`
  display: flex;
  gap: 0.7rem;
  margin-top: 1.4rem;
`, An = q.button`
  flex: 1;
  border: none;
  padding: 0.8rem;
  border-radius: 4px;
  font-weight: 700;
  font-size: 0.9rem;
  cursor: pointer;
  transition: 0.2s;
  background: ${({ variant: e, accent: t }) => e === "confirm" ? t : "#f4f6f5"};
  color: ${({ variant: e }) => e === "confirm" ? "#ffffff" : "#6b7a72"};

  &:hover {
    background: ${({ variant: e, accentDark: t }) => e === "confirm" ? t : "rgba(0, 0, 0, 0.08)"};
  }
`, Yc = {
    transfer: "Transferir"
  }, Tt = {
    transfer: [
      "#2b3a33",
      "#16201c"
    ]
  }, Gc = ({ onSubmit: e }) => {
    const [t, r] = Ct(null), [n, o] = Ct(""), [i, s] = Ct(""), [c, a] = Ct(""), l = () => {
      r(null), o(""), s(""), a("");
    }, p = () => {
      const u = parseInt(n, 10);
      !t || !u || u < 1 || t === "transfer" && !i.trim() || (e(t, u, t === "transfer" ? i.trim() : void 0, c || void 0), l());
    };
    return f.jsxs(f.Fragment, {
      children: [
        f.jsx(Nc, {
          children: f.jsx(Dc, {
            gradientFrom: "#2b3a33",
            gradientTo: "#16201c",
            onClick: () => r("transfer"),
            children: "Transferir"
          })
        }),
        t && f.jsx(Hc, {
          onClick: (u) => {
            u.target === u.currentTarget && l();
          },
          children: f.jsxs(Kc, {
            children: [
              f.jsx(Uc, {
                children: Yc[t]
              }),
              f.jsxs(br, {
                children: [
                  f.jsx(vr, {
                    children: "Valor:"
                  }),
                  f.jsx(xr, {
                    type: "number",
                    min: 1,
                    step: 1,
                    placeholder: "0",
                    value: n,
                    onChange: (u) => o(u.target.value)
                  })
                ]
              }),
              t === "transfer" && f.jsxs(br, {
                children: [
                  f.jsx(vr, {
                    children: "Conta ou ID do cidad\xE3o de destino:"
                  }),
                  f.jsx(xr, {
                    type: "text",
                    placeholder: "Ex: 1001",
                    autoFocus: true,
                    value: i,
                    onChange: (u) => s(u.target.value)
                  })
                ]
              }),
              f.jsxs(br, {
                children: [
                  f.jsx(vr, {
                    children: "Coment\xE1rio (opcional):"
                  }),
                  f.jsx(xr, {
                    type: "text",
                    placeholder: "Ex: aluguel",
                    value: c,
                    onChange: (u) => a(u.target.value)
                  })
                ]
              }),
              f.jsxs(Vc, {
                children: [
                  f.jsx(An, {
                    variant: "cancel",
                    accent: Tt[t][0],
                    accentDark: Tt[t][1],
                    onClick: l,
                    children: "Cancelar"
                  }),
                  f.jsx(An, {
                    variant: "confirm",
                    accent: Tt[t][0],
                    accentDark: Tt[t][1],
                    onClick: p,
                    children: "Confirmar"
                  })
                ]
              })
            ]
          })
        })
      ]
    });
  }, Xc = q.div`
  display: flex;
  align-items: center;
  gap: 0.8rem;
  padding: 0.7rem 0;
  border-bottom: 1px solid rgba(128, 128, 128, 0.15);

  &:last-of-type {
    border-bottom: none;
  }
`, qc = q.div`
  width: 34px;
  height: 34px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: #ffffff;
  background: ${({ isDeposit: e }) => e ? "#16a84f" : "#d64545"};
`, In = (e) => new Date(e * 1e3).toLocaleString("pt-BR"), Zc = ({ transactions: e, isDarkMode: t }) => !e || e.length === 0 ? f.jsx(me, {
    align: "center",
    fontSize: 14,
    sx: {
      opacity: 0.7,
      mt: 2
    },
    children: "Nenhuma transa\xE7\xE3o ainda."
  }) : f.jsx("div", {
    children: e.map((r) => {
      const n = r.trans_type === "deposit", o = r.issuer && r.receiver && r.issuer !== r.receiver ? `${r.issuer} \u2192 ${r.receiver} \xB7 ${In(r.time)}` : In(r.time);
      return f.jsxs(Xc, {
        children: [
          f.jsx(qc, {
            isDeposit: n,
            children: n ? f.jsx(jc, {
              fontSize: "small"
            }) : f.jsx(Bc, {
              fontSize: "small"
            })
          }),
          f.jsxs("div", {
            style: {
              flex: 1,
              minWidth: 0
            },
            children: [
              f.jsx(me, {
                fontSize: 14,
                fontWeight: 600,
                color: t ? "white" : "black",
                noWrap: true,
                children: r.message || r.title
              }),
              f.jsx(me, {
                fontSize: 12,
                sx: {
                  opacity: 0.65
                },
                noWrap: true,
                children: o
              })
            ]
          }),
          f.jsxs(me, {
            fontSize: 14,
            fontWeight: 700,
            color: n ? "#16a84f" : "#d64545",
            children: [
              n ? "+" : "-",
              " ",
              Er(r.amount)
            ]
          })
        ]
      }, r.trans_id);
    })
  });
  async function zn(e, t, r) {
    const n = {
      method: "post",
      headers: {
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: JSON.stringify(t)
    };
    return await (await fetch(`https://npwd_fleeca/${e}`, n)).json();
  }
  let Jc, Ln, Qc, eu, tu;
  ({ useEffect: Jc, useState: Ln } = await w("react"));
  ({ useHistory: Qc } = await w("react-router-dom"));
  eu = q.div`
  flex: 1;
  padding: 1.5rem;
  display: flex;
  box-sizing: border-box;
  flex-direction: column;
  overflow: auto;
  max-height: 100%;
  /* Server: neutral-100, the same surface the phone's own AppContent and navigation bar use.
     Was #fafafa (neutral-50) - one shade lighter, which drew a visible seam where the app met
     the nav bar. The dark value below already matched neutral-900 exactly. */
  background-color: #f5f5f5;
  ${({ isDarkMode: e }) => e && `
  background-color: rgb(23 23 23 / 1);
`}
`;
  tu = (e) => {
    const t = Qc(), r = e.theme.palette.mode === "dark", [n, o] = Ln([]), [i, s] = Ln(0), c = () => {
      zn("npwd_fleeca:getAccounts", null).then((p) => {
        p.data && o(p.data);
      });
    };
    Jc(() => {
      c();
    }, []);
    const a = n[i], l = (p, u, d, y) => {
      a && zn("npwd_fleeca:" + p, {
        fromAccount: a.id,
        amount: u,
        targetId: d,
        comment: y
      }).then((g) => {
        g.status === "ok" && g.data && o(g.data);
      });
    };
    return f.jsx(Dn, {
      injectFirst: true,
      children: f.jsx(Lc, {
        mode: e.theme.palette.mode,
        children: f.jsxs(eu, {
          isDarkMode: r,
          children: [
            f.jsxs(Oc, {
              children: [
                f.jsx(Xl, {
                  color: "default",
                  onClick: () => t.push("/"),
                  children: f.jsx(Mc, {})
                }),
                f.jsx(me, {
                  fontSize: 24,
                  color: r ? "white" : "black",
                  fontWeight: "bold",
                  children: "Fleeca"
                })
              ]
            }),
            n.length === 0 && f.jsx(me, {
              align: "center",
              fontSize: 16,
              sx: {
                opacity: 0.7,
                mt: 4
              },
              children: "Nenhuma conta encontrada."
            }),
            n.length > 1 && f.jsx(kc, {
              value: i,
              onChange: (p, u) => s(u),
              variant: "scrollable",
              scrollButtons: "auto",
              sx: {
                mb: 1.5,
                minHeight: 36
              },
              children: n.map((p, u) => f.jsx(ac, {
                label: p.name,
                value: u,
                sx: {
                  minHeight: 36
                }
              }, p.id))
            }),
            a && f.jsxs(f.Fragment, {
              children: [
                f.jsx(Wc, {
                  account: a
                }),
                f.jsx(Gc, {
                  onSubmit: l
                }),
                f.jsx(me, {
                  fontSize: 15,
                  fontWeight: 700,
                  color: r ? "white" : "black",
                  sx: {
                    mt: 1,
                    mb: 0.5
                  },
                  children: "Transa\xE7\xF5es"
                }),
                f.jsx(Zc, {
                  transactions: a.transactions,
                  isDarkMode: r
                })
              ]
            })
          ]
        })
      })
    });
  };
  lu = (e) => f.jsx(tu, {
    ...e
  });
});
export {
  lu as W,
  __tla,
  at as a,
  To as c,
  f as j
};
