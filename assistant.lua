script_name('AST')
script_description("Assistant")
script_version('1.00')
script_author('Oscar Jimenez')

-- Используемые библиотеки
require 'lib.moonloader'
local inicfg = require 'inicfg'
local mem = require 'memory'
local keys = require 'vkeys'

local mainColor = 0xFFD700

-- Главный конфиг
local directIni = 'moonloader\\AST config\\settings.ini'
local mainIni = inicfg.load(nil, directIni)

mainIni = {
    config = {
        post = 'Стажер'
    }
}

-- Диалог главного меню
local dMainMenuArr = {'{FFD700}[1] {FFFFFF}Команды', '{FFD700}[2] {FFFFFF}Настройки', '{FFD700}[3] {FFFFFF}Информация о ' ..thisScript().name}
local dMainMenuStr = ''
for _, str in ipairs(dMainMenuArr) do
    dMainMenuStr = dMainMenuStr ..str.. '\n'
end

-- Диалог настроек
local dSettingsArr = {'{FFD700}[1] {FFFFFF}Установить должность'}
local dSettingsStr = ''
for _, str in ipairs(dSettingsArr) do
    dSettingsStr = dSettingsStr ..str.. '\n'
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

        -- Вывод сообщения при загрузке скрипта
        sampAddChatMessage(thisScript().name.. ' {FFFFFF}• Assistant v' ..thisScript().version.. ' {32CD32}успешно {FFFFFF}загружен!', mainColor)
        sampAddChatMessage(thisScript().name.. ' {FFFFFF}• Используйте: {FFD700}/ast', mainColor)
        
        -- Получение ID и собственного Nickname
        _, pId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        pNick = string.gsub(sampGetPlayerNickname(pId), '_', ' ')

        -- Список команд
        sampRegisterChatCommand('ast', cmdMainMenu)
        sampRegisterChatCommand('tpi', cmdTakePlayerInfo)
        sampRegisterChatCommand('clearchat', cmdClearChat)
        sampRegisterChatCommand('testcmd', cmdTestCmd)

    while true do

        -- Главное меню
        local result, button, list, input = sampHasDialogRespond(0)
        if result then
            if button == 1 then
                if list == 0 then
                    sampShowDialog(1, '{FFD700}'..thisScript().name.. ' {FFFFFF}• Список команд', '{FFD700}/ast {FFFFFF}- меню скрипта\n{FFD700}/tpi {FFFFFF}- получить информаию об игроке\n{FFD700}/clearchat {FFFFFF}- очистить чат\n{FFD700}CTRL + 5 {FFFFFF}- переподключиться к серверу', 'Назад', 'Закрыть', 0)
                elseif list == 1 then
                    sampShowDialog(2, '{FFD700}'..thisScript().name.. ' {FFFFFF}• Настройки', dSettingsStr, 'Выбрать', 'Закрыть', 2)
                elseif list == 2 then
                    sampShowDialog(3, '{FFD700}'..thisScript().name.. ' {FFFFFF}• Информация', '{FFFFFF}Автор скрипта: \t{FFD700}Oscar_Jimenez{FFFFFF}\nСервер: \t\t{FFD700}Trilliant\n{FFFFFF}Версия скрипта: \t{FFD700}' ..thisScript().version, 'Выбрать', 'Закрыть', 0)
                end
            end
        end

        -- Диалог ввода должности
        local result, button, list, input = sampHasDialogRespond(2)
        if result then
            if button == 1 then
                if list == 0 then
                    mainIni = inicfg.load(nil, directIni)
                    sampShowDialog(4, '{FFD700}'..thisScript().name.. ' {FFFFFF}• Ввод должности', '{FFFFFF}Сейчас установлено: {FFD700}' ..mainIni.config.post.. '\n{FFFFFF}Введите Вашу должность', 'Ввод', 'Закрыть', 1)
                    post = mainIni.config.post
                end
            end
        end

        -- Установка должности
        local result, button, list, input = sampHasDialogRespond(4)
        if result then
            if button == 1 then
                mainIni.config.post = input
                if inicfg.save(mainIni, directIni) then
                    sampAddChatMessage(thisScript().name.. ' {FFFFFF}• Должность {32CD32}успешно {FFFFFF}установлена', mainColor)
                    sampAddChatMessage(thisScript().name.. ' {FFFFFF}• Новая должность: {FFD700}' ..mainIni.config.post, mainColor)
                end
            end
        end

        -- Реконект
        if chatstring == 'Server closed the connection.' or chatstring == 'You are banned from this server.' then
            sampDisconnectWithReason(false)
                wait(150000)
            sampSetGamestate(1)
        elseif isKeyDown(0x11) and isKeyDown(0x35) then
            sampSetGamestate(1)
        end

        wait(0)
    end
end

function cmdMainMenu()
    sampShowDialog(0, '{FFD700}'..thisScript().name..' {FFFFFF}• Главное меню', dMainMenuStr, 'Выбрать', 'Закрыть', 2)
end

function cmdTakePlayerInfo(id)
    if id == '' then
        sampAddChatMessage(thisScript().name.. ' {FFFFFF}• Используйте: {FFD700}/tpi [ID]', mainColor)
    else
        local result = sampIsPlayerConnected(id)
        local score = sampGetPlayerScore(id)
        local ping = sampGetPlayerPing(id)
        if not result and id == pId then
            sampAddChatMessage(thisScript().name.. ' {FFFFFF}• Игрока нет на сервере!', mainColor)
        else
            local nick = sampGetPlayerNickname(id)
            sampAddChatMessage(thisScript().name.. ' {FFFFFF}• Ник: {FFD700}' ..nick.. ' [' ..id.. '] {FFFFFF} Уровень: {FFD700}' ..score .. ' {FFFFFF}Пинг: {FFD700}' ..ping, mainColor)
        end
    end
end

function cmdClearChat()
    mem.fill(sampGetChatInfoPtr() + 306, 0x0, 25200, false)
	setStructElement(sampGetChatInfoPtr() + 306, 25562, 4, true, false)
	mem.write(sampGetChatInfoPtr() + 0x63DA, 1, 1, false)
end

function cmdTestCmd()
    printStyledString('~w~Exam is finished', 20, 2)
end