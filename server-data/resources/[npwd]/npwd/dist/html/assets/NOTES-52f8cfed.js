import { j as s } from "./jsx-runtime-dc228b70.js";
import { S as t, __tla as __tla_0 } from "./__federation_expose_Input-3de07060.js";
let r;
let __tla = Promise.all([
  (() => {
    try {
      return __tla_0;
    } catch {
    }
  })()
]).then(async () => {
  let e;
  e = (o) => s.jsx(t, {
    ...o,
    children: s.jsxs("svg", {
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24",
      children: [
        s.jsx("rect", {
          fill: "none"
        }),
        s.jsx("path", {
          d: "M19,3H4.99C3.89,3,3,3.9,3,5l0.01,14c0,1.1,0.89,2,1.99,2h10l6-6V5C21,3.9,20.1,3,19,3z M7,8h10v2H7V8z M12,14H7v-2h5V14z M14,19.5V14h5.5L14,19.5z"
        })
      ]
    })
  });
  r = () => s.jsx(e, {
    fontSize: "small"
  });
});
export {
  __tla,
  r as default
};
