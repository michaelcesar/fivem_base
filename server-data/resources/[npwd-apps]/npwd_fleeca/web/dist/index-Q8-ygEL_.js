import { importShared as o, __tla as __tla_0 } from "./__federation_fn_import-Bhcw9meP.js";
import { j as t, W as a, c as m, __tla as __tla_1 } from "./App-Ba0j8FiQ.js";
import { r as s } from "./index-DPsCD7-Y.js";
Promise.all([
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
  var e, r = s;
  e = r.createRoot, r.hydrateRoot;
  const { MemoryRouter: i } = await o("react-router-dom"), c = e(document.getElementById("root"));
  c.render(t.jsx(i, {
    children: t.jsx(a, {
      theme: m({
        palette: {
          mode: "dark"
        }
      }),
      i18n: {},
      settings: {}
    })
  }));
});
