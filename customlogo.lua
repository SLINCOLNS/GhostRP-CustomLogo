require 'lib.moonloader'
local dlstatus = require 'moonloader'.download_status
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

script_author("t.me/some_lincoln") -- Äëÿ ñâÿçè


local resFolder = getWorkingDirectory() .. '\\resource\\'
if not doesDirectoryExist(resFolder) then createDirectory(resFolder) end

-------------- [ cfg ] ---------------
local inicfg = require 'inicfg'
local configIni = "clogo.ini"
local ini = inicfg.load({
    settings = {
        logo_texture = nil, -- äåñêğèïòîğ òåêñòóğû
        current_logo = 1,
        show_logo = true
    },
    position = {
        x = 1650,
        y = 70,
        width = 200,
        height = 50
    }
}, configIni)
inicfg.save(ini, configIni)
--------------------------------------

local logo_paths = {
    [1] = resFolder .. '1.png',
    [2] = resFolder .. '2.png',
    [3] = resFolder .. '3.png'
}

local logo_urls = {
    [1] = 'https://raw.githubusercontent.com/SLINCOLNS/GhostRP-CustomLogo/main/images/1.png',
    [2] = 'https://raw.githubusercontent.com/SLINCOLNS/GhostRP-CustomLogo/main/images/2.png',
    [3] = 'https://raw.githubusercontent.com/SLINCOLNS/GhostRP-CustomLogo/main/images/3.png'
}

local main_color = 0xFFf2ed8e

-- Ïàğàìåòğû ïî óìîë÷àíèş äëÿ ëîãîòèïîâ
local logo_settings = {
    [1] = {x = 1650, y = 70, width = 200, height = 50},
    [2] = {x = 1600, y = 15, width = 240, height = 150},
    [3] = {x = 1670, y = 35, width = 150, height = 100}
}


function main()
    while not isSampAvailable() do wait(3000) end
    if logo_texture then
        renderReleaseTexture(logo_texture)
        logo_texture = nil
    end
    sampRegisterChatCommand("clogo", cmd_clogo)

    print("GitHub - https://github.com/SLINCOLNS/GhostRP-CustomLogo")
    print("Âñå èçîáğàæåíèÿ ìîãóò îáíîâëÿòüñÿ íà ãèòõàáå, òàê æå ıòî òåñòîâàÿ âåğñèÿ ñêğèïòà.")

    -- Èíèöèàëèçàöèÿ òåêóùåãî ëîãîòèïà èç êîíôèãóğàöèè
    current_logo = ini.settings.current_logo
    show_logo = ini.settings.show_logo

    loadOrDownloadLogo(current_logo)

    while true do
        wait(0)
        if show_logo and logo_texture then
            local s = logo_settings[current_logo]
            renderDrawTexture(logo_texture, s.x, s.y, s.width, s.height, 0.0, 0xFFFFFFFF)
        end
    end
end

function cmd_clogo(arg)
    if not arg or arg == '' or arg == 'help' then
        sampAddChatMessage("[CustomLogo] Èñïîëüçîâàíèå:", main_color)
        sampAddChatMessage(" /clogo [1-3] — âûáğàòü ëîãîòèï", main_color)
        sampAddChatMessage(" /clogo off — âûêëş÷èòü ëîãîòèï", main_color)
        sampAddChatMessage(" /clogo pos x y width height — óñòàíîâèòü ïîçèöèş è ğàçìåğ òåêóùåãî ëîãîòèïà", main_color)
        sampAddChatMessage("Ïğèìåğ: /clogo pos 1700 35 150 45", main_color)
        return
    end

    local args = {}
    for word in string.gmatch(arg, "%S+") do
        table.insert(args, word)
    end

    if args[1] == 'off' then
        show_logo = false
        ini.settings.show_logo = false
        sampAddChatMessage("[CustomLogo] Ëîãîòèï âûêëş÷åí.", main_color)
        inicfg.save(ini, configIni) 
        return
    elseif args[1] == 'pos' then
        if #args ~= 5 then
            sampAddChatMessage("[CustomLogo] Îøèáêà. Èñïîëüçîâàíèå: /clogo pos x y width height", main_color)
            return
        end

        local x = tonumber(args[2])
        local y = tonumber(args[3])
        local width = tonumber(args[4])
        local height = tonumber(args[5])

        if not x or not y or not width or not height then
            sampAddChatMessage("[CustomLogo] Âñå ïàğàìåòğû äîëæíû áûòü ÷èñëàìè.", main_color)
            return
        end

        -- Òóò íè÷åãî íå ìåíÿòü, êîíôèã ñëîìàåòñÿ
        logo_settings[current_logo].x = x
        logo_settings[current_logo].y = y
        logo_settings[current_logo].width = width
        logo_settings[current_logo].height = height
        ini.position.x = x
        ini.position.y = y
        ini.position.width = width
        ini.position.height = height
        inicfg.save(ini, configIni)

        sampAddChatMessage(string.format("[CustomLogo] Ïîçèöèÿ è ğàçìåğ ëîãîòèïà #%d óñòàíîâëåíû: x=%d y=%d w=%d h=%d", current_logo, x, y, width, height), main_color)
        return
    end

    local num = tonumber(args[1])
    if num and num >= 1 and num <= 3 then
        current_logo = num
        show_logo = true
        ini.settings.current_logo = num
        ini.settings.show_logo = true
        loadOrDownloadLogo(current_logo)
        inicfg.save(ini, configIni) 
        sampAddChatMessage(string.format("[CustomLogo] Âûáğàí ëîãîòèï #%d.", num), main_color)
    else
        sampAddChatMessage("[CustomLogo] Íåâåğíûé àğãóìåíò. Èñïîëüçóéòå 1-3, off èëè pos.", main_color)
    end
