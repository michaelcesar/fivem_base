'use strict';
// Live RP: minimal glue over fengari (a real Lua VM, not a reimplementation in JS) so a test can
// run an actual extracted Lua snippet and read back a single return value. Deliberately small -
// this project needs "run this pure function with these args, check the result," not a general
// Lua/JS bridge.
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = require('fengari');

function newState() {
    const L = lauxlib.luaL_newstate();
    lualib.luaL_openlibs(L);
    return L;
}

/**
 * Runs `source` (arbitrary Lua chunk text) and returns whatever it `return`s, converted to a JS
 * value. Only handles the value shapes this project's pure functions actually return - booleans,
 * numbers, strings, nil/undefined, and plain tables (recursively, arrays or maps by convention).
 */
function runLua(source) {
    const L = newState();

    if (lauxlib.luaL_dostring(L, to_luastring(source)) !== lua.LUA_OK) {
        const err = to_jsstring(lua.lua_tostring(L, -1));
        throw new Error(`Lua error: ${err}\n--- source ---\n${source}`);
    }

    return readReturn(L);
}

function readReturn(L) {
    if (lua.lua_gettop(L) === 0) return undefined;
    return luaToJs(L, -1);
}

function luaToJs(L, index) {
    const type = lua.lua_type(L, index);

    switch (type) {
        case lua.LUA_TNIL:
            return undefined;
        case lua.LUA_TBOOLEAN:
            return lua.lua_toboolean(L, index);
        case lua.LUA_TNUMBER:
            return lua.lua_tonumber(L, index);
        case lua.LUA_TSTRING:
            return to_jsstring(lua.lua_tostring(L, index));
        case lua.LUA_TTABLE:
            return luaTableToJs(L, index);
        default:
            throw new Error(`readReturn: unsupported Lua type ${lua.lua_typename(L, type)}`);
    }
}

function luaTableToJs(L, index) {
    const abs = index < 0 ? lua.lua_gettop(L) + index + 1 : index;
    const out = {};
    let isArray = true;
    let n = 0;

    lua.lua_pushnil(L);
    while (lua.lua_next(L, abs) !== 0) {
        const key = lua.lua_type(L, -2) === lua.LUA_TNUMBER
            ? lua.lua_tonumber(L, -2)
            : to_jsstring(lua.lua_tostring(L, -2));
        const value = luaToJs(L, -1);
        out[key] = value;
        if (typeof key !== 'number') isArray = false;
        n += 1;
        lua.lua_pop(L, 1);
    }

    if (isArray) {
        const arr = [];
        for (let i = 1; i <= n; i++) arr.push(out[i]);
        return arr;
    }

    return out;
}

module.exports = { runLua };
