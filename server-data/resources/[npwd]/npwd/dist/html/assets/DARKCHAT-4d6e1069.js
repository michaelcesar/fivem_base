import { j as r } from "./jsx-runtime-dc228b70.js";
import { i as a, __tla as __tla_0 } from "./__federation_expose_Input-3de07060.js";
import { r as o, __tla as __tla_1 } from "./index-0f6a7e6a.js";
let m;
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
  var e = {}, u = a;
  Object.defineProperty(e, "__esModule", {
    value: true
  });
  var t = e.default = void 0, i = u(o()), l = r;
  t = e.default = (0, i.default)((0, l.jsx)("path", {
    d: "M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1m-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1"
  }), "Forum");
  m = () => r.jsx(t, {
    fontSize: "small"
  });
});
export {
  __tla,
  m as default
};
