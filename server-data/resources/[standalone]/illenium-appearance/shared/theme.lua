Config.Theme = {
    currentTheme = "lite",
    themes = {
        -- Servidor: this project's own look, mapped onto the fields this resource exposes.
        -- Colours come from ox_lib's `gfx` palette (dev/ox_lib-src/web/src/theme/index.ts) so the
        -- clothing UI matches every other panel on the server rather than shipping a stock theme.
        --
        -- Field meanings were read off the stock "default" theme rather than guessed: it pairs
        -- primaryBackground "0,0,0" with primaryBackgroundSelected "255,255,255" and
        -- fontColor white with fontColorSelected black - so primaryBackground is a normal row,
        -- primaryBackgroundSelected is the highlighted one, and secondaryBackground is the panel
        -- behind them.
        --
        -- `fontFamily` only works because web/dist/index.html now declares an @font-face for it;
        -- an undeclared name silently falls back, which is exactly what "qb-core" (the theme this
        -- replaces) was doing with Poppins. See ADR-077.
        {
            id = "lite",
            borderRadius = "3px",                        -- gfx cards use 3px, not the stock 3vh pill
            fontColor = "163, 163, 163",                 -- gfx.textMid, idle rows
            fontColorHover = "242, 242, 242",            -- gfx.textHi
            fontColorSelected = "15, 15, 15",            -- gfx.panel, dark text on the white accent
            fontFamily = "Inter",
            primaryBackground = "20, 20, 20",            -- gfx.bg2, one step above the panel
            primaryBackgroundSelected = "255, 255, 255", -- gfx.blueBright, the active accent
            secondaryBackground = "15, 15, 15",          -- gfx.panel
            scaleOnHover = false,                        -- nothing else in this project scales on hover
            sectionFontWeight = "bold",
            smoothBackgroundTransition = true
        },
        {
            id = "default",
            borderRadius = "4px",
            fontColor = "255, 255, 255",
            fontColorHover = "255, 255, 255",
            fontColorSelected = "0, 0, 0",
            fontFamily = "Inter",
            primaryBackground = "0, 0, 0",
            primaryBackgroundSelected = "255, 255, 255",
            secondaryBackground = "0, 0, 0",
            scaleOnHover = false,
            sectionFontWeight = "normal",
            smoothBackgroundTransition = false
        },
        {
            id = "qb-core",
            borderRadius = "3vh",
            fontColor = "255, 255, 255",
            fontColorHover = "255, 255, 255",
            fontColorSelected = "255, 255, 255",
            fontFamily = "Poppins",
            primaryBackground = "220, 20, 60",
            primaryBackgroundSelected = "220, 20, 60",
            secondaryBackground = "23, 23, 23",
            scaleOnHover = true,
            sectionFontWeight = "bold",
            smoothBackgroundTransition = true
        },
        {
            id = "project-sloth",
            borderRadius = "6vh",
            fontColor = "255, 255, 255",
            fontColorHover = "255, 255, 255",
            fontColorSelected = "255, 255, 255",
            fontFamily = "Inter",
            primaryBackground = "2, 241, 181",
            primaryBackgroundSelected = "2, 241, 181",
            secondaryBackground = "27, 24, 69",
            scaleOnHover = true,
            sectionFontWeight = "bold",
            smoothBackgroundTransition = false
        },
        {
            id = "not-heavily-inspired",
            borderRadius = "10vh",
            fontColor = "255, 255, 255",
            fontColorHover = "255, 255, 255",
            fontColorSelected = "255, 255, 255",
            fontFamily = "Inter",
            primaryBackground = "149, 239, 119",
            primaryBackgroundSelected = "242, 163, 101",
            secondaryBackground = "25, 46, 70",
            scaleOnHover = true,
            sectionFontWeight = "bold",
            smoothBackgroundTransition = false
        }
    }
}
