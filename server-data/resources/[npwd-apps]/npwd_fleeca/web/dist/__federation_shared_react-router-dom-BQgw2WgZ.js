import { importShared as Me, __tla as __tla_0 } from "./__federation_fn_import-Bhcw9meP.js";
import { _ as J, a as ae } from "./inheritsLoose-G6YR9G09.js";
import { _, h as bt } from "./hoist-non-react-statics.cjs-3wE6KoJ0.js";
import { g as it } from "./_commonjsHelpers-C932wzq6.js";
let Bn, Wn, Cn, Ln, jn, An, On, Mn, Pe, Un, _n, et, Ee, In, xn, Nn, Dn, Hn;
let __tla = Promise.all([
  (() => {
    try {
      return __tla_0;
    } catch {
    }
  })()
]).then(async () => {
  var at = {
    exports: {}
  }, Rt = "SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED", St = Rt, Tt = St;
  function st() {
  }
  function ct() {
  }
  ct.resetWarningCache = st;
  var $t = function() {
    function e(o, r, i, c, s, f) {
      if (f !== Tt) {
        var a = new Error("Calling PropTypes validators directly is not supported by the `prop-types` package. Use PropTypes.checkPropTypes() to call them. Read more at http://fb.me/use-check-prop-types");
        throw a.name = "Invariant Violation", a;
      }
    }
    e.isRequired = e;
    function t() {
      return e;
    }
    var n = {
      array: e,
      bigint: e,
      bool: e,
      func: e,
      number: e,
      object: e,
      string: e,
      symbol: e,
      any: e,
      arrayOf: t,
      element: e,
      elementType: e,
      instanceOf: t,
      node: e,
      objectOf: t,
      oneOf: t,
      oneOfType: t,
      shape: t,
      exact: t,
      checkPropTypes: ct,
      resetWarningCache: st
    };
    return n.PropTypes = n, n;
  };
  at.exports = $t();
  var Lt = at.exports;
  const qe = it(Lt);
  function se(e) {
    return e.charAt(0) === "/";
  }
  function Re(e, t) {
    for (var n = t, o = n + 1, r = e.length; o < r; n += 1, o += 1) e[n] = e[o];
    e.pop();
  }
  function At(e, t) {
    t === void 0 && (t = "");
    var n = e && e.split("/") || [], o = t && t.split("/") || [], r = e && se(e), i = t && se(t), c = r || i;
    if (e && se(e) ? o = n : n.length && (o.pop(), o = o.concat(n)), !o.length) return "/";
    var s;
    if (o.length) {
      var f = o[o.length - 1];
      s = f === "." || f === ".." || f === "";
    } else s = false;
    for (var a = 0, u = o.length; u >= 0; u--) {
      var l = o[u];
      l === "." ? Re(o, u) : l === ".." ? (Re(o, u), a++) : a && (Re(o, u), a--);
    }
    if (!c) for (; a--; a) o.unshift("..");
    c && o[0] !== "" && (!o[0] || !se(o[0])) && o.unshift("");
    var h = o.join("/");
    return s && h.substr(-1) !== "/" && (h += "/"), h;
  }
  function Ke(e) {
    return e.valueOf ? e.valueOf() : Object.prototype.valueOf.call(e);
  }
  function ce(e, t) {
    if (e === t) return true;
    if (e == null || t == null) return false;
    if (Array.isArray(e)) return Array.isArray(t) && e.length === t.length && e.every(function(r, i) {
      return ce(r, t[i]);
    });
    if (typeof e == "object" || typeof t == "object") {
      var n = Ke(e), o = Ke(t);
      return n !== e || o !== t ? ce(n, o) : Object.keys(Object.assign({}, e, t)).every(function(r) {
        return ce(e[r], t[r]);
      });
    }
    return false;
  }
  var Ot = "Invariant failed";
  function X(e, t) {
    throw new Error(Ot);
  }
  function ie(e) {
    return e.charAt(0) === "/" ? e : "/" + e;
  }
  function ke(e) {
    return e.charAt(0) === "/" ? e.substr(1) : e;
  }
  function Mt(e, t) {
    return e.toLowerCase().indexOf(t.toLowerCase()) === 0 && "/?#".indexOf(e.charAt(t.length)) !== -1;
  }
  function ut(e, t) {
    return Mt(e, t) ? e.substr(t.length) : e;
  }
  function ft(e) {
    return e.charAt(e.length - 1) === "/" ? e.slice(0, -1) : e;
  }
  function Ut(e) {
    var t = e || "/", n = "", o = "", r = t.indexOf("#");
    r !== -1 && (o = t.substr(r), t = t.substr(0, r));
    var i = t.indexOf("?");
    return i !== -1 && (n = t.substr(i), t = t.substr(0, i)), {
      pathname: t,
      search: n === "?" ? "" : n,
      hash: o === "#" ? "" : o
    };
  }
  function W(e) {
    var t = e.pathname, n = e.search, o = e.hash, r = t || "/";
    return n && n !== "?" && (r += n.charAt(0) === "?" ? n : "?" + n), o && o !== "#" && (r += o.charAt(0) === "#" ? o : "#" + o), r;
  }
  function N(e, t, n, o) {
    var r;
    typeof e == "string" ? (r = Ut(e), r.state = t) : (r = _({}, e), r.pathname === void 0 && (r.pathname = ""), r.search ? r.search.charAt(0) !== "?" && (r.search = "?" + r.search) : r.search = "", r.hash ? r.hash.charAt(0) !== "#" && (r.hash = "#" + r.hash) : r.hash = "", t !== void 0 && r.state === void 0 && (r.state = t));
    try {
      r.pathname = decodeURI(r.pathname);
    } catch (i) {
      throw i instanceof URIError ? new URIError('Pathname "' + r.pathname + '" could not be decoded. This is likely caused by an invalid percent-encoding.') : i;
    }
    return n && (r.key = n), o ? r.pathname ? r.pathname.charAt(0) !== "/" && (r.pathname = At(r.pathname, o.pathname)) : r.pathname = o.pathname : r.pathname || (r.pathname = "/"), r;
  }
  function _t(e, t) {
    return e.pathname === t.pathname && e.search === t.search && e.hash === t.hash && e.key === t.key && ce(e.state, t.state);
  }
  function Ue() {
    var e = null;
    function t(c) {
      return e = c, function() {
        e === c && (e = null);
      };
    }
    function n(c, s, f, a) {
      if (e != null) {
        var u = typeof e == "function" ? e(c, s) : e;
        typeof u == "string" ? typeof f == "function" ? f(u, a) : a(true) : a(u !== false);
      } else a(true);
    }
    var o = [];
    function r(c) {
      var s = true;
      function f() {
        s && c.apply(void 0, arguments);
      }
      return o.push(f), function() {
        s = false, o = o.filter(function(a) {
          return a !== f;
        });
      };
    }
    function i() {
      for (var c = arguments.length, s = new Array(c), f = 0; f < c; f++) s[f] = arguments[f];
      o.forEach(function(a) {
        return a.apply(void 0, s);
      });
    }
    return {
      setPrompt: t,
      confirmTransitionTo: n,
      appendListener: r,
      notifyListeners: i
    };
  }
  var lt = !!(typeof window < "u" && window.document && window.document.createElement);
  function ht(e, t) {
    t(window.confirm(e));
  }
  function Ht() {
    var e = window.navigator.userAgent;
    return (e.indexOf("Android 2.") !== -1 || e.indexOf("Android 4.0") !== -1) && e.indexOf("Mobile Safari") !== -1 && e.indexOf("Chrome") === -1 && e.indexOf("Windows Phone") === -1 ? false : window.history && "pushState" in window.history;
  }
  function It() {
    return window.navigator.userAgent.indexOf("Trident") === -1;
  }
  function Nt() {
    return window.navigator.userAgent.indexOf("Firefox") === -1;
  }
  function Dt(e) {
    return e.state === void 0 && navigator.userAgent.indexOf("CriOS") === -1;
  }
  var ze = "popstate", Ge = "hashchange";
  function Ve() {
    try {
      return window.history.state || {};
    } catch {
      return {};
    }
  }
  function Bt(e) {
    e === void 0 && (e = {}), lt || X();
    var t = window.history, n = Ht(), o = !It(), r = e, i = r.forceRefresh, c = i === void 0 ? false : i, s = r.getUserConfirmation, f = s === void 0 ? ht : s, a = r.keyLength, u = a === void 0 ? 6 : a, l = e.basename ? ft(ie(e.basename)) : "";
    function h(v) {
      var p = v || {}, w = p.key, m = p.state, C = window.location, U = C.pathname, F = C.search, G = C.hash, k = U + F + G;
      return l && (k = ut(k, l)), N(k, m, w);
    }
    function d() {
      return Math.random().toString(36).substr(2, u);
    }
    var g = Ue();
    function b(v) {
      _(K, v), K.length = t.length, g.notifyListeners(K.location, K.action);
    }
    function S(v) {
      Dt(v) || D(h(v.state));
    }
    function T() {
      D(h(Ve()));
    }
    var M = false;
    function D(v) {
      if (M) M = false, b();
      else {
        var p = "POP";
        g.confirmTransitionTo(v, p, f, function(w) {
          w ? b({
            action: p,
            location: v
          }) : B(v);
        });
      }
    }
    function B(v) {
      var p = K.location, w = R.indexOf(p.key);
      w === -1 && (w = 0);
      var m = R.indexOf(v.key);
      m === -1 && (m = 0);
      var C = w - m;
      C && (M = true, $(C));
    }
    var H = h(Ve()), R = [
      H.key
    ];
    function y(v) {
      return l + W(v);
    }
    function x(v, p) {
      var w = "PUSH", m = N(v, p, d(), K.location);
      g.confirmTransitionTo(m, w, f, function(C) {
        if (C) {
          var U = y(m), F = m.key, G = m.state;
          if (n) if (t.pushState({
            key: F,
            state: G
          }, null, U), c) window.location.href = U;
          else {
            var k = R.indexOf(K.location.key), Z = R.slice(0, k + 1);
            Z.push(m.key), R = Z, b({
              action: w,
              location: m
            });
          }
          else window.location.href = U;
        }
      });
    }
    function O(v, p) {
      var w = "REPLACE", m = N(v, p, d(), K.location);
      g.confirmTransitionTo(m, w, f, function(C) {
        if (C) {
          var U = y(m), F = m.key, G = m.state;
          if (n) if (t.replaceState({
            key: F,
            state: G
          }, null, U), c) window.location.replace(U);
          else {
            var k = R.indexOf(K.location.key);
            k !== -1 && (R[k] = m.key), b({
              action: w,
              location: m
            });
          }
          else window.location.replace(U);
        }
      });
    }
    function $(v) {
      t.go(v);
    }
    function L() {
      $(-1);
    }
    function Y() {
      $(1);
    }
    var Q = 0;
    function j(v) {
      Q += v, Q === 1 && v === 1 ? (window.addEventListener(ze, S), o && window.addEventListener(Ge, T)) : Q === 0 && (window.removeEventListener(ze, S), o && window.removeEventListener(Ge, T));
    }
    var I = false;
    function te(v) {
      v === void 0 && (v = false);
      var p = g.setPrompt(v);
      return I || (j(1), I = true), function() {
        return I && (I = false, j(-1)), p();
      };
    }
    function be(v) {
      var p = g.appendListener(v);
      return j(1), function() {
        j(-1), p();
      };
    }
    var K = {
      length: t.length,
      action: "POP",
      location: H,
      createHref: y,
      push: x,
      replace: O,
      go: $,
      goBack: L,
      goForward: Y,
      block: te,
      listen: be
    };
    return K;
  }
  var Je = "hashchange", Wt = {
    hashbang: {
      encodePath: function(t) {
        return t.charAt(0) === "!" ? t : "!/" + ke(t);
      },
      decodePath: function(t) {
        return t.charAt(0) === "!" ? t.substr(1) : t;
      }
    },
    noslash: {
      encodePath: ke,
      decodePath: ie
    },
    slash: {
      encodePath: ie,
      decodePath: ie
    }
  };
  function pt(e) {
    var t = e.indexOf("#");
    return t === -1 ? e : e.slice(0, t);
  }
  function oe() {
    var e = window.location.href, t = e.indexOf("#");
    return t === -1 ? "" : e.substring(t + 1);
  }
  function jt(e) {
    window.location.hash = e;
  }
  function Se(e) {
    window.location.replace(pt(window.location.href) + "#" + e);
  }
  function Ft(e) {
    e === void 0 && (e = {}), lt || X();
    var t = window.history;
    Nt();
    var n = e, o = n.getUserConfirmation, r = o === void 0 ? ht : o, i = n.hashType, c = i === void 0 ? "slash" : i, s = e.basename ? ft(ie(e.basename)) : "", f = Wt[c], a = f.encodePath, u = f.decodePath;
    function l() {
      var p = u(oe());
      return s && (p = ut(p, s)), N(p);
    }
    var h = Ue();
    function d(p) {
      _(v, p), v.length = t.length, h.notifyListeners(v.location, v.action);
    }
    var g = false, b = null;
    function S(p, w) {
      return p.pathname === w.pathname && p.search === w.search && p.hash === w.hash;
    }
    function T() {
      var p = oe(), w = a(p);
      if (p !== w) Se(w);
      else {
        var m = l(), C = v.location;
        if (!g && S(C, m) || b === W(m)) return;
        b = null, M(m);
      }
    }
    function M(p) {
      if (g) g = false, d();
      else {
        var w = "POP";
        h.confirmTransitionTo(p, w, r, function(m) {
          m ? d({
            action: w,
            location: p
          }) : D(p);
        });
      }
    }
    function D(p) {
      var w = v.location, m = y.lastIndexOf(W(w));
      m === -1 && (m = 0);
      var C = y.lastIndexOf(W(p));
      C === -1 && (C = 0);
      var U = m - C;
      U && (g = true, L(U));
    }
    var B = oe(), H = a(B);
    B !== H && Se(H);
    var R = l(), y = [
      W(R)
    ];
    function x(p) {
      var w = document.querySelector("base"), m = "";
      return w && w.getAttribute("href") && (m = pt(window.location.href)), m + "#" + a(s + W(p));
    }
    function O(p, w) {
      var m = "PUSH", C = N(p, void 0, void 0, v.location);
      h.confirmTransitionTo(C, m, r, function(U) {
        if (U) {
          var F = W(C), G = a(s + F), k = oe() !== G;
          if (k) {
            b = F, jt(G);
            var Z = y.lastIndexOf(W(v.location)), Fe = y.slice(0, Z + 1);
            Fe.push(F), y = Fe, d({
              action: m,
              location: C
            });
          } else d();
        }
      });
    }
    function $(p, w) {
      var m = "REPLACE", C = N(p, void 0, void 0, v.location);
      h.confirmTransitionTo(C, m, r, function(U) {
        if (U) {
          var F = W(C), G = a(s + F), k = oe() !== G;
          k && (b = F, Se(G));
          var Z = y.indexOf(W(v.location));
          Z !== -1 && (y[Z] = F), d({
            action: m,
            location: C
          });
        }
      });
    }
    function L(p) {
      t.go(p);
    }
    function Y() {
      L(-1);
    }
    function Q() {
      L(1);
    }
    var j = 0;
    function I(p) {
      j += p, j === 1 && p === 1 ? window.addEventListener(Je, T) : j === 0 && window.removeEventListener(Je, T);
    }
    var te = false;
    function be(p) {
      p === void 0 && (p = false);
      var w = h.setPrompt(p);
      return te || (I(1), te = true), function() {
        return te && (te = false, I(-1)), w();
      };
    }
    function K(p) {
      var w = h.appendListener(p);
      return I(1), function() {
        I(-1), w();
      };
    }
    var v = {
      length: t.length,
      action: "POP",
      location: R,
      createHref: x,
      push: O,
      replace: $,
      go: L,
      goBack: Y,
      goForward: Q,
      block: be,
      listen: K
    };
    return v;
  }
  function Xe(e, t, n) {
    return Math.min(Math.max(e, t), n);
  }
  function qt(e) {
    e === void 0 && (e = {});
    var t = e, n = t.getUserConfirmation, o = t.initialEntries, r = o === void 0 ? [
      "/"
    ] : o, i = t.initialIndex, c = i === void 0 ? 0 : i, s = t.keyLength, f = s === void 0 ? 6 : s, a = Ue();
    function u(x) {
      _(y, x), y.length = y.entries.length, a.notifyListeners(y.location, y.action);
    }
    function l() {
      return Math.random().toString(36).substr(2, f);
    }
    var h = Xe(c, 0, r.length - 1), d = r.map(function(x) {
      return typeof x == "string" ? N(x, void 0, l()) : N(x, void 0, x.key || l());
    }), g = W;
    function b(x, O) {
      var $ = "PUSH", L = N(x, O, l(), y.location);
      a.confirmTransitionTo(L, $, n, function(Y) {
        if (Y) {
          var Q = y.index, j = Q + 1, I = y.entries.slice(0);
          I.length > j ? I.splice(j, I.length - j, L) : I.push(L), u({
            action: $,
            location: L,
            index: j,
            entries: I
          });
        }
      });
    }
    function S(x, O) {
      var $ = "REPLACE", L = N(x, O, l(), y.location);
      a.confirmTransitionTo(L, $, n, function(Y) {
        Y && (y.entries[y.index] = L, u({
          action: $,
          location: L
        }));
      });
    }
    function T(x) {
      var O = Xe(y.index + x, 0, y.entries.length - 1), $ = "POP", L = y.entries[O];
      a.confirmTransitionTo(L, $, n, function(Y) {
        Y ? u({
          action: $,
          location: L,
          index: O
        }) : u();
      });
    }
    function M() {
      T(-1);
    }
    function D() {
      T(1);
    }
    function B(x) {
      var O = y.index + x;
      return O >= 0 && O < y.entries.length;
    }
    function H(x) {
      return x === void 0 && (x = false), a.setPrompt(x);
    }
    function R(x) {
      return a.appendListener(x);
    }
    var y = {
      length: d.length,
      action: "POP",
      location: d[h],
      index: h,
      entries: d,
      createHref: g,
      push: b,
      replace: S,
      go: T,
      goBack: M,
      goForward: D,
      canGo: B,
      block: H,
      listen: R
    };
    return y;
  }
  const vt = await Me("react"), { Component: Ye } = vt;
  var Te = 1073741823, Qe = typeof globalThis < "u" ? globalThis : typeof window < "u" ? window : typeof global < "u" ? global : {};
  function Kt() {
    var e = "__global_unique_id__";
    return Qe[e] = (Qe[e] || 0) + 1;
  }
  function kt(e, t) {
    return e === t ? e !== 0 || 1 / e === 1 / t : e !== e && t !== t;
  }
  function zt(e) {
    var t = [];
    return {
      on: function(o) {
        t.push(o);
      },
      off: function(o) {
        t = t.filter(function(r) {
          return r !== o;
        });
      },
      get: function() {
        return e;
      },
      set: function(o, r) {
        e = o, t.forEach(function(i) {
          return i(e, r);
        });
      }
    };
  }
  function Gt(e) {
    return Array.isArray(e) ? e[0] : e;
  }
  function Vt(e, t) {
    var n, o, r = "__create-react-context-" + Kt() + "__", i = function(s) {
      J(f, s);
      function f() {
        var u;
        return u = s.apply(this, arguments) || this, u.emitter = zt(u.props.value), u;
      }
      var a = f.prototype;
      return a.getChildContext = function() {
        var l;
        return l = {}, l[r] = this.emitter, l;
      }, a.componentWillReceiveProps = function(l) {
        if (this.props.value !== l.value) {
          var h = this.props.value, d = l.value, g;
          kt(h, d) ? g = 0 : (g = typeof t == "function" ? t(h, d) : Te, g |= 0, g !== 0 && this.emitter.set(l.value, g));
        }
      }, a.render = function() {
        return this.props.children;
      }, f;
    }(Ye);
    i.childContextTypes = (n = {}, n[r] = qe.object.isRequired, n);
    var c = function(s) {
      J(f, s);
      function f() {
        var u;
        return u = s.apply(this, arguments) || this, u.state = {
          value: u.getValue()
        }, u.onUpdate = function(l, h) {
          var d = u.observedBits | 0;
          d & h && u.setState({
            value: u.getValue()
          });
        }, u;
      }
      var a = f.prototype;
      return a.componentWillReceiveProps = function(l) {
        var h = l.observedBits;
        this.observedBits = h ?? Te;
      }, a.componentDidMount = function() {
        this.context[r] && this.context[r].on(this.onUpdate);
        var l = this.props.observedBits;
        this.observedBits = l ?? Te;
      }, a.componentWillUnmount = function() {
        this.context[r] && this.context[r].off(this.onUpdate);
      }, a.getValue = function() {
        return this.context[r] ? this.context[r].get() : e;
      }, a.render = function() {
        return Gt(this.props.children)(this.state.value);
      }, f;
    }(Ye);
    return c.contextTypes = (o = {}, o[r] = qe.object, o), {
      Provider: i,
      Consumer: c
    };
  }
  var Jt = vt.createContext || Vt, re = {
    exports: {}
  }, Xt = Array.isArray || function(e) {
    return Object.prototype.toString.call(e) == "[object Array]";
  }, ue = Xt;
  re.exports = yt;
  re.exports.parse = _e;
  re.exports.compile = Zt;
  re.exports.tokensToFunction = dt;
  re.exports.tokensToRegExp = mt;
  var Yt = new RegExp([
    "(\\\\.)",
    "([\\/.])?(?:(?:\\:(\\w+)(?:\\(((?:\\\\.|[^\\\\()])+)\\))?|\\(((?:\\\\.|[^\\\\()])+)\\))([+*?])?|(\\*))"
  ].join("|"), "g");
  function _e(e, t) {
    for (var n = [], o = 0, r = 0, i = "", c = t && t.delimiter || "/", s; (s = Yt.exec(e)) != null; ) {
      var f = s[0], a = s[1], u = s.index;
      if (i += e.slice(r, u), r = u + f.length, a) {
        i += a[1];
        continue;
      }
      var l = e[r], h = s[2], d = s[3], g = s[4], b = s[5], S = s[6], T = s[7];
      i && (n.push(i), i = "");
      var M = h != null && l != null && l !== h, D = S === "+" || S === "*", B = S === "?" || S === "*", H = h || c, R = g || b, y = h || (typeof n[n.length - 1] == "string" ? n[n.length - 1] : "");
      n.push({
        name: d || o++,
        prefix: h || "",
        delimiter: H,
        optional: B,
        repeat: D,
        partial: M,
        asterisk: !!T,
        pattern: R ? nn(R) : T ? ".*" : Qt(H, y)
      });
    }
    return r < e.length && (i += e.substr(r)), i && n.push(i), n;
  }
  function Qt(e, t) {
    return !t || t.indexOf(e) > -1 ? "[^" + ee(e) + "]+?" : ee(t) + "|(?:(?!" + ee(t) + ")[^" + ee(e) + "])+?";
  }
  function Zt(e, t) {
    return dt(_e(e, t), t);
  }
  function en(e) {
    return encodeURI(e).replace(/[\/?#]/g, function(t) {
      return "%" + t.charCodeAt(0).toString(16).toUpperCase();
    });
  }
  function tn(e) {
    return encodeURI(e).replace(/[?#]/g, function(t) {
      return "%" + t.charCodeAt(0).toString(16).toUpperCase();
    });
  }
  function dt(e, t) {
    for (var n = new Array(e.length), o = 0; o < e.length; o++) typeof e[o] == "object" && (n[o] = new RegExp("^(?:" + e[o].pattern + ")$", Ie(t)));
    return function(r, i) {
      for (var c = "", s = r || {}, f = i || {}, a = f.pretty ? en : encodeURIComponent, u = 0; u < e.length; u++) {
        var l = e[u];
        if (typeof l == "string") {
          c += l;
          continue;
        }
        var h = s[l.name], d;
        if (h == null) if (l.optional) {
          l.partial && (c += l.prefix);
          continue;
        } else throw new TypeError('Expected "' + l.name + '" to be defined');
        if (ue(h)) {
          if (!l.repeat) throw new TypeError('Expected "' + l.name + '" to not repeat, but received `' + JSON.stringify(h) + "`");
          if (h.length === 0) {
            if (l.optional) continue;
            throw new TypeError('Expected "' + l.name + '" to not be empty');
          }
          for (var g = 0; g < h.length; g++) {
            if (d = a(h[g]), !n[u].test(d)) throw new TypeError('Expected all "' + l.name + '" to match "' + l.pattern + '", but received `' + JSON.stringify(d) + "`");
            c += (g === 0 ? l.prefix : l.delimiter) + d;
          }
          continue;
        }
        if (d = l.asterisk ? tn(h) : a(h), !n[u].test(d)) throw new TypeError('Expected "' + l.name + '" to match "' + l.pattern + '", but received "' + d + '"');
        c += l.prefix + d;
      }
      return c;
    };
  }
  function ee(e) {
    return e.replace(/([.+*?=^!:${}()[\]|\/\\])/g, "\\$1");
  }
  function nn(e) {
    return e.replace(/([=!:$\/()])/g, "\\$1");
  }
  function He(e, t) {
    return e.keys = t, e;
  }
  function Ie(e) {
    return e && e.sensitive ? "" : "i";
  }
  function rn(e, t) {
    var n = e.source.match(/\((?!\?)/g);
    if (n) for (var o = 0; o < n.length; o++) t.push({
      name: o,
      prefix: null,
      delimiter: null,
      optional: false,
      repeat: false,
      partial: false,
      asterisk: false,
      pattern: null
    });
    return He(e, t);
  }
  function on(e, t, n) {
    for (var o = [], r = 0; r < e.length; r++) o.push(yt(e[r], t, n).source);
    var i = new RegExp("(?:" + o.join("|") + ")", Ie(n));
    return He(i, t);
  }
  function an(e, t, n) {
    return mt(_e(e, n), t, n);
  }
  function mt(e, t, n) {
    ue(t) || (n = t || n, t = []), n = n || {};
    for (var o = n.strict, r = n.end !== false, i = "", c = 0; c < e.length; c++) {
      var s = e[c];
      if (typeof s == "string") i += ee(s);
      else {
        var f = ee(s.prefix), a = "(?:" + s.pattern + ")";
        t.push(s), s.repeat && (a += "(?:" + f + a + ")*"), s.optional ? s.partial ? a = f + "(" + a + ")?" : a = "(?:" + f + "(" + a + "))?" : a = f + "(" + a + ")", i += a;
      }
    }
    var u = ee(n.delimiter || "/"), l = i.slice(-u.length) === u;
    return o || (i = (l ? i.slice(0, -u.length) : i) + "(?:" + u + "(?=$))?"), r ? i += "$" : i += o && l ? "" : "(?=" + u + "|$)", He(new RegExp("^" + i, Ie(n)), t);
  }
  function yt(e, t, n) {
    return ue(t) || (n = t || n, t = []), n = n || {}, e instanceof RegExp ? rn(e, t) : ue(e) ? on(e, t, n) : an(e, t, n);
  }
  var sn = re.exports;
  const gt = it(sn);
  var P = {};
  var A = typeof Symbol == "function" && Symbol.for, Ne = A ? Symbol.for("react.element") : 60103, De = A ? Symbol.for("react.portal") : 60106, le = A ? Symbol.for("react.fragment") : 60107, he = A ? Symbol.for("react.strict_mode") : 60108, pe = A ? Symbol.for("react.profiler") : 60114, ve = A ? Symbol.for("react.provider") : 60109, de = A ? Symbol.for("react.context") : 60110, Be = A ? Symbol.for("react.async_mode") : 60111, me = A ? Symbol.for("react.concurrent_mode") : 60111, ye = A ? Symbol.for("react.forward_ref") : 60112, ge = A ? Symbol.for("react.suspense") : 60113, cn = A ? Symbol.for("react.suspense_list") : 60120, we = A ? Symbol.for("react.memo") : 60115, xe = A ? Symbol.for("react.lazy") : 60116, un = A ? Symbol.for("react.block") : 60121, fn = A ? Symbol.for("react.fundamental") : 60117, ln = A ? Symbol.for("react.responder") : 60118, hn = A ? Symbol.for("react.scope") : 60119;
  function q(e) {
    if (typeof e == "object" && e !== null) {
      var t = e.$$typeof;
      switch (t) {
        case Ne:
          switch (e = e.type, e) {
            case Be:
            case me:
            case le:
            case pe:
            case he:
            case ge:
              return e;
            default:
              switch (e = e && e.$$typeof, e) {
                case de:
                case ye:
                case xe:
                case we:
                case ve:
                  return e;
                default:
                  return t;
              }
          }
        case De:
          return t;
      }
    }
  }
  function wt(e) {
    return q(e) === me;
  }
  P.AsyncMode = Be;
  P.ConcurrentMode = me;
  P.ContextConsumer = de;
  P.ContextProvider = ve;
  P.Element = Ne;
  P.ForwardRef = ye;
  P.Fragment = le;
  P.Lazy = xe;
  P.Memo = we;
  P.Portal = De;
  P.Profiler = pe;
  P.StrictMode = he;
  P.Suspense = ge;
  P.isAsyncMode = function(e) {
    return wt(e) || q(e) === Be;
  };
  P.isConcurrentMode = wt;
  P.isContextConsumer = function(e) {
    return q(e) === de;
  };
  P.isContextProvider = function(e) {
    return q(e) === ve;
  };
  P.isElement = function(e) {
    return typeof e == "object" && e !== null && e.$$typeof === Ne;
  };
  P.isForwardRef = function(e) {
    return q(e) === ye;
  };
  P.isFragment = function(e) {
    return q(e) === le;
  };
  P.isLazy = function(e) {
    return q(e) === xe;
  };
  P.isMemo = function(e) {
    return q(e) === we;
  };
  P.isPortal = function(e) {
    return q(e) === De;
  };
  P.isProfiler = function(e) {
    return q(e) === pe;
  };
  P.isStrictMode = function(e) {
    return q(e) === he;
  };
  P.isSuspense = function(e) {
    return q(e) === ge;
  };
  P.isValidElementType = function(e) {
    return typeof e == "string" || typeof e == "function" || e === le || e === me || e === pe || e === he || e === ge || e === cn || typeof e == "object" && e !== null && (e.$$typeof === xe || e.$$typeof === we || e.$$typeof === ve || e.$$typeof === de || e.$$typeof === ye || e.$$typeof === fn || e.$$typeof === ln || e.$$typeof === hn || e.$$typeof === un);
  };
  P.typeOf = q;
  const E = await Me("react");
  let xt, Pt, z, Et;
  xt = function(t) {
    var n = Jt();
    return n.displayName = t, n;
  };
  Pt = xt("Router-History");
  z = xt("Router");
  Pe = function(e) {
    J(t, e), t.computeRootMatch = function(r) {
      return {
        path: "/",
        url: "/",
        params: {},
        isExact: r === "/"
      };
    };
    function t(o) {
      var r;
      return r = e.call(this, o) || this, r.state = {
        location: o.history.location
      }, r._isMounted = false, r._pendingLocation = null, o.staticContext || (r.unlisten = o.history.listen(function(i) {
        r._isMounted ? r.setState({
          location: i
        }) : r._pendingLocation = i;
      })), r;
    }
    var n = t.prototype;
    return n.componentDidMount = function() {
      this._isMounted = true, this._pendingLocation && this.setState({
        location: this._pendingLocation
      });
    }, n.componentWillUnmount = function() {
      this.unlisten && (this.unlisten(), this._isMounted = false, this._pendingLocation = null);
    }, n.render = function() {
      return E.createElement(z.Provider, {
        value: {
          history: this.props.history,
          location: this.state.location,
          match: t.computeRootMatch(this.state.location.pathname),
          staticContext: this.props.staticContext
        }
      }, E.createElement(Pt.Provider, {
        children: this.props.children || null,
        value: this.props.history
      }));
    }, t;
  }(E.Component);
  Ln = function(e) {
    J(t, e);
    function t() {
      for (var o, r = arguments.length, i = new Array(r), c = 0; c < r; c++) i[c] = arguments[c];
      return o = e.call.apply(e, [
        this
      ].concat(i)) || this, o.history = qt(o.props), o;
    }
    var n = t.prototype;
    return n.render = function() {
      return E.createElement(Pe, {
        history: this.history,
        children: this.props.children
      });
    }, t;
  }(E.Component);
  Et = function(e) {
    J(t, e);
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
  }(E.Component);
  An = function(e) {
    var t = e.message, n = e.when, o = n === void 0 ? true : n;
    return E.createElement(z.Consumer, null, function(r) {
      if (r || X(), !o || r.staticContext) return null;
      var i = r.history.block;
      return E.createElement(Et, {
        onMount: function(s) {
          s.release = i(t);
        },
        onUpdate: function(s, f) {
          f.message !== t && (s.release(), s.release = i(t));
        },
        onUnmount: function(s) {
          s.release();
        },
        message: t
      });
    });
  };
  var $e = {}, pn = 1e4, Ze = 0;
  function vn(e) {
    if ($e[e]) return $e[e];
    var t = gt.compile(e);
    return Ze < pn && ($e[e] = t, Ze++), t;
  }
  et = function(e, t) {
    return e === void 0 && (e = "/"), t === void 0 && (t = {}), e === "/" ? e : vn(e)(t, {
      pretty: true
    });
  };
  On = function(e) {
    var t = e.computedMatch, n = e.to, o = e.push, r = o === void 0 ? false : o;
    return E.createElement(z.Consumer, null, function(i) {
      i || X();
      var c = i.history, s = i.staticContext, f = r ? c.push : c.replace, a = N(t ? typeof n == "string" ? et(n, t.params) : _({}, n, {
        pathname: et(n.pathname, t.params)
      }) : n);
      return s ? (f(a), null) : E.createElement(Et, {
        onMount: function() {
          f(a);
        },
        onUpdate: function(l, h) {
          var d = N(h.to);
          _t(d, _({}, a, {
            key: d.key
          })) || f(a);
        },
        to: n
      });
    });
  };
  var tt = {}, dn = 1e4, nt = 0;
  function mn(e, t) {
    var n = "" + t.end + t.strict + t.sensitive, o = tt[n] || (tt[n] = {});
    if (o[e]) return o[e];
    var r = [], i = gt(e, r, t), c = {
      regexp: i,
      keys: r
    };
    return nt < dn && (o[e] = c, nt++), c;
  }
  Ee = function(e, t) {
    t === void 0 && (t = {}), (typeof t == "string" || Array.isArray(t)) && (t = {
      path: t
    });
    var n = t, o = n.path, r = n.exact, i = r === void 0 ? false : r, c = n.strict, s = c === void 0 ? false : c, f = n.sensitive, a = f === void 0 ? false : f, u = [].concat(o);
    return u.reduce(function(l, h) {
      if (!h && h !== "") return null;
      if (l) return l;
      var d = mn(h, {
        end: i,
        strict: s,
        sensitive: a
      }), g = d.regexp, b = d.keys, S = g.exec(e);
      if (!S) return null;
      var T = S[0], M = S.slice(1), D = e === T;
      return i && !D ? null : {
        path: h,
        url: h === "/" && T === "" ? "/" : T,
        isExact: D,
        params: b.reduce(function(B, H, R) {
          return B[H.name] = M[R], B;
        }, {})
      };
    }, null);
  };
  function yn(e) {
    return E.Children.count(e) === 0;
  }
  Mn = function(e) {
    J(t, e);
    function t() {
      return e.apply(this, arguments) || this;
    }
    var n = t.prototype;
    return n.render = function() {
      var r = this;
      return E.createElement(z.Consumer, null, function(i) {
        i || X();
        var c = r.props.location || i.location, s = r.props.computedMatch ? r.props.computedMatch : r.props.path ? Ee(c.pathname, r.props) : i.match, f = _({}, i, {
          location: c,
          match: s
        }), a = r.props, u = a.children, l = a.component, h = a.render;
        return Array.isArray(u) && yn(u) && (u = null), E.createElement(z.Provider, {
          value: f
        }, f.match ? u ? typeof u == "function" ? u(f) : u : l ? E.createElement(l, f) : h ? h(f) : null : typeof u == "function" ? u(f) : null);
      });
    }, t;
  }(E.Component);
  function We(e) {
    return e.charAt(0) === "/" ? e : "/" + e;
  }
  function gn(e, t) {
    return e ? _({}, t, {
      pathname: We(e) + t.pathname
    }) : t;
  }
  function wn(e, t) {
    if (!e) return t;
    var n = We(e);
    return t.pathname.indexOf(n) !== 0 ? t : _({}, t, {
      pathname: t.pathname.substr(n.length)
    });
  }
  function rt(e) {
    return typeof e == "string" ? e : W(e);
  }
  function Le(e) {
    return function() {
      X();
    };
  }
  function ot() {
  }
  Un = function(e) {
    J(t, e);
    function t() {
      for (var o, r = arguments.length, i = new Array(r), c = 0; c < r; c++) i[c] = arguments[c];
      return o = e.call.apply(e, [
        this
      ].concat(i)) || this, o.handlePush = function(s) {
        return o.navigateTo(s, "PUSH");
      }, o.handleReplace = function(s) {
        return o.navigateTo(s, "REPLACE");
      }, o.handleListen = function() {
        return ot;
      }, o.handleBlock = function() {
        return ot;
      }, o;
    }
    var n = t.prototype;
    return n.navigateTo = function(r, i) {
      var c = this.props, s = c.basename, f = s === void 0 ? "" : s, a = c.context, u = a === void 0 ? {} : a;
      u.action = i, u.location = gn(f, N(r)), u.url = rt(u.location);
    }, n.render = function() {
      var r = this.props, i = r.basename, c = i === void 0 ? "" : i, s = r.context, f = s === void 0 ? {} : s, a = r.location, u = a === void 0 ? "/" : a, l = ae(r, [
        "basename",
        "context",
        "location"
      ]), h = {
        createHref: function(g) {
          return We(c + rt(g));
        },
        action: "POP",
        location: wn(c, N(u)),
        push: this.handlePush,
        replace: this.handleReplace,
        go: Le(),
        goBack: Le(),
        goForward: Le(),
        listen: this.handleListen,
        block: this.handleBlock
      };
      return E.createElement(Pe, _({}, l, {
        history: h,
        staticContext: f
      }));
    }, t;
  }(E.Component);
  _n = function(e) {
    J(t, e);
    function t() {
      return e.apply(this, arguments) || this;
    }
    var n = t.prototype;
    return n.render = function() {
      var r = this;
      return E.createElement(z.Consumer, null, function(i) {
        i || X();
        var c = r.props.location || i.location, s, f;
        return E.Children.forEach(r.props.children, function(a) {
          if (f == null && E.isValidElement(a)) {
            s = a;
            var u = a.props.path || a.props.from;
            f = u ? Ee(c.pathname, _({}, a.props, {
              path: u
            })) : i.match;
          }
        }), f ? E.cloneElement(s, {
          location: c,
          computedMatch: f
        }) : null;
      });
    }, t;
  }(E.Component);
  Hn = function(e) {
    var t = "withRouter(" + (e.displayName || e.name) + ")", n = function(r) {
      var i = r.wrappedComponentRef, c = ae(r, [
        "wrappedComponentRef"
      ]);
      return E.createElement(z.Consumer, null, function(s) {
        return s || X(), E.createElement(e, _({}, c, s, {
          ref: i
        }));
      });
    };
    return n.displayName = t, n.WrappedComponent = e, bt(n, e);
  };
  var Ce = E.useContext;
  In = function() {
    return Ce(Pt);
  };
  xn = function() {
    return Ce(z).location;
  };
  Nn = function() {
    var e = Ce(z).match;
    return e ? e.params : {};
  };
  Dn = function(e) {
    var t = xn(), n = Ce(z).match;
    return e ? Ee(t.pathname, e) : n;
  };
  const V = await Me("react");
  let Ae, Oe, je, ne;
  Bn = function(e) {
    J(t, e);
    function t() {
      for (var o, r = arguments.length, i = new Array(r), c = 0; c < r; c++) i[c] = arguments[c];
      return o = e.call.apply(e, [
        this
      ].concat(i)) || this, o.history = Bt(o.props), o;
    }
    var n = t.prototype;
    return n.render = function() {
      return V.createElement(Pe, {
        history: this.history,
        children: this.props.children
      });
    }, t;
  }(V.Component);
  Wn = function(e) {
    J(t, e);
    function t() {
      for (var o, r = arguments.length, i = new Array(r), c = 0; c < r; c++) i[c] = arguments[c];
      return o = e.call.apply(e, [
        this
      ].concat(i)) || this, o.history = Ft(o.props), o;
    }
    var n = t.prototype;
    return n.render = function() {
      return V.createElement(Pe, {
        history: this.history,
        children: this.props.children
      });
    }, t;
  }(V.Component);
  Ae = function(t, n) {
    return typeof t == "function" ? t(n) : t;
  };
  Oe = function(t, n) {
    return typeof t == "string" ? N(t, null, null, n) : t;
  };
  je = function(t) {
    return t;
  };
  ne = V.forwardRef;
  typeof ne > "u" && (ne = je);
  function Pn(e) {
    return !!(e.metaKey || e.altKey || e.ctrlKey || e.shiftKey);
  }
  let En, Ct, fe;
  En = ne(function(e, t) {
    var n = e.innerRef, o = e.navigate, r = e.onClick, i = ae(e, [
      "innerRef",
      "navigate",
      "onClick"
    ]), c = i.target, s = _({}, i, {
      onClick: function(a) {
        try {
          r && r(a);
        } catch (u) {
          throw a.preventDefault(), u;
        }
        !a.defaultPrevented && a.button === 0 && (!c || c === "_self") && !Pn(a) && (a.preventDefault(), o());
      }
    });
    return je !== ne ? s.ref = t || n : s.ref = n, V.createElement("a", s);
  });
  Cn = ne(function(e, t) {
    var n = e.component, o = n === void 0 ? En : n, r = e.replace, i = e.to, c = e.innerRef, s = ae(e, [
      "component",
      "replace",
      "to",
      "innerRef"
    ]);
    return V.createElement(z.Consumer, null, function(f) {
      f || X();
      var a = f.history, u = Oe(Ae(i, f.location), f.location), l = u ? a.createHref(u) : "", h = _({}, s, {
        href: l,
        navigate: function() {
          var g = Ae(i, f.location), b = W(f.location) === W(Oe(g)), S = r || b ? a.replace : a.push;
          S(g);
        }
      });
      return je !== ne ? h.ref = t || c : h.innerRef = c, V.createElement(o, h);
    });
  });
  Ct = function(t) {
    return t;
  };
  fe = V.forwardRef;
  typeof fe > "u" && (fe = Ct);
  function bn() {
    for (var e = arguments.length, t = new Array(e), n = 0; n < e; n++) t[n] = arguments[n];
    return t.filter(function(o) {
      return o;
    }).join(" ");
  }
  jn = fe(function(e, t) {
    var n = e["aria-current"], o = n === void 0 ? "page" : n, r = e.activeClassName, i = r === void 0 ? "active" : r, c = e.activeStyle, s = e.className, f = e.exact, a = e.isActive, u = e.location, l = e.sensitive, h = e.strict, d = e.style, g = e.to, b = e.innerRef, S = ae(e, [
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
    return V.createElement(z.Consumer, null, function(T) {
      T || X();
      var M = u || T.location, D = Oe(Ae(g, M), M), B = D.pathname, H = B && B.replace(/([.+*?=^!:${}()[\]|/\\])/g, "\\$1"), R = H ? Ee(M.pathname, {
        path: H,
        exact: f,
        sensitive: l,
        strict: h
      }) : null, y = !!(a ? a(R, M) : R), x = typeof s == "function" ? s(y) : s, O = typeof d == "function" ? d(y) : d;
      y && (x = bn(x, i), O = _({}, O, c));
      var $ = _({
        "aria-current": y && o || null,
        className: x,
        style: O,
        to: D
      }, S);
      return Ct !== fe ? $.ref = t || b : $.innerRef = b, V.createElement(Cn, $);
    });
  });
});
export {
  Bn as BrowserRouter,
  Wn as HashRouter,
  Cn as Link,
  Ln as MemoryRouter,
  jn as NavLink,
  An as Prompt,
  On as Redirect,
  Mn as Route,
  Pe as Router,
  Un as StaticRouter,
  _n as Switch,
  __tla,
  et as generatePath,
  Ee as matchPath,
  In as useHistory,
  xn as useLocation,
  Nn as useParams,
  Dn as useRouteMatch,
  Hn as withRouter
};