end

function loadTexture(path)
    if not doesFileExist(path) then
        sampAddChatMessage("[CustomLogo] Ôàéë íå íàéäåí: " .. path, main_color)
        return false
    end

    local tex = renderLoadTextureFromFile(path)
    if not tex then
        sampAddChatMessage("[CustomLogo] Îøèáêà çàãğóçêè òåêñòóğû èç ôàéëà: " .. path, main_color)
        return false
    end

    logo_texture = tex 
    return true
end

function loadOrDownloadLogo(index)
    if logo_texture then
        renderReleaseTexture(logo_texture)
        logo_texture = nil
    end

    local path = logo_paths[index]
    local url = logo_urls[index]

    if doesFileExist(path) then
        loadTexture(path)
    else
        sampAddChatMessage(string.format("[CustomLogo] Çàãğóæàş ëîãîòèï #%d...", index), main_color)
        downloadUrlToFile(url, path, function(_, status, _, _)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                print("[CustomLogo] Ëîãîòèï óñïåøíî çàãğóæåí.")
                if doesFileExist(path) then
                    loadTexture(path)
                else
                    print("[CustomLogo] Ôàéë íå íàéäåí ïîñëå çàãğóçêè!")
                end
            elseif status == dlstatus.STATUS_DOWNLOADFAILED then
                print("[CustomLogo] Îøèáêà çàãğóçêè ëîãîòèïà, âîçìîæíî ïëîõîå ñîåäèíåíèå èëè ğåïîçèòîğèé íå íàéäåí!.")
            end
        end)
    end
end




-- function apply_custom_style()
--     imgui.SwitchContext()
--     local style = imgui.GetStyle()
--     local colors = style.Colors
--     local clr = imgui.Col
--     local ImVec4 = imgui.ImVec4
 
--     style.WindowPadding = imgui.ImVec2(15, 15)
--     style.WindowRounding = 1.5
--     style.FramePadding = imgui.ImVec2(5, 5)
--     style.FrameRounding = 4.0
--     style.ItemSpacing = imgui.ImVec2(6, 4)
--     style.ItemInnerSpacing = imgui.ImVec2(8, 6)
--     style.IndentSpacing = 20.0
--     style.ScrollbarSize = 12.0
--     style.ScrollbarRounding = 9.0
--     style.GrabMinSize = 5.0
--     style.GrabRounding = 3.0                                                         ÄËß iMGUI, ÒÓÒ ÅÃÎ ÍÅÒÓ, ÍÎ ÏÓÑÊÀÉ ÏÎÊÀ ÁÓÄÅÒ

--     colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
--     colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
--     colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
--     colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
--     colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
--     colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
--     colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
--     colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
--     colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
--     colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
--     colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
--     colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
--     colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
--     colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
--     colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
--     colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
--     colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
--     colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
--     colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
--     colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
--     colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
--     colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
--     colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
--     colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
--     colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
--     colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
--     colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
--     colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
--     colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
--     colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
--     colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
--     colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
--     colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
--     colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
--     colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
--     colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
--     colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
--     colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
--     colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
--     colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
-- end
-- apply_custom_style()