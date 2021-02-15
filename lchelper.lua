script_name('LCH')
script_author('Oscar Jimenez')
script_version('0.01')

-- Используемые библиотеки
require 'lib.moonloader'
local dlstatus = require('moonloader').download_status
local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local inicfg = require 'inicfg'
local encoding = require 'encoding'

-- Автообновление
local script_vers = 1
local script_vers_text = '0.01'

local script_path = thisScript().script_path
local script_url = 'https://raw.githubusercontent.com/Bennioff/scripts/main/lchelper.lua'

local update_path = getWorkingDirectory() .. '/LCH config/update.ini'
local update_url = 'https://raw.githubusercontent.com/Bennioff/scripts/main/update.ini'

-- Кодировка
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local mainColor = 0xFFD700

-- Главная функция
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    -- Определение ID и Nickname игрока
    _, pId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    pNick = sampGetPlayerNickname(pId):gsub('_', ' ')
    wait(2000)
    sampAddChatMessage(thisScript().name.. ' {FFFFFF}• LC Helper v' ..thisScript().version.. ' {32CD32}успешно {FFFFFF}загружен!', mainColor)

    downloadUrlToFile(update_url, update_path, function(pId, stats)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage('Update ready!', -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)

    while true do

        if update_state then
            downloadUrlToFile(script_url, script_path, function(pId, stats)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage('Script successfuly updated!', -1)
                    thisScript():reload()
                end
            end)
            break
        end

        wait(0)
    end
end