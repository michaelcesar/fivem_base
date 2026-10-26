import { importShared as Y, __tla as __tla_0 } from "./__federation_fn_import-Bhcw9meP.js";
import { h as ze, _ as Se } from "./hoist-non-react-statics.cjs-3wE6KoJ0.js";
let Mr, Fr, W, Wr, Rr, jr, pr, Lr, zr, _r, Ae, ce, Ce, Gr, Fe, se, U, $e, le;
let __tla = Promise.all([
  (() => {
    try {
      return __tla_0;
    } catch {
    }
  })()
]).then(async () => {
  function Le(e) {
    for (var r = 0, t, n = 0, a = e.length; a >= 4; ++n, a -= 4) t = e.charCodeAt(n) & 255 | (e.charCodeAt(++n) & 255) << 8 | (e.charCodeAt(++n) & 255) << 16 | (e.charCodeAt(++n) & 255) << 24, t = (t & 65535) * 1540483477 + ((t >>> 16) * 59797 << 16), t ^= t >>> 24, r = (t & 65535) * 1540483477 + ((t >>> 16) * 59797 << 16) ^ (r & 65535) * 1540483477 + ((r >>> 16) * 59797 << 16);
    switch (a) {
      case 3:
        r ^= (e.charCodeAt(n + 2) & 255) << 16;
      case 2:
        r ^= (e.charCodeAt(n + 1) & 255) << 8;
      case 1:
        r ^= e.charCodeAt(n) & 255, r = (r & 65535) * 1540483477 + ((r >>> 16) * 59797 << 16);
    }
    return r ^= r >>> 13, r = (r & 65535) * 1540483477 + ((r >>> 16) * 59797 << 16), ((r ^ r >>> 15) >>> 0).toString(36);
  }
  var _e = {
    animationIterationCount: 1,
    aspectRatio: 1,
    borderImageOutset: 1,
    borderImageSlice: 1,
    borderImageWidth: 1,
    boxFlex: 1,
    boxFlexGroup: 1,
    boxOrdinalGroup: 1,
    columnCount: 1,
    columns: 1,
    flex: 1,
    flexGrow: 1,
    flexPositive: 1,
    flexShrink: 1,
    flexNegative: 1,
    flexOrder: 1,
    gridRow: 1,
    gridRowEnd: 1,
    gridRowSpan: 1,
    gridRowStart: 1,
    gridColumn: 1,
    gridColumnEnd: 1,
    gridColumnSpan: 1,
    gridColumnStart: 1,
    msGridRow: 1,
    msGridRowSpan: 1,
    msGridColumn: 1,
    msGridColumnSpan: 1,
    fontWeight: 1,
    lineHeight: 1,
    opacity: 1,
    order: 1,
    orphans: 1,
    scale: 1,
    tabSize: 1,
    widows: 1,
    zIndex: 1,
    zoom: 1,
    WebkitLineClamp: 1,
    fillOpacity: 1,
    floodOpacity: 1,
    stopOpacity: 1,
    strokeDasharray: 1,
    strokeDashoffset: 1,
    strokeMiterlimit: 1,
    strokeOpacity: 1,
    strokeWidth: 1
  };
  Fe = function(e) {
    var r = /* @__PURE__ */ Object.create(null);
    return function(t) {
      return r[t] === void 0 && (r[t] = e(t)), r[t];
    };
  };
  var Ge = /[A-Z]|^ms/g, je = /_EMO_([^_]+?)_([^]*?)_EMO_/g, Ee = function(r) {
    return r.charCodeAt(1) === 45;
  }, me = function(r) {
    return r != null && typeof r != "boolean";
  }, re = Fe(function(e) {
    return Ee(e) ? e : e.replace(Ge, "-$&").toLowerCase();
  }), ve = function(r, t) {
    switch (r) {
      case "animation":
      case "animationName":
        if (typeof t == "string") return t.replace(je, function(n, a, i) {
          return R = {
            name: a,
            styles: i,
            next: R
          }, a;
        });
    }
    return _e[r] !== 1 && !Ee(r) && typeof t == "number" && t !== 0 ? t + "px" : t;
  };
  function G(e, r, t) {
    if (t == null) return "";
    var n = t;
    if (n.__emotion_styles !== void 0) return n;
    switch (typeof t) {
      case "boolean":
        return "";
      case "object": {
        var a = t;
        if (a.anim === 1) return R = {
          name: a.name,
          styles: a.styles,
          next: R
        }, a.name;
        var i = t;
        if (i.styles !== void 0) {
          var s = i.next;
          if (s !== void 0) for (; s !== void 0; ) R = {
            name: s.name,
            styles: s.styles,
            next: R
          }, s = s.next;
          var c = i.styles + ";";
          return c;
        }
        return De(e, r, t);
      }
      case "function": {
        if (e !== void 0) {
          var f = R, u = t(e);
          return R = f, G(e, r, u);
        }
        break;
      }
    }
    var o = t;
    if (r == null) return o;
    var d = r[o];
    return d !== void 0 ? d : o;
  }
  function De(e, r, t) {
    var n = "";
    if (Array.isArray(t)) for (var a = 0; a < t.length; a++) n += G(e, r, t[a]) + ";";
    else for (var i in t) {
      var s = t[i];
      if (typeof s != "object") {
        var c = s;
        r != null && r[c] !== void 0 ? n += i + "{" + r[c] + "}" : me(c) && (n += re(i) + ":" + ve(i, c) + ";");
      } else if (Array.isArray(s) && typeof s[0] == "string" && (r == null || r[s[0]] === void 0)) for (var f = 0; f < s.length; f++) me(s[f]) && (n += re(i) + ":" + ve(i, s[f]) + ";");
      else {
        var u = G(e, r, s);
        switch (i) {
          case "animation":
          case "animationName": {
            n += re(i) + ":" + u + ";";
            break;
          }
          default:
            n += i + "{" + u + "}";
        }
      }
    }
    return n;
  }
  var ge = /label:\s*([^\s;{]+)\s*(;|$)/g, R;
  U = function(e, r, t) {
    if (e.length === 1 && typeof e[0] == "object" && e[0] !== null && e[0].styles !== void 0) return e[0];
    var n = true, a = "";
    R = void 0;
    var i = e[0];
    if (i == null || i.raw === void 0) n = false, a += G(t, r, i);
    else {
      var s = i;
      a += s[0];
    }
    for (var c = 1; c < e.length; c++) if (a += G(t, r, e[c]), n) {
      var f = i;
      a += f[c];
    }
    ge.lastIndex = 0;
    for (var u = "", o; (o = ge.exec(a)) !== null; ) u += "-" + o[1];
    var d = Le(a) + u;
    return {
      name: d,
      styles: a,
      next: R
    };
  };
  const te = await Y("react");
  let Je, ke, ye, Ve;
  Je = function(r) {
    return r();
  };
  ke = te.useInsertionEffect ? te.useInsertionEffect : false;
  $e = ke || Je;
  ye = ke || te.useLayoutEffect;
  Ve = true;
  Ae = function(e, r, t) {
    var n = "";
    return t.split(" ").forEach(function(a) {
      e[a] !== void 0 ? r.push(e[a] + ";") : a && (n += a + " ");
    }), n;
  };
  se = function(r, t, n) {
    var a = r.key + "-" + t.name;
    (n === false || Ve === false) && r.registered[a] === void 0 && (r.registered[a] = t.styles);
  };
  ce = function(r, t, n) {
    se(r, t, n);
    var a = r.key + "-" + t.name;
    if (r.inserted[t.name] === void 0) {
      var i = t;
      do
        r.insert(t === i ? "." + a : "", i, r.sheet, true), i = i.next;
      while (i !== void 0);
    }
  };
  function Xe(e) {
    if (e.sheet) return e.sheet;
    for (var r = 0; r < document.styleSheets.length; r++) if (document.styleSheets[r].ownerNode === e) return document.styleSheets[r];
  }
  function qe(e) {
    var r = document.createElement("style");
    return r.setAttribute("data-emotion", e.key), e.nonce !== void 0 && r.setAttribute("nonce", e.nonce), r.appendChild(document.createTextNode("")), r.setAttribute("data-s", ""), r;
  }
  var Be = function() {
    function e(t) {
      var n = this;
      this._insertTag = function(a) {
        var i;
        n.tags.length === 0 ? n.insertionPoint ? i = n.insertionPoint.nextSibling : n.prepend ? i = n.container.firstChild : i = n.before : i = n.tags[n.tags.length - 1].nextSibling, n.container.insertBefore(a, i), n.tags.push(a);
      }, this.isSpeedy = t.speedy === void 0 ? true : t.speedy, this.tags = [], this.ctr = 0, this.nonce = t.nonce, this.key = t.key, this.container = t.container, this.prepend = t.prepend, this.insertionPoint = t.insertionPoint, this.before = null;
    }
    var r = e.prototype;
    return r.hydrate = function(n) {
      n.forEach(this._insertTag);
    }, r.insert = function(n) {
      this.ctr % (this.isSpeedy ? 65e3 : 1) === 0 && this._insertTag(qe(this));
      var a = this.tags[this.tags.length - 1];
      if (this.isSpeedy) {
        var i = Xe(a);
        try {
          i.insertRule(n, i.cssRules.length);
        } catch {
        }
      } else a.appendChild(document.createTextNode(n));
      this.ctr++;
    }, r.flush = function() {
      this.tags.forEach(function(n) {
        var a;
        return (a = n.parentNode) == null ? void 0 : a.removeChild(n);
      }), this.tags = [], this.ctr = 0;
    }, e;
  }(), w = "-ms-", K = "-moz-", h = "-webkit-", Re = "comm", fe = "rule", oe = "decl", He = "@import", Te = "@keyframes", Ke = "@layer", Ye = Math.abs, Z = String.fromCharCode, Ue = Object.assign;
  function Ze(e, r) {
    return b(e, 0) ^ 45 ? (((r << 2 ^ b(e, 0)) << 2 ^ b(e, 1)) << 2 ^ b(e, 2)) << 2 ^ b(e, 3) : 0;
  }
  function Pe(e) {
    return e.trim();
  }
  function Qe(e, r) {
    return (e = r.exec(e)) ? e[0] : e;
  }
  function l(e, r, t) {
    return e.replace(r, t);
  }
  function ne(e, r) {
    return e.indexOf(r);
  }
  function b(e, r) {
    return e.charCodeAt(r) | 0;
  }
  function j(e, r, t) {
    return e.slice(r, t);
  }
  function T(e) {
    return e.length;
  }
  function ue(e) {
    return e.length;
  }
  function X(e, r) {
    return r.push(e), e;
  }
  function er(e, r) {
    return e.map(r).join("");
  }
  var Q = 1, L = 1, Oe = 0, C = 0, y = 0, _ = "";
  function ee(e, r, t, n, a, i, s) {
    return {
      value: e,
      root: r,
      parent: t,
      type: n,
      props: a,
      children: i,
      line: Q,
      column: L,
      length: s,
      return: ""
    };
  }
  function F(e, r) {
    return Ue(ee("", null, null, "", null, null, 0), e, {
      length: -e.length
    }, r);
  }
  function rr() {
    return y;
  }
  function tr() {
    return y = C > 0 ? b(_, --C) : 0, L--, y === 10 && (L = 1, Q--), y;
  }
  function k() {
    return y = C < Oe ? b(_, C++) : 0, L++, y === 10 && (L = 1, Q++), y;
  }
  function P() {
    return b(_, C);
  }
  function q() {
    return C;
  }
  function J(e, r) {
    return j(_, e, r);
  }
  function D(e) {
    switch (e) {
      case 0:
      case 9:
      case 10:
      case 13:
      case 32:
        return 5;
      case 33:
      case 43:
      case 44:
      case 47:
      case 62:
      case 64:
      case 126:
      case 59:
      case 123:
      case 125:
        return 4;
      case 58:
        return 3;
      case 34:
      case 39:
      case 40:
      case 91:
        return 2;
      case 41:
      case 93:
        return 1;
    }
    return 0;
  }
  function Ne(e) {
    return Q = L = 1, Oe = T(_ = e), C = 0, [];
  }
  function Ie(e) {
    return _ = "", e;
  }
  function B(e) {
    return Pe(J(C - 1, ae(e === 91 ? e + 2 : e === 40 ? e + 1 : e)));
  }
  function nr(e) {
    for (; (y = P()) && y < 33; ) k();
    return D(e) > 2 || D(y) > 3 ? "" : " ";
  }
  function ar(e, r) {
    for (; --r && k() && !(y < 48 || y > 102 || y > 57 && y < 65 || y > 70 && y < 97); ) ;
    return J(e, q() + (r < 6 && P() == 32 && k() == 32));
  }
  function ae(e) {
    for (; k(); ) switch (y) {
      case e:
        return C;
      case 34:
      case 39:
        e !== 34 && e !== 39 && ae(y);
        break;
      case 40:
        e === 41 && ae(e);
        break;
      case 92:
        k();
        break;
    }
    return C;
  }
  function ir(e, r) {
    for (; k() && e + y !== 57; ) if (e + y === 84 && P() === 47) break;
    return "/*" + J(r, C - 1) + "*" + Z(e === 47 ? e : k());
  }
  function sr(e) {
    for (; !D(P()); ) k();
    return J(e, C);
  }
  function cr(e) {
    return Ie(H("", null, null, null, [
      ""
    ], e = Ne(e), 0, [
      0
    ], e));
  }
  function H(e, r, t, n, a, i, s, c, f) {
    for (var u = 0, o = 0, d = s, O = 0, N = 0, S = 0, v = 1, x = 1, g = 1, p = 0, $ = "", V = a, M = i, A = n, m = $; x; ) switch (S = p, p = k()) {
      case 40:
        if (S != 108 && b(m, d - 1) == 58) {
          ne(m += l(B(p), "&", "&\f"), "&\f") != -1 && (g = -1);
          break;
        }
      case 34:
      case 39:
      case 91:
        m += B(p);
        break;
      case 9:
      case 10:
      case 13:
      case 32:
        m += nr(S);
        break;
      case 92:
        m += ar(q() - 1, 7);
        continue;
      case 47:
        switch (P()) {
          case 42:
          case 47:
            X(fr(ir(k(), q()), r, t), f);
            break;
          default:
            m += "/";
        }
        break;
      case 123 * v:
        c[u++] = T(m) * g;
      case 125 * v:
      case 59:
      case 0:
        switch (p) {
          case 0:
          case 125:
            x = 0;
          case 59 + o:
            g == -1 && (m = l(m, /\f/g, "")), N > 0 && T(m) - d && X(N > 32 ? pe(m + ";", n, t, d - 1) : pe(l(m, " ", "") + ";", n, t, d - 2), f);
            break;
          case 59:
            m += ";";
          default:
            if (X(A = be(m, r, t, u, o, a, c, $, V = [], M = [], d), i), p === 123) if (o === 0) H(m, r, A, A, V, i, d, c, M);
            else switch (O === 99 && b(m, 3) === 110 ? 100 : O) {
              case 100:
              case 108:
              case 109:
              case 115:
                H(e, A, A, n && X(be(e, A, A, 0, 0, a, c, $, a, V = [], d), M), a, M, d, c, n ? V : M);
                break;
              default:
                H(m, A, A, A, [
                  ""
                ], M, 0, c, M);
            }
        }
        u = o = N = 0, v = g = 1, $ = m = "", d = s;
        break;
      case 58:
        d = 1 + T(m), N = S;
      default:
        if (v < 1) {
          if (p == 123) --v;
          else if (p == 125 && v++ == 0 && tr() == 125) continue;
        }
        switch (m += Z(p), p * v) {
          case 38:
            g = o > 0 ? 1 : (m += "\f", -1);
            break;
          case 44:
            c[u++] = (T(m) - 1) * g, g = 1;
            break;
          case 64:
            P() === 45 && (m += B(k())), O = P(), o = d = T($ = m += sr(q())), p++;
            break;
          case 45:
            S === 45 && T(m) == 2 && (v = 0);
        }
    }
    return i;
  }
  function be(e, r, t, n, a, i, s, c, f, u, o) {
    for (var d = a - 1, O = a === 0 ? i : [
      ""
    ], N = ue(O), S = 0, v = 0, x = 0; S < n; ++S) for (var g = 0, p = j(e, d + 1, d = Ye(v = s[S])), $ = e; g < N; ++g) ($ = Pe(v > 0 ? O[g] + " " + p : l(p, /&\f/g, O[g]))) && (f[x++] = $);
    return ee(e, r, t, a === 0 ? fe : c, f, u, o);
  }
  function fr(e, r, t) {
    return ee(e, r, t, Re, Z(rr()), j(e, 2, -2), 0);
  }
  function pe(e, r, t, n) {
    return ee(e, r, t, oe, j(e, 0, n), j(e, n + 1, -1), n);
  }
  function z(e, r) {
    for (var t = "", n = ue(e), a = 0; a < n; a++) t += r(e[a], a, e, r) || "";
    return t;
  }
  function or(e, r, t, n) {
    switch (e.type) {
      case Ke:
        if (e.children.length) break;
      case He:
      case oe:
        return e.return = e.return || e.value;
      case Re:
        return "";
      case Te:
        return e.return = e.value + "{" + z(e.children, n) + "}";
      case fe:
        e.value = e.props.join(",");
    }
    return T(t = z(e.children, n)) ? e.return = e.value + "{" + t + "}" : "";
  }
  function ur(e) {
    var r = ue(e);
    return function(t, n, a, i) {
      for (var s = "", c = 0; c < r; c++) s += e[c](t, n, a, i) || "";
      return s;
    };
  }
  function hr(e) {
    return function(r) {
      r.root || (r = r.return) && e(r);
    };
  }
  var we = function(r) {
    var t = /* @__PURE__ */ new WeakMap();
    return function(n) {
      if (t.has(n)) return t.get(n);
      var a = r(n);
      return t.set(n, a), a;
    };
  }, lr = function(r, t, n) {
    for (var a = 0, i = 0; a = i, i = P(), a === 38 && i === 12 && (t[n] = 1), !D(i); ) k();
    return J(r, C);
  }, dr = function(r, t) {
    var n = -1, a = 44;
    do
      switch (D(a)) {
        case 0:
          a === 38 && P() === 12 && (t[n] = 1), r[n] += lr(C - 1, t, n);
          break;
        case 2:
          r[n] += B(a);
          break;
        case 4:
          if (a === 44) {
            r[++n] = P() === 58 ? "&\f" : "", t[n] = r[n].length;
            break;
          }
        default:
          r[n] += Z(a);
      }
    while (a = k());
    return r;
  }, mr = function(r, t) {
    return Ie(dr(Ne(r), t));
  }, xe = /* @__PURE__ */ new WeakMap(), vr = function(r) {
    if (!(r.type !== "rule" || !r.parent || r.length < 1)) {
      for (var t = r.value, n = r.parent, a = r.column === n.column && r.line === n.line; n.type !== "rule"; ) if (n = n.parent, !n) return;
      if (!(r.props.length === 1 && t.charCodeAt(0) !== 58 && !xe.get(n)) && !a) {
        xe.set(r, true);
        for (var i = [], s = mr(t, i), c = n.props, f = 0, u = 0; f < s.length; f++) for (var o = 0; o < c.length; o++, u++) r.props[u] = i[f] ? s[f].replace(/&\f/g, c[o]) : c[o] + " " + s[f];
      }
    }
  }, gr = function(r) {
    if (r.type === "decl") {
      var t = r.value;
      t.charCodeAt(0) === 108 && t.charCodeAt(2) === 98 && (r.return = "", r.value = "");
    }
  };
  function Me(e, r) {
    switch (Ze(e, r)) {
      case 5103:
        return h + "print-" + e + e;
      case 5737:
      case 4201:
      case 3177:
      case 3433:
      case 1641:
      case 4457:
      case 2921:
      case 5572:
      case 6356:
      case 5844:
      case 3191:
      case 6645:
      case 3005:
      case 6391:
      case 5879:
      case 5623:
      case 6135:
      case 4599:
      case 4855:
      case 4215:
      case 6389:
      case 5109:
      case 5365:
      case 5621:
      case 3829:
        return h + e + e;
      case 5349:
      case 4246:
      case 4810:
      case 6968:
      case 2756:
        return h + e + K + e + w + e + e;
      case 6828:
      case 4268:
        return h + e + w + e + e;
      case 6165:
        return h + e + w + "flex-" + e + e;
      case 5187:
        return h + e + l(e, /(\w+).+(:[^]+)/, h + "box-$1$2" + w + "flex-$1$2") + e;
      case 5443:
        return h + e + w + "flex-item-" + l(e, /flex-|-self/, "") + e;
      case 4675:
        return h + e + w + "flex-line-pack" + l(e, /align-content|flex-|-self/, "") + e;
      case 5548:
        return h + e + w + l(e, "shrink", "negative") + e;
      case 5292:
        return h + e + w + l(e, "basis", "preferred-size") + e;
      case 6060:
        return h + "box-" + l(e, "-grow", "") + h + e + w + l(e, "grow", "positive") + e;
      case 4554:
        return h + l(e, /([^-])(transform)/g, "$1" + h + "$2") + e;
      case 6187:
        return l(l(l(e, /(zoom-|grab)/, h + "$1"), /(image-set)/, h + "$1"), e, "") + e;
      case 5495:
      case 3959:
        return l(e, /(image-set\([^]*)/, h + "$1$`$1");
      case 4968:
        return l(l(e, /(.+:)(flex-)?(.*)/, h + "box-pack:$3" + w + "flex-pack:$3"), /s.+-b[^;]+/, "justify") + h + e + e;
      case 4095:
      case 3583:
      case 4068:
      case 2532:
        return l(e, /(.+)-inline(.+)/, h + "$1$2") + e;
      case 8116:
      case 7059:
      case 5753:
      case 5535:
      case 5445:
      case 5701:
      case 4933:
      case 4677:
      case 5533:
      case 5789:
      case 5021:
      case 4765:
        if (T(e) - 1 - r > 6) switch (b(e, r + 1)) {
          case 109:
            if (b(e, r + 4) !== 45) break;
          case 102:
            return l(e, /(.+:)(.+)-([^]+)/, "$1" + h + "$2-$3$1" + K + (b(e, r + 3) == 108 ? "$3" : "$2-$3")) + e;
          case 115:
            return ~ne(e, "stretch") ? Me(l(e, "stretch", "fill-available"), r) + e : e;
        }
        break;
      case 4949:
        if (b(e, r + 1) !== 115) break;
      case 6444:
        switch (b(e, T(e) - 3 - (~ne(e, "!important") && 10))) {
          case 107:
            return l(e, ":", ":" + h) + e;
          case 101:
            return l(e, /(.+:)([^;!]+)(;|!.+)?/, "$1" + h + (b(e, 14) === 45 ? "inline-" : "") + "box$3$1" + h + "$2$3$1" + w + "$2box$3") + e;
        }
        break;
      case 5936:
        switch (b(e, r + 11)) {
          case 114:
            return h + e + w + l(e, /[svh]\w+-[tblr]{2}/, "tb") + e;
          case 108:
            return h + e + w + l(e, /[svh]\w+-[tblr]{2}/, "tb-rl") + e;
          case 45:
            return h + e + w + l(e, /[svh]\w+-[tblr]{2}/, "lr") + e;
        }
        return h + e + w + e + e;
    }
    return e;
  }
  let yr, br, wr;
  yr = function(r, t, n, a) {
    if (r.length > -1 && !r.return) switch (r.type) {
      case oe:
        r.return = Me(r.value, r.length);
        break;
      case Te:
        return z([
          F(r, {
            value: l(r.value, "@", "@" + h)
          })
        ], a);
      case fe:
        if (r.length) return er(r.props, function(i) {
          switch (Qe(i, /(::plac\w+|:read-\w+)/)) {
            case ":read-only":
            case ":read-write":
              return z([
                F(r, {
                  props: [
                    l(i, /:(read-\w+)/, ":" + K + "$1")
                  ]
                })
              ], a);
            case "::placeholder":
              return z([
                F(r, {
                  props: [
                    l(i, /:(plac\w+)/, ":" + h + "input-$1")
                  ]
                }),
                F(r, {
                  props: [
                    l(i, /:(plac\w+)/, ":" + K + "$1")
                  ]
                }),
                F(r, {
                  props: [
                    l(i, /:(plac\w+)/, w + "input-$1")
                  ]
                })
              ], a);
          }
          return "";
        });
    }
  };
  br = [
    yr
  ];
  pr = function(r) {
    var t = r.key;
    if (t === "css") {
      var n = document.querySelectorAll("style[data-emotion]:not([data-s])");
      Array.prototype.forEach.call(n, function(v) {
        var x = v.getAttribute("data-emotion");
        x.indexOf(" ") !== -1 && (document.head.appendChild(v), v.setAttribute("data-s", ""));
      });
    }
    var a = r.stylisPlugins || br, i = {}, s, c = [];
    s = r.container || document.head, Array.prototype.forEach.call(document.querySelectorAll('style[data-emotion^="' + t + ' "]'), function(v) {
      for (var x = v.getAttribute("data-emotion").split(" "), g = 1; g < x.length; g++) i[x[g]] = true;
      c.push(v);
    });
    var f, u = [
      vr,
      gr
    ];
    {
      var o, d = [
        or,
        hr(function(v) {
          o.insert(v);
        })
      ], O = ur(u.concat(a, d)), N = function(x) {
        return z(cr(x), O);
      };
      f = function(x, g, p, $) {
        o = p, N(x ? x + "{" + g.styles + "}" : g.styles), $ && (S.inserted[g.name] = true);
      };
    }
    var S = {
      key: t,
      sheet: new Be({
        key: t,
        container: s,
        nonce: r.nonce,
        speedy: r.speedy,
        prepend: r.prepend,
        insertionPoint: r.insertionPoint
      }),
      nonce: r.nonce,
      inserted: i,
      registered: {},
      insert: f
    };
    return S.sheet.hydrate(c), S;
  };
  wr = function(e, r) {
    return ze(e, r);
  };
  const E = await Y("react"), { useContext: We, forwardRef: xr } = await Y("react");
  let he, Cr, Sr;
  he = E.createContext(typeof HTMLElement < "u" ? pr({
    key: "css"
  }) : null);
  Mr = he.Provider;
  Wr = function() {
    return We(he);
  };
  le = function(r) {
    return xr(function(t, n) {
      var a = We(he);
      return r(t, a, n);
    });
  };
  W = E.createContext({});
  zr = function() {
    return E.useContext(W);
  };
  Cr = function(r, t) {
    if (typeof t == "function") {
      var n = t(r);
      return n;
    }
    return Se({}, r, t);
  };
  Sr = we(function(e) {
    return we(function(r) {
      return Cr(e, r);
    });
  });
  Lr = function(r) {
    var t = E.useContext(W);
    return r.theme !== t && (t = Sr(t)(r.theme)), E.createElement(W.Provider, {
      value: t
    }, r.children);
  };
  _r = function(e) {
    var r = e.displayName || e.name || "Component", t = E.forwardRef(function(a, i) {
      var s = E.useContext(W);
      return E.createElement(e, Se({
        theme: s,
        ref: i
      }, a));
    });
    return t.displayName = "WithTheme(" + r + ")", wr(t, e);
  };
  var de = {}.hasOwnProperty, ie = "__EMOTION_TYPE_PLEASE_DO_NOT_USE__", Er = function(r, t) {
    var n = {};
    for (var a in t) de.call(t, a) && (n[a] = t[a]);
    return n[ie] = r, n;
  }, kr = function(r) {
    var t = r.cache, n = r.serialized, a = r.isStringTag;
    return se(t, n, a), $e(function() {
      return ce(t, n, a);
    }), null;
  }, $r = le(function(e, r, t) {
    var n = e.css;
    typeof n == "string" && r.registered[n] !== void 0 && (n = r.registered[n]);
    var a = e[ie], i = [
      n
    ], s = "";
    typeof e.className == "string" ? s = Ae(r.registered, i, e.className) : e.className != null && (s = e.className + " ");
    var c = U(i, void 0, E.useContext(W));
    s += r.key + "-" + c.name;
    var f = {};
    for (var u in e) de.call(e, u) && u !== "css" && u !== ie && (f[u] = e[u]);
    return f.className = s, t && (f.ref = t), E.createElement(E.Fragment, null, E.createElement(kr, {
      cache: r,
      serialized: c,
      isStringTag: typeof a == "string"
    }), E.createElement(a, f));
  }), Ar = $r;
  const I = await Y("react");
  Ce = function(r, t) {
    var n = arguments;
    if (t == null || !de.call(t, "css")) return I.createElement.apply(void 0, n);
    var a = n.length, i = new Array(a);
    i[0] = Ar, i[1] = Er(r, t);
    for (var s = 2; s < a; s++) i[s] = n[s];
    return I.createElement.apply(null, i);
  };
  (function(e) {
    var r;
    r || (r = e.JSX || (e.JSX = {}));
  })(Ce || (Ce = {}));
  Fr = le(function(e, r) {
    var t = e.styles, n = U([
      t
    ], void 0, I.useContext(W)), a = I.useRef();
    return ye(function() {
      var i = r.key + "-global", s = new r.sheet.constructor({
        key: i,
        nonce: r.sheet.nonce,
        container: r.sheet.container,
        speedy: r.sheet.isSpeedy
      }), c = false, f = document.querySelector('style[data-emotion="' + i + " " + n.name + '"]');
      return r.sheet.tags.length && (s.before = r.sheet.tags[0]), f !== null && (c = true, f.setAttribute("data-emotion", i), s.hydrate([
        f
      ])), a.current = [
        s,
        c
      ], function() {
        s.flush();
      };
    }, [
      r
    ]), ye(function() {
      var i = a.current, s = i[0], c = i[1];
      if (c) {
        i[1] = false;
        return;
      }
      if (n.next !== void 0 && ce(r, n.next, true), s.tags.length) {
        var f = s.tags[s.tags.length - 1].nextElementSibling;
        s.before = f, s.flush();
      }
      r.insert("", n, s, false);
    }, [
      r,
      n.name
    ]), null;
  });
  Rr = function() {
    for (var e = arguments.length, r = new Array(e), t = 0; t < e; t++) r[t] = arguments[t];
    return U(r);
  };
  Gr = function() {
    var e = Rr.apply(void 0, arguments), r = "animation-" + e.name;
    return {
      name: r,
      styles: "@keyframes " + r + "{" + e.styles + "}",
      anim: 1,
      toString: function() {
        return "_EMO_" + this.name + "_" + this.styles + "_EMO_";
      }
    };
  };
  var Tr = function e(r) {
    for (var t = r.length, n = 0, a = ""; n < t; n++) {
      var i = r[n];
      if (i != null) {
        var s = void 0;
        switch (typeof i) {
          case "boolean":
            break;
          case "object": {
            if (Array.isArray(i)) s = e(i);
            else {
              s = "";
              for (var c in i) i[c] && c && (s && (s += " "), s += c);
            }
            break;
          }
          default:
            s = i;
        }
        s && (a && (a += " "), a += s);
      }
    }
    return a;
  };
  function Pr(e, r, t) {
    var n = [], a = Ae(e, n, t);
    return n.length < 2 ? t : a + r(n);
  }
  let Or;
  Or = function(r) {
    var t = r.cache, n = r.serializedArr;
    return $e(function() {
      for (var a = 0; a < n.length; a++) ce(t, n[a], false);
    }), null;
  };
  jr = le(function(e, r) {
    var t = [], n = function() {
      for (var f = arguments.length, u = new Array(f), o = 0; o < f; o++) u[o] = arguments[o];
      var d = U(u, r.registered);
      return t.push(d), se(r, d, false), r.key + "-" + d.name;
    }, a = function() {
      for (var f = arguments.length, u = new Array(f), o = 0; o < f; o++) u[o] = arguments[o];
      return Pr(r.registered, n, Tr(u));
    }, i = {
      css: n,
      cx: a,
      theme: I.useContext(W)
    }, s = e.children(i);
    return I.createElement(I.Fragment, null, I.createElement(Or, {
      cache: r,
      serializedArr: t
    }), s);
  });
});
export {
  Mr as C,
  Fr as G,
  W as T,
  Wr as _,
  __tla,
  Rr as a,
  jr as b,
  pr as c,
  Lr as d,
  zr as e,
  _r as f,
  Ae as g,
  ce as i,
  Ce as j,
  Gr as k,
  Fe as m,
  se as r,
  U as s,
  $e as u,
  le as w
};
