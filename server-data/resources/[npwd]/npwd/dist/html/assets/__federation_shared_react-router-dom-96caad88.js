import { importShared as Fe, __tla as __tla_0 } from "./__federation_fn_import-6f6f420b.js";
import { _ as k, a as re } from "./inheritsLoose-82a311a4.js";
import { P as Te } from "./index-8d47fad6.js";
import { _ as M, h as nt } from "./hoist-non-react-statics.cjs-ef94205d.js";
import { g as rt } from "./_commonjsHelpers-de833af9.js";
let un, fn, Gt, Yt, ln, Zt, en, tn, ce, nn, rn, Ne, ue, on, Ft, sn, cn, an;
let __tla = Promise.all([
  (() => {
    try {
      return __tla_0;
    } catch {
    }
  })()
]).then(async () => {
  function ie(e) {
    return e.charAt(0) === "/";
  }
  function he(e, t) {
    for (var n = t, i = n + 1, r = e.length; i < r; n += 1, i += 1)
      e[n] = e[i];
    e.pop();
  }
  function it(e, t) {
    t === void 0 && (t = "");
    var n = e && e.split("/") || [], i = t && t.split("/") || [], r = e && ie(e), a = t && ie(t), c = r || a;
    if (e && ie(e) ? i = n : n.length && (i.pop(), i = i.concat(n)), !i.length)
      return "/";
    var s;
    if (i.length) {
      var f = i[i.length - 1];
      s = f === "." || f === ".." || f === "";
    } else
      s = false;
    for (var o = 0, u = i.length; u >= 0; u--) {
      var l = i[u];
      l === "." ? he(i, u) : l === ".." ? (he(i, u), o++) : o && (he(i, u), o--);
    }
    if (!c)
      for (; o--; o)
        i.unshift("..");
    c && i[0] !== "" && (!i[0] || !ie(i[0])) && i.unshift("");
    var h = i.join("/");
    return s && h.substr(-1) !== "/" && (h += "/"), h;
  }
  function be(e) {
    return e.valueOf ? e.valueOf() : Object.prototype.valueOf.call(e);
  }
  function ae(e, t) {
    if (e === t)
      return true;
    if (e == null || t == null)
      return false;
    if (Array.isArray(e))
      return Array.isArray(t) && e.length === t.length && e.every(function(r, a) {
        return ae(r, t[a]);
      });
    if (typeof e == "object" || typeof t == "object") {
      var n = be(e), i = be(t);
      return n !== e || i !== t ? ae(n, i) : Object.keys(Object.assign({}, e, t)).every(function(r) {
        return ae(e[r], t[r]);
      });
    }
    return false;
  }
  var at = true, ve = "Invariant failed";
  function z(e, t) {
    if (!e) {
      if (at)
        throw new Error(ve);
      var n = typeof t == "function" ? t() : t, i = n ? "".concat(ve, ": ").concat(n) : ve;
      throw new Error(i);
    }
  }
  function ne(e) {
    return e.charAt(0) === "/" ? e : "/" + e;
  }
  function Oe(e) {
    return e.charAt(0) === "/" ? e.substr(1) : e;
  }
  function ot(e, t) {
    return e.toLowerCase().indexOf(t.toLowerCase()) === 0 && "/?#".indexOf(e.charAt(t.length)) !== -1;
  }
  function Ke(e, t) {
    return ot(e, t) ? e.substr(t.length) : e;
  }
  function qe(e) {
    return e.charAt(e.length - 1) === "/" ? e.slice(0, -1) : e;
  }
  function st(e) {
    var t = e || "/", n = "", i = "", r = t.indexOf("#");
    r !== -1 && (i = t.substr(r), t = t.substr(0, r));
    var a = t.indexOf("?");
    return a !== -1 && (n = t.substr(a), t = t.substr(0, a)), {
      pathname: t,
      search: n === "?" ? "" : n,
      hash: i === "#" ? "" : i
    };
  }
  function D(e) {
    var t = e.pathname, n = e.search, i = e.hash, r = t || "/";
    return n && n !== "?" && (r += n.charAt(0) === "?" ? n : "?" + n), i && i !== "#" && (r += i.charAt(0) === "#" ? i : "#" + i), r;
  }
  function I(e, t, n, i) {
    var r;
    typeof e == "string" ? (r = st(e), r.state = t) : (r = M({}, e), r.pathname === void 0 && (r.pathname = ""), r.search ? r.search.charAt(0) !== "?" && (r.search = "?" + r.search) : r.search = "", r.hash ? r.hash.charAt(0) !== "#" && (r.hash = "#" + r.hash) : r.hash = "", t !== void 0 && r.state === void 0 && (r.state = t));
    try {
      r.pathname = decodeURI(r.pathname);
    } catch (a) {
      throw a instanceof URIError ? new URIError('Pathname "' + r.pathname + '" could not be decoded. This is likely caused by an invalid percent-encoding.') : a;
    }
    return n && (r.key = n), i ? r.pathname ? r.pathname.charAt(0) !== "/" && (r.pathname = it(r.pathname, i.pathname)) : r.pathname = i.pathname : r.pathname || (r.pathname = "/"), r;
  }
  function ct(e, t) {
    return e.pathname === t.pathname && e.search === t.search && e.hash === t.hash && e.key === t.key && ae(e.state, t.state);
  }
  function xe() {
    var e = null;
    function t(c) {
      return e = c, function() {
        e === c && (e = null);
      };
    }
    function n(c, s, f, o) {
      if (e != null) {
        var u = typeof e == "function" ? e(c, s) : e;
        typeof u == "string" ? typeof f == "function" ? f(u, o) : o(true) : o(u !== false);
      } else
        o(true);
    }
    var i = [];
    function r(c) {
      var s = true;
      function f() {
        s && c.apply(void 0, arguments);
      }
      return i.push(f), function() {
        s = false, i = i.filter(function(o) {
          return o !== f;
        });
      };
    }
    function a() {
      for (var c = arguments.length, s = new Array(c), f = 0; f < c; f++)
        s[f] = arguments[f];
      i.forEach(function(o) {
        return o.apply(void 0, s);
      });
    }
    return {
      setPrompt: t,
      confirmTransitionTo: n,
      appendListener: r,
      notifyListeners: a
    };
  }
  var Ge = !!(typeof window < "u" && window.document && window.document.createElement);
  function ke(e, t) {
    t(window.confirm(e));
  }
  function ut() {
    var e = window.navigator.userAgent;
    return (e.indexOf("Android 2.") !== -1 || e.indexOf("Android 4.0") !== -1) && e.indexOf("Mobile Safari") !== -1 && e.indexOf("Chrome") === -1 && e.indexOf("Windows Phone") === -1 ? false : window.history && "pushState" in window.history;
  }
  function ft() {
    return window.navigator.userAgent.indexOf("Trident") === -1;
  }
  function lt() {
    return window.navigator.userAgent.indexOf("Firefox") === -1;
  }
  function ht(e) {
    return e.state === void 0 && navigator.userAgent.indexOf("CriOS") === -1;
  }
  var Se = "popstate", Ue = "hashchange";
  function Me() {
    try {
      return window.history.state || {};
    } catch {
      return {};
    }
  }
  function vt(e) {
    e === void 0 && (e = {}), Ge || z(false);
    var t = window.history, n = ut(), i = !ft(), r = e, a = r.forceRefresh, c = a === void 0 ? false : a, s = r.getUserConfirmation, f = s === void 0 ? ke : s, o = r.keyLength, u = o === void 0 ? 6 : o, l = e.basename ? qe(ne(e.basename)) : "";
    function h(d) {
      var v = d || {}, w = v.key, m = v.state, E = window.location, U = E.pathname, W = E.search, q = E.hash, F = U + W + q;
      return l && (F = Ke(F, l)), I(F, m, w);
    }
    function p() {
      return Math.random().toString(36).substr(2, u);
    }
    var g = xe();
    function C(d) {
      M(j, d), j.length = t.length, g.notifyListeners(j.location, j.action);
    }
    function R(d) {
      ht(d) || B(h(d.state));
    }
    function A() {
      B(h(Me()));
    }
    var S = false;
    function B(d) {
      if (S)
        S = false, C();
      else {
        var v = "POP";
        g.confirmTransitionTo(d, v, f, function(w) {
          w ? C({
            action: v,
            location: d
          }) : N(d);
        });
      }
    }
    function N(d) {
      var v = j.location, w = L.indexOf(v.key);
      w === -1 && (w = 0);
      var m = L.indexOf(d.key);
      m === -1 && (m = 0);
      var E = w - m;
      E && (S = true, T(E));
    }
    var H = h(Me()), L = [
      H.key
    ];
    function y(d) {
      return l + D(d);
    }
    function x(d, v) {
      var w = "PUSH", m = I(d, v, p(), j.location);
      g.confirmTransitionTo(m, w, f, function(E) {
        if (E) {
          var U = y(m), W = m.key, q = m.state;
          if (n)
            if (t.pushState({
              key: W,
              state: q
            }, null, U), c)
              window.location.href = U;
            else {
              var F = L.indexOf(j.location.key), X = L.slice(0, F + 1);
              X.push(m.key), L = X, C({
                action: w,
                location: m
              });
            }
          else
            window.location.href = U;
        }
      });
    }
    function O(d, v) {
      var w = "REPLACE", m = I(d, v, p(), j.location);
      g.confirmTransitionTo(m, w, f, function(E) {
        if (E) {
          var U = y(m), W = m.key, q = m.state;
          if (n)
            if (t.replaceState({
              key: W,
              state: q
            }, null, U), c)
              window.location.replace(U);
            else {
              var F = L.indexOf(j.location.key);
              F !== -1 && (L[F] = m.key), C({
                action: w,
                location: m
              });
            }
          else
            window.location.replace(U);
        }
      });
    }
    function T(d) {
      t.go(d);
    }
    function b() {
      T(-1);
    }
    function J() {
      T(1);
    }
    var V = 0;
    function _(d) {
      V += d, V === 1 && d === 1 ? (window.addEventListener(Se, R), i && window.addEventListener(Ue, A)) : V === 0 && (window.removeEventListener(Se, R), i && window.removeEventListener(Ue, A));
    }
    var $ = false;
    function Y(d) {
      d === void 0 && (d = false);
      var v = g.setPrompt(d);
      return $ || (_(1), $ = true), function() {
        return $ && ($ = false, _(-1)), v();
      };
    }
    function le(d) {
      var v = g.appendListener(d);
      return _(1), function() {
        _(-1), v();
      };
    }
    var j = {
      length: t.length,
      action: "POP",
      location: H,
      createHref: y,
      push: x,
      replace: O,
      go: T,
      goBack: b,
      goForward: J,
      block: Y,
      listen: le
    };
    return j;
  }
  var He = "hashchange", pt = {
    hashbang: {
      encodePath: function(t) {
        return t.charAt(0) === "!" ? t : "!/" + Oe(t);
      },
      decodePath: function(t) {
        return t.charAt(0) === "!" ? t.substr(1) : t;
      }
    },
    noslash: {
      encodePath: Oe,
      decodePath: ne
    },
    slash: {
      encodePath: ne,
      decodePath: ne
    }
  };
  function ze(e) {
    var t = e.indexOf("#");
    return t === -1 ? e : e.slice(0, t);
  }
  function te() {
    var e = window.location.href, t = e.indexOf("#");
    return t === -1 ? "" : e.substring(t + 1);
  }
  function dt(e) {
    window.location.hash = e;
  }
  function pe(e) {
    window.location.replace(ze(window.location.href) + "#" + e);
  }
  function mt(e) {
    e === void 0 && (e = {}), Ge || z(false);
    var t = window.history;
    lt();
    var n = e, i = n.getUserConfirmation, r = i === void 0 ? ke : i, a = n.hashType, c = a === void 0 ? "slash" : a, s = e.basename ? qe(ne(e.basename)) : "", f = pt[c], o = f.encodePath, u = f.decodePath;
    function l() {
      var v = u(te());
      return s && (v = Ke(v, s)), I(v);
    }
    var h = xe();
    function p(v) {
      M(d, v), d.length = t.length, h.notifyListeners(d.location, d.action);
    }
    var g = false, C = null;
    function R(v, w) {
      return v.pathname === w.pathname && v.search === w.search && v.hash === w.hash;
    }
    function A() {
      var v = te(), w = o(v);
      if (v !== w)
        pe(w);
      else {
        var m = l(), E = d.location;
        if (!g && R(E, m) || C === D(m))
          return;
        C = null, S(m);
      }
    }
    function S(v) {
      if (g)
        g = false, p();
      else {
        var w = "POP";
        h.confirmTransitionTo(v, w, r, function(m) {
          m ? p({
            action: w,
            location: v
          }) : B(v);
        });
      }
    }
    function B(v) {
      var w = d.location, m = y.lastIndexOf(D(w));
      m === -1 && (m = 0);
      var E = y.lastIndexOf(D(v));
      E === -1 && (E = 0);
      var U = m - E;
      U && (g = true, b(U));
    }
    var N = te(), H = o(N);
    N !== H && pe(H);
    var L = l(), y = [
      D(L)
    ];
    function x(v) {
      var w = document.querySelector("base"), m = "";
      return w && w.getAttribute("href") && (m = ze(window.location.href)), m + "#" + o(s + D(v));
    }
    function O(v, w) {
      var m = "PUSH", E = I(v, void 0, void 0, d.location);
      h.confirmTransitionTo(E, m, r, function(U) {
        if (U) {
          var W = D(E), q = o(s + W), F = te() !== q;
          if (F) {
            C = W, dt(q);
            var X = y.lastIndexOf(D(d.location)), Ae = y.slice(0, X + 1);
            Ae.push(W), y = Ae, p({
              action: m,
              location: E
            });
          } else
            p();
        }
      });
    }
    function T(v, w) {
      var m = "REPLACE", E = I(v, void 0, void 0, d.location);
      h.confirmTransitionTo(E, m, r, function(U) {
        if (U) {
          var W = D(E), q = o(s + W), F = te() !== q;
          F && (C = W, pe(q));
          var X = y.indexOf(D(d.location));
          X !== -1 && (y[X] = W), p({
            action: m,
            location: E
          });
        }
      });
    }
    function b(v) {
      t.go(v);
    }
    function J() {
      b(-1);
    }
    function V() {
      b(1);
    }
    var _ = 0;
    function $(v) {
      _ += v, _ === 1 && v === 1 ? window.addEventListener(He, A) : _ === 0 && window.removeEventListener(He, A);
    }
    var Y = false;
    function le(v) {
      v === void 0 && (v = false);
      var w = h.setPrompt(v);
      return Y || ($(1), Y = true), function() {
        return Y && (Y = false, $(-1)), w();
      };
    }
    function j(v) {
      var w = h.appendListener(v);
      return $(1), function() {
        $(-1), w();
      };
    }
    var d = {
      length: t.length,
      action: "POP",
      location: L,
      createHref: x,
      push: O,
      replace: T,
      go: b,
      goBack: J,
      goForward: V,
      block: le,
      listen: j
    };
    return d;
  }
  function $e(e, t, n) {
    return Math.min(Math.max(e, t), n);
  }
  function gt(e) {
    e === void 0 && (e = {});
    var t = e, n = t.getUserConfirmation, i = t.initialEntries, r = i === void 0 ? [
      "/"
    ] : i, a = t.initialIndex, c = a === void 0 ? 0 : a, s = t.keyLength, f = s === void 0 ? 6 : s, o = xe();
    function u(x) {
      M(y, x), y.length = y.entries.length, o.notifyListeners(y.location, y.action);
    }
    function l() {
      return Math.random().toString(36).substr(2, f);
    }
    var h = $e(c, 0, r.length - 1), p = r.map(function(x) {
      return typeof x == "string" ? I(x, void 0, l()) : I(x, void 0, x.key || l());
    }), g = D;
    function C(x, O) {
      var T = "PUSH", b = I(x, O, l(), y.location);
      o.confirmTransitionTo(b, T, n, function(J) {
        if (J) {
          var V = y.index, _ = V + 1, $ = y.entries.slice(0);
          $.length > _ ? $.splice(_, $.length - _, b) : $.push(b), u({
            action: T,
            location: b,
            index: _,
            entries: $
          });
        }
      });
    }
    function R(x, O) {
      var T = "REPLACE", b = I(x, O, l(), y.location);
      o.confirmTransitionTo(b, T, n, function(J) {
        J && (y.entries[y.index] = b, u({
          action: T,
          location: b
        }));
      });
    }
    function A(x) {
      var O = $e(y.index + x, 0, y.entries.length - 1), T = "POP", b = y.entries[O];
      o.confirmTransitionTo(b, T, n, function(J) {
        J ? u({
          action: T,
          location: b,
          index: O
        }) : u();
      });
    }
    function S() {
      A(-1);
    }
    function B() {
      A(1);
    }
    function N(x) {
      var O = y.index + x;
      return O >= 0 && O < y.entries.length;
    }
    function H(x) {
      return x === void 0 && (x = false), o.setPrompt(x);
    }
    function L(x) {
      return o.appendListener(x);
    }
    var y = {
      length: p.length,
      action: "POP",
      location: p[h],
      index: h,
      entries: p,
      createHref: g,
      push: C,
      replace: R,
      go: A,
      goBack: S,
      goForward: B,
      canGo: N,
      block: H,
      listen: L
    };
    return y;
  }
  var ee = {
    exports: {}
  }, yt = Array.isArray || function(e) {
    return Object.prototype.toString.call(e) == "[object Array]";
  }, oe = yt;
  ee.exports = Xe;
  ee.exports.parse = Pe;
  ee.exports.compile = Pt;
  ee.exports.tokensToFunction = Je;
  ee.exports.tokensToRegExp = Ve;
  var wt = new RegExp([
    "(\\\\.)",
    "([\\/.])?(?:(?:\\:(\\w+)(?:\\(((?:\\\\.|[^\\\\()])+)\\))?|\\(((?:\\\\.|[^\\\\()])+)\\))([+*?])?|(\\*))"
  ].join("|"), "g");
  function Pe(e, t) {
    for (var n = [], i = 0, r = 0, a = "", c = t && t.delimiter || "/", s; (s = wt.exec(e)) != null; ) {
      var f = s[0], o = s[1], u = s.index;
      if (a += e.slice(r, u), r = u + f.length, o) {
        a += o[1];
        continue;
      }
      var l = e[r], h = s[2], p = s[3], g = s[4], C = s[5], R = s[6], A = s[7];
      a && (n.push(a), a = "");
      var S = h != null && l != null && l !== h, B = R === "+" || R === "*", N = R === "?" || R === "*", H = h || c, L = g || C, y = h || (typeof n[n.length - 1] == "string" ? n[n.length - 1] : "");
      n.push({
        name: p || i++,
        prefix: h || "",
        delimiter: H,
        optional: N,
        repeat: B,
        partial: S,
        asterisk: !!A,
        pattern: L ? Rt(L) : A ? ".*" : xt(H, y)
      });
    }
    return r < e.length && (a += e.substr(r)), a && n.push(a), n;
  }
  function xt(e, t) {
    return !t || t.indexOf(e) > -1 ? "[^" + Q(e) + "]+?" : Q(t) + "|(?:(?!" + Q(t) + ")[^" + Q(e) + "])+?";
  }
  function Pt(e, t) {
    return Je(Pe(e, t), t);
  }
  function Et(e) {
    return encodeURI(e).replace(/[\/?#]/g, function(t) {
      return "%" + t.charCodeAt(0).toString(16).toUpperCase();
    });
  }
  function Ct(e) {
    return encodeURI(e).replace(/[?#]/g, function(t) {
      return "%" + t.charCodeAt(0).toString(16).toUpperCase();
    });
  }
  function Je(e, t) {
    for (var n = new Array(e.length), i = 0; i < e.length; i++)
      typeof e[i] == "object" && (n[i] = new RegExp("^(?:" + e[i].pattern + ")$", Ce(t)));
    return function(r, a) {
      for (var c = "", s = r || {}, f = a || {}, o = f.pretty ? Et : encodeURIComponent, u = 0; u < e.length; u++) {
        var l = e[u];
        if (typeof l == "string") {
          c += l;
          continue;
        }
        var h = s[l.name], p;
        if (h == null)
          if (l.optional) {
            l.partial && (c += l.prefix);
            continue;
          } else
            throw new TypeError('Expected "' + l.name + '" to be defined');
        if (oe(h)) {
          if (!l.repeat)
            throw new TypeError('Expected "' + l.name + '" to not repeat, but received `' + JSON.stringify(h) + "`");
          if (h.length === 0) {
            if (l.optional)
              continue;
            throw new TypeError('Expected "' + l.name + '" to not be empty');
          }
          for (var g = 0; g < h.length; g++) {
            if (p = o(h[g]), !n[u].test(p))
              throw new TypeError('Expected all "' + l.name + '" to match "' + l.pattern + '", but received `' + JSON.stringify(p) + "`");
            c += (g === 0 ? l.prefix : l.delimiter) + p;
          }
          continue;
        }
        if (p = l.asterisk ? Ct(h) : o(h), !n[u].test(p))
          throw new TypeError('Expected "' + l.name + '" to match "' + l.pattern + '", but received "' + p + '"');
        c += l.prefix + p;
      }
      return c;
    };
  }
  function Q(e) {
    return e.replace(/([.+*?=^!:${}()[\]|\/\\])/g, "\\$1");
  }
  function Rt(e) {
    return e.replace(/([=!:$\/()])/g, "\\$1");
  }
  function Ee(e, t) {
    return e.keys = t, e;
  }
  function Ce(e) {
    return e && e.sensitive ? "" : "i";
  }
  function Lt(e, t) {
    var n = e.source.match(/\((?!\?)/g);
    if (n)
      for (var i = 0; i < n.length; i++)
        t.push({
          name: i,
          prefix: null,
          delimiter: null,
          optional: false,
          repeat: false,
          partial: false,
          asterisk: false,
          pattern: null
        });
    return Ee(e, t);
  }
  function At(e, t, n) {
    for (var i = [], r = 0; r < e.length; r++)
      i.push(Xe(e[r], t, n).source);
    var a = new RegExp("(?:" + i.join("|") + ")", Ce(n));
    return Ee(a, t);
  }
  function Tt(e, t, n) {
    return Ve(Pe(e, n), t, n);
  }
  function Ve(e, t, n) {
    oe(t) || (n = t || n, t = []), n = n || {};
    for (var i = n.strict, r = n.end !== false, a = "", c = 0; c < e.length; c++) {
      var s = e[c];
      if (typeof s == "string")
        a += Q(s);
      else {
        var f = Q(s.prefix), o = "(?:" + s.pattern + ")";
        t.push(s), s.repeat && (o += "(?:" + f + o + ")*"), s.optional ? s.partial ? o = f + "(" + o + ")?" : o = "(?:" + f + "(" + o + "))?" : o = f + "(" + o + ")", a += o;
      }
    }
    var u = Q(n.delimiter || "/"), l = a.slice(-u.length) === u;
    return i || (a = (l ? a.slice(0, -u.length) : a) + "(?:" + u + "(?=$))?"), r ? a += "$" : a += i && l ? "" : "(?=" + u + "|$)", Ee(new RegExp("^" + a, Ce(n)), t);
  }
  function Xe(e, t, n) {
    return oe(t) || (n = t || n, t = []), n = n || {}, e instanceof RegExp ? Lt(e, t) : oe(e) ? At(e, t, n) : Tt(e, t, n);
  }
  var bt = ee.exports;
  const Qe = rt(bt), P = await Fe("react");
  var de = 1073741823, Ie = typeof globalThis < "u" ? globalThis : typeof window < "u" ? window : typeof global < "u" ? global : {};
  function Ot() {
    var e = "__global_unique_id__";
    return Ie[e] = (Ie[e] || 0) + 1;
  }
  function St(e, t) {
    return e === t ? e !== 0 || 1 / e === 1 / t : e !== e && t !== t;
  }
  function Ut(e) {
    var t = [];
    return {
      on: function(i) {
        t.push(i);
      },
      off: function(i) {
        t = t.filter(function(r) {
          return r !== i;
        });
      },
      get: function() {
        return e;
      },
      set: function(i, r) {
        e = i, t.forEach(function(a) {
          return a(e, r);
        });
      }
    };
  }
  function Mt(e) {
    return Array.isArray(e) ? e[0] : e;
  }
  function Ht(e, t) {
    var n, i, r = "__create-react-context-" + Ot() + "__", a = function(s) {
      k(f, s);
      function f() {
        for (var u, l = arguments.length, h = new Array(l), p = 0; p < l; p++)
          h[p] = arguments[p];
        return u = s.call.apply(s, [
          this
        ].concat(h)) || this, u.emitter = Ut(u.props.value), u;
      }
      var o = f.prototype;
      return o.getChildContext = function() {
        var l;
        return l = {}, l[r] = this.emitter, l;
      }, o.componentWillReceiveProps = function(l) {
        if (this.props.value !== l.value) {
          var h = this.props.value, p = l.value, g;
          St(h, p) ? g = 0 : (g = typeof t == "function" ? t(h, p) : de, g |= 0, g !== 0 && this.emitter.set(l.value, g));
        }
      }, o.render = function() {
        return this.props.children;
      }, f;
    }(P.Component);
    a.childContextTypes = (n = {}, n[r] = Te.object.isRequired, n);
    var c = function(s) {
      k(f, s);
      function f() {
        for (var u, l = arguments.length, h = new Array(l), p = 0; p < l; p++)
          h[p] = arguments[p];
        return u = s.call.apply(s, [
          this
        ].concat(h)) || this, u.observedBits = void 0, u.state = {
          value: u.getValue()
        }, u.onUpdate = function(g, C) {
          var R = u.observedBits | 0;
          R & C && u.setState({
            value: u.getValue()
          });
        }, u;
      }
      var o = f.prototype;
      return o.componentWillReceiveProps = function(l) {
        var h = l.observedBits;
        this.observedBits = h ?? de;
      }, o.componentDidMount = function() {
        this.context[r] && this.context[r].on(this.onUpdate);
        var l = this.props.observedBits;
        this.observedBits = l ?? de;
      }, o.componentWillUnmount = function() {
        this.context[r] && this.context[r].off(this.onUpdate);
      }, o.getValue = function() {
        return this.context[r] ? this.context[r].get() : e;
      }, o.render = function() {
        return Mt(this.props.children)(this.state.value);
      }, f;
    }(P.Component);
    return c.contextTypes = (i = {}, i[r] = Te.object, i), {
      Provider: a,
      Consumer: c
    };
  }
  let $t, Ye, Ze, K, et;
  $t = P.createContext || Ht;
  Ye = function(t) {
    var n = $t();
    return n.displayName = t, n;
  };
  Ze = Ye("Router-History");
  K = Ye("Router");
  ce = function(e) {
    k(t, e), t.computeRootMatch = function(r) {
      return {
        path: "/",
        url: "/",
        params: {},
        isExact: r === "/"
      };
    };
    function t(i) {
      var r;
      return r = e.call(this, i) || this, r.state = {
        location: i.history.location
      }, r._isMounted = false, r._pendingLocation = null, i.staticContext || (r.unlisten = i.history.listen(function(a) {
        r._pendingLocation = a;
      })), r;
    }
    var n = t.prototype;
    return n.componentDidMount = function() {
      var r = this;
      this._isMounted = true, this.unlisten && this.unlisten(), this.props.staticContext || (this.unlisten = this.props.history.listen(function(a) {
        r._isMounted && r.setState({
          location: a
        });
      })), this._pendingLocation && this.setState({
        location: this._pendingLocation
      });
    }, n.componentWillUnmount = function() {
      this.unlisten && (this.unlisten(), this._isMounted = false, this._pendingLocation = null);
    }, n.render = function() {
      return P.createElement(K.Provider, {
        value: {
          history: this.props.history,
          location: this.state.location,
          match: t.computeRootMatch(this.state.location.pathname),
          staticContext: this.props.staticContext
        }
      }, P.createElement(Ze.Provider, {
        children: this.props.children || null,
        value: this.props.history
      }));
    }, t;
  }(P.Component);
  Yt = function(e) {
    k(t, e);
    function t() {
      for (var i, r = arguments.length, a = new Array(r), c = 0; c < r; c++)
        a[c] = arguments[c];
      return i = e.call.apply(e, [
        this
      ].concat(a)) || this, i.history = gt(i.props), i;
    }
    var n = t.prototype;
    return n.render = function() {
      return P.createElement(ce, {
        history: this.history,
        children: this.props.children
      });
    }, t;
  }(P.Component);
  et = function(e) {
    k(t, e);
    function t() {
      return e.apply(this, arguments) || this;
    }
    var n = t.prototype;
    return n.componentDidMount = function() {
      this.props.onMount && this.props.onMount.call(this, this);
    }, n.componentDidUpdate = function(r) {
      this.props.onUpdate && this.props.onUpdate.call(this, this, r);
    }, n.componentWillUnmount = function() {
      this.props.onUnmount && this.props.onUnmount.call(this, this);
    }, n.render = function() {
      return null;
    }, t;
  }(P.Component);
  Zt = function(e) {
    var t = e.message, n = e.when, i = n === void 0 ? true : n;
    return P.createElement(K.Consumer, null, function(r) {
      if (r || z(false), !i || r.staticContext)
        return null;
      var a = r.history.block;
      return P.createElement(et, {
        onMount: function(s) {
          s.release = a(t);
        },
        onUpdate: function(s, f) {
          f.message !== t && (s.release(), s.release = a(t));
        },
        onUnmount: function(s) {
          s.release();
        },
        message: t
      });
    });
  };
  var me = {}, It = 1e4, Be = 0;
  function Bt(e) {
    if (me[e])
      return me[e];
    var t = Qe.compile(e);
    return Be < It && (me[e] = t, Be++), t;
  }
  Ne = function(e, t) {
    return e === void 0 && (e = "/"), t === void 0 && (t = {}), e === "/" ? e : Bt(e)(t, {
      pretty: true
    });
  };
  en = function(e) {
    var t = e.computedMatch, n = e.to, i = e.push, r = i === void 0 ? false : i;
    return P.createElement(K.Consumer, null, function(a) {
      a || z(false);
      var c = a.history, s = a.staticContext, f = r ? c.push : c.replace, o = I(t ? typeof n == "string" ? Ne(n, t.params) : M({}, n, {
        pathname: Ne(n.pathname, t.params)
      }) : n);
      return s ? (f(o), null) : P.createElement(et, {
        onMount: function() {
          f(o);
        },
        onUpdate: function(l, h) {
          var p = I(h.to);
          ct(p, M({}, o, {
            key: p.key
          })) || f(o);
        },
        to: n
      });
    });
  };
  var De = {}, Nt = 1e4, _e = 0;
  function Dt(e, t) {
    var n = "" + t.end + t.strict + t.sensitive, i = De[n] || (De[n] = {});
    if (i[e])
      return i[e];
    var r = [], a = Qe(e, r, t), c = {
      regexp: a,
      keys: r
    };
    return _e < Nt && (i[e] = c, _e++), c;
  }
  ue = function(e, t) {
    t === void 0 && (t = {}), (typeof t == "string" || Array.isArray(t)) && (t = {
      path: t
    });
    var n = t, i = n.path, r = n.exact, a = r === void 0 ? false : r, c = n.strict, s = c === void 0 ? false : c, f = n.sensitive, o = f === void 0 ? false : f, u = [].concat(i);
    return u.reduce(function(l, h) {
      if (!h && h !== "")
        return null;
      if (l)
        return l;
      var p = Dt(h, {
        end: a,
        strict: s,
        sensitive: o
      }), g = p.regexp, C = p.keys, R = g.exec(e);
      if (!R)
        return null;
      var A = R[0], S = R.slice(1), B = e === A;
      return a && !B ? null : {
        path: h,
        url: h === "/" && A === "" ? "/" : A,
        isExact: B,
        params: C.reduce(function(N, H, L) {
          return N[H.name] = S[L], N;
        }, {})
      };
    }, null);
  };
  function _t(e) {
    return P.Children.count(e) === 0;
  }
  tn = function(e) {
    k(t, e);
    function t() {
      return e.apply(this, arguments) || this;
    }
    var n = t.prototype;
    return n.render = function() {
      var r = this;
      return P.createElement(K.Consumer, null, function(a) {
        a || z(false);
        var c = r.props.location || a.location, s = r.props.computedMatch ? r.props.computedMatch : r.props.path ? ue(c.pathname, r.props) : a.match, f = M({}, a, {
          location: c,
          match: s
        }), o = r.props, u = o.children, l = o.component, h = o.render;
        return Array.isArray(u) && _t(u) && (u = null), P.createElement(K.Provider, {
          value: f
        }, f.match ? u ? typeof u == "function" ? u(f) : u : l ? P.createElement(l, f) : h ? h(f) : null : typeof u == "function" ? u(f) : null);
      });
    }, t;
  }(P.Component);
  function Re(e) {
    return e.charAt(0) === "/" ? e : "/" + e;
  }
  function Wt(e, t) {
    return e ? M({}, t, {
      pathname: Re(e) + t.pathname
    }) : t;
  }
  function jt(e, t) {
    if (!e)
      return t;
    var n = Re(e);
    return t.pathname.indexOf(n) !== 0 ? t : M({}, t, {
      pathname: t.pathname.substr(n.length)
    });
  }
  function We(e) {
    return typeof e == "string" ? e : D(e);
  }
  function ge(e) {
    return function() {
      z(false);
    };
  }
  function je() {
  }
  nn = function(e) {
    k(t, e);
    function t() {
      for (var i, r = arguments.length, a = new Array(r), c = 0; c < r; c++)
        a[c] = arguments[c];
      return i = e.call.apply(e, [
        this
      ].concat(a)) || this, i.handlePush = function(s) {
        return i.navigateTo(s, "PUSH");
      }, i.handleReplace = function(s) {
        return i.navigateTo(s, "REPLACE");
      }, i.handleListen = function() {
        return je;
      }, i.handleBlock = function() {
        return je;
      }, i;
    }
    var n = t.prototype;
    return n.navigateTo = function(r, a) {
      var c = this.props, s = c.basename, f = s === void 0 ? "" : s, o = c.context, u = o === void 0 ? {} : o;
      u.action = a, u.location = Wt(f, I(r)), u.url = We(u.location);
    }, n.render = function() {
      var r = this.props, a = r.basename, c = a === void 0 ? "" : a, s = r.context, f = s === void 0 ? {} : s, o = r.location, u = o === void 0 ? "/" : o, l = re(r, [
        "basename",
        "context",
        "location"
      ]), h = {
        createHref: function(g) {
          return Re(c + We(g));
        },
        action: "POP",
        location: jt(c, I(u)),
        push: this.handlePush,
        replace: this.handleReplace,
        go: ge(),
        goBack: ge(),
        goForward: ge(),
        listen: this.handleListen,
        block: this.handleBlock
      };
      return P.createElement(ce, M({}, l, {
        history: h,
        staticContext: f
      }));
    }, t;
  }(P.Component);
  rn = function(e) {
    k(t, e);
    function t() {
      return e.apply(this, arguments) || this;
    }
    var n = t.prototype;
    return n.render = function() {
      var r = this;
      return P.createElement(K.Consumer, null, function(a) {
        a || z(false);
        var c = r.props.location || a.location, s, f;
        return P.Children.forEach(r.props.children, function(o) {
          if (f == null && P.isValidElement(o)) {
            s = o;
            var u = o.props.path || o.props.from;
            f = u ? ue(c.pathname, M({}, o.props, {
              path: u
            })) : a.match;
          }
        }), f ? P.cloneElement(s, {
          location: c,
          computedMatch: f
        }) : null;
      });
    }, t;
  }(P.Component);
  an = function(e) {
    var t = "withRouter(" + (e.displayName || e.name) + ")", n = function(r) {
      var a = r.wrappedComponentRef, c = re(r, [
        "wrappedComponentRef"
      ]);
      return P.createElement(K.Consumer, null, function(s) {
        return s || z(false), P.createElement(e, M({}, c, s, {
          ref: a
        }));
      });
    };
    return n.displayName = t, n.WrappedComponent = e, nt(n, e);
  };
  var fe = P.useContext;
  on = function() {
    return fe(Ze);
  };
  Ft = function() {
    return fe(K).location;
  };
  sn = function() {
    var e = fe(K).match;
    return e ? e.params : {};
  };
  cn = function(e) {
    var t = Ft(), n = fe(K).match;
    return e ? ue(t.pathname, e) : n;
  };
  const G = await Fe("react");
  let ye, we, Le, Z;
  un = function(e) {
    k(t, e);
    function t() {
      for (var i, r = arguments.length, a = new Array(r), c = 0; c < r; c++)
        a[c] = arguments[c];
      return i = e.call.apply(e, [
        this
      ].concat(a)) || this, i.history = vt(i.props), i;
    }
    var n = t.prototype;
    return n.render = function() {
      return G.createElement(ce, {
        history: this.history,
        children: this.props.children
      });
    }, t;
  }(G.Component);
  fn = function(e) {
    k(t, e);
    function t() {
      for (var i, r = arguments.length, a = new Array(r), c = 0; c < r; c++)
        a[c] = arguments[c];
      return i = e.call.apply(e, [
        this
      ].concat(a)) || this, i.history = mt(i.props), i;
    }
    var n = t.prototype;
    return n.render = function() {
      return G.createElement(ce, {
        history: this.history,
        children: this.props.children
      });
    }, t;
  }(G.Component);
  ye = function(t, n) {
    return typeof t == "function" ? t(n) : t;
  };
  we = function(t, n) {
    return typeof t == "string" ? I(t, null, null, n) : t;
  };
  Le = function(t) {
    return t;
  };
  Z = G.forwardRef;
  typeof Z > "u" && (Z = Le);
  function Kt(e) {
    return !!(e.metaKey || e.altKey || e.ctrlKey || e.shiftKey);
  }
  let qt, tt, se;
  qt = Z(function(e, t) {
    var n = e.innerRef, i = e.navigate, r = e.onClick, a = re(e, [
      "innerRef",
      "navigate",
      "onClick"
    ]), c = a.target, s = M({}, a, {
      onClick: function(o) {
        try {
          r && r(o);
        } catch (u) {
          throw o.preventDefault(), u;
        }
        !o.defaultPrevented && o.button === 0 && (!c || c === "_self") && !Kt(o) && (o.preventDefault(), i());
      }
    });
    return Le !== Z ? s.ref = t || n : s.ref = n, G.createElement("a", s);
  });
  Gt = Z(function(e, t) {
    var n = e.component, i = n === void 0 ? qt : n, r = e.replace, a = e.to, c = e.innerRef, s = re(e, [
      "component",
      "replace",
      "to",
      "innerRef"
    ]);
    return G.createElement(K.Consumer, null, function(f) {
      f || z(false);
      var o = f.history, u = we(ye(a, f.location), f.location), l = u ? o.createHref(u) : "", h = M({}, s, {
        href: l,
        navigate: function() {
          var g = ye(a, f.location), C = D(f.location) === D(we(g)), R = r || C ? o.replace : o.push;
          R(g);
        }
      });
      return Le !== Z ? h.ref = t || c : h.innerRef = c, G.createElement(i, h);
    });
  });
  tt = function(t) {
    return t;
  };
  se = G.forwardRef;
  typeof se > "u" && (se = tt);
  function kt() {
    for (var e = arguments.length, t = new Array(e), n = 0; n < e; n++)
      t[n] = arguments[n];
    return t.filter(function(i) {
      return i;
    }).join(" ");
  }
  ln = se(function(e, t) {
    var n = e["aria-current"], i = n === void 0 ? "page" : n, r = e.activeClassName, a = r === void 0 ? "active" : r, c = e.activeStyle, s = e.className, f = e.exact, o = e.isActive, u = e.location, l = e.sensitive, h = e.strict, p = e.style, g = e.to, C = e.innerRef, R = re(e, [
      "aria-current",
      "activeClassName",
      "activeStyle",
      "className",
      "exact",
      "isActive",
      "location",
      "sensitive",
      "strict",
      "style",
      "to",
      "innerRef"
    ]);
    return G.createElement(K.Consumer, null, function(A) {
      A || z(false);
      var S = u || A.location, B = we(ye(g, S), S), N = B.pathname, H = N && N.replace(/([.+*?=^!:${}()[\]|/\\])/g, "\\$1"), L = H ? ue(S.pathname, {
        path: H,
        exact: f,
        sensitive: l,
        strict: h
      }) : null, y = !!(o ? o(L, S) : L), x = typeof s == "function" ? s(y) : s, O = typeof p == "function" ? p(y) : p;
      y && (x = kt(x, a), O = M({}, O, c));
      var T = M({
        "aria-current": y && i || null,
        className: x,
        style: O,
        to: B
      }, R);
      return tt !== se ? T.ref = t || C : T.innerRef = C, G.createElement(Gt, T);
    });
  });
});
export {
  un as BrowserRouter,
  fn as HashRouter,
  Gt as Link,
  Yt as MemoryRouter,
  ln as NavLink,
  Zt as Prompt,
  en as Redirect,
  tn as Route,
  ce as Router,
  nn as StaticRouter,
  rn as Switch,
  __tla,
  Ne as generatePath,
  ue as matchPath,
  on as useHistory,
  Ft as useLocation,
  sn as useParams,
  cn as useRouteMatch,
  an as withRouter
};
