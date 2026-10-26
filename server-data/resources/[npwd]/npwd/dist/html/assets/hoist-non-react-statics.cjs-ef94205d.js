import { g as D } from "./_commonjsHelpers-de833af9.js";
function j() {
  return j = Object.assign ? Object.assign.bind() : function(r) {
    for (var o = 1; o < arguments.length; o++) {
      var c = arguments[o];
      for (var f in c)
        ({}).hasOwnProperty.call(c, f) && (r[f] = c[f]);
    }
    return r;
  }, j.apply(null, arguments);
}
var E = { exports: {} }, e = {};
/** @license React v16.13.1
* react-is.production.min.js
*
* Copyright (c) Facebook, Inc. and its affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/
var t = typeof Symbol == "function" && Symbol.for, g = t ? Symbol.for("react.element") : 60103, P = t ? Symbol.for("react.portal") : 60106, a = t ? Symbol.for("react.fragment") : 60107, i = t ? Symbol.for("react.strict_mode") : 60108, p = t ? Symbol.for("react.profiler") : 60114, y = t ? Symbol.for("react.provider") : 60109, l = t ? Symbol.for("react.context") : 60110, O = t ? Symbol.for("react.async_mode") : 60111, m = t ? Symbol.for("react.concurrent_mode") : 60111, S = t ? Symbol.for("react.forward_ref") : 60112, b = t ? Symbol.for("react.suspense") : 60113, C = t ? Symbol.for("react.suspense_list") : 60120, d = t ? Symbol.for("react.memo") : 60115, v = t ? Symbol.for("react.lazy") : 60116, z = t ? Symbol.for("react.block") : 60121, L = t ? Symbol.for("react.fundamental") : 60117, W = t ? Symbol.for("react.responder") : 60118, q = t ? Symbol.for("react.scope") : 60119;
function n(r) {
  if (typeof r == "object" && r !== null) {
    var o = r.$$typeof;
    switch (o) {
      case g:
        switch (r = r.type, r) {
          case O:
          case m:
          case a:
          case p:
          case i:
          case b:
            return r;
          default:
            switch (r = r && r.$$typeof, r) {
              case l:
              case S:
              case v:
              case d:
              case y:
                return r;
              default:
                return o;
            }
        }
      case P:
        return o;
    }
  }
}
function F(r) {
  return n(r) === m;
}
e.AsyncMode = O;
e.ConcurrentMode = m;
e.ContextConsumer = l;
e.ContextProvider = y;
e.Element = g;
e.ForwardRef = S;
e.Fragment = a;
e.Lazy = v;
e.Memo = d;
e.Portal = P;
e.Profiler = p;
e.StrictMode = i;
e.Suspense = b;
e.isAsyncMode = function(r) {
  return F(r) || n(r) === O;
};
e.isConcurrentMode = F;
e.isContextConsumer = function(r) {
  return n(r) === l;
};
e.isContextProvider = function(r) {
  return n(r) === y;
};
e.isElement = function(r) {
  return typeof r == "object" && r !== null && r.$$typeof === g;
};
e.isForwardRef = function(r) {
  return n(r) === S;
};
e.isFragment = function(r) {
  return n(r) === a;
};
e.isLazy = function(r) {
  return n(r) === v;
};
e.isMemo = function(r) {
  return n(r) === d;
};
e.isPortal = function(r) {
  return n(r) === P;
};
e.isProfiler = function(r) {
  return n(r) === p;
};
e.isStrictMode = function(r) {
  return n(r) === i;
};
e.isSuspense = function(r) {
  return n(r) === b;
};
e.isValidElementType = function(r) {
  return typeof r == "string" || typeof r == "function" || r === a || r === m || r === p || r === i || r === b || r === C || typeof r == "object" && r !== null && (r.$$typeof === v || r.$$typeof === d || r.$$typeof === y || r.$$typeof === l || r.$$typeof === S || r.$$typeof === L || r.$$typeof === W || r.$$typeof === q || r.$$typeof === z);
};
e.typeOf = n;
E.exports = e;
var K = E.exports, T = K, V = { childContextTypes: true, contextType: true, contextTypes: true, defaultProps: true, displayName: true, getDefaultProps: true, getDerivedStateFromError: true, getDerivedStateFromProps: true, mixins: true, propTypes: true, type: true }, Y = { name: true, length: true, prototype: true, caller: true, callee: true, arguments: true, arity: true }, B = { $$typeof: true, render: true, defaultProps: true, displayName: true, propTypes: true }, I = { $$typeof: true, compare: true, defaultProps: true, displayName: true, propTypes: true, type: true }, x = {};
x[T.ForwardRef] = B;
x[T.Memo] = I;
function h(r) {
  return T.isMemo(r) ? I : x[r.$$typeof] || V;
}
var G = Object.defineProperty, H = Object.getOwnPropertyNames, M = Object.getOwnPropertySymbols, J = Object.getOwnPropertyDescriptor, Q = Object.getPrototypeOf, A = Object.prototype;
function N(r, o, c) {
  if (typeof o != "string") {
    if (A) {
      var f = Q(o);
      f && f !== A && N(r, f, c);
    }
    var s = H(o);
    M && (s = s.concat(M(o)));
    for (var _ = h(r), w = h(o), $ = 0; $ < s.length; ++$) {
      var u = s[$];
      if (!Y[u] && !(c && c[u]) && !(w && w[u]) && !(_ && _[u])) {
        var R = J(o, u);
        try {
          G(r, u, R);
        } catch {
        }
      }
    }
  }
  return r;
}
var U = N;
const k = D(U);
export {
  j as _,
  k as h
};
