--[[
    ⚙️ AUTO SERVEHOP + CUSTOM SCRIPT EXECUTOR (v3 SUPER MELHORADA)
    
    ✨ Features:
    • Auto-load do script em cada servidor
    • Reexecuta automaticamente a cada hop
    • Servehop a cada 5 segundos
    • Sistema de reload 100% funcional
    
    📝 Criador: apexscripters
    🔗 Repositório: github.com/apexscripters/lua-auto-servehop-executor
]]

-- ============================================
-- ⚙️ CONFIGURAÇÕES
-- ============================================

local CONFIG = {
    MIN_PLAYERS = 5,
    MAX_PLAYERS = 25,
    DELAY_HOP = 5,           -- ⭐ 5 SEGUNDOS ENTRE HOPS
    DELAY_RETRY = 5,
    SCRIPT_RELOAD_DELAY = 3, -- Tempo para script recarregar
    DEBUG = true
}

-- 🔗 SEU SCRIPT AQUI (JÁ CONFIGURADO)
local CUSTOM_SCRIPT = "https://raw.githubusercontent.com/apexscripters/ApexFunctionS/refs/heads/main/Multi-FunCtionS"

-- ============================================
-- SERVICES
-- ============================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================

local localPlayer = Players.LocalPlayer
local placeId = game.PlaceId
local lastJobId = game.JobId
local isHopping = false
local successfulHops = 0
local scriptExecuted = false

-- ============================================
-- FUNÇÕES DE LOG
-- ============================================

local function log(message, level)
    if not CONFIG.DEBUG then return end
    
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local prefix = ""
    
    if level == "INFO" then prefix = "ℹ️" end
    if level == "SUCCESS" then prefix = "✅" end
    if level == "WARNING" then prefix = "⚠️" end
    if level == "ERROR" then prefix = "❌" end
    if level == "HOP" then prefix = "🔄" end
    if level == "CUSTOM" then prefix = "🎮" end
    if level == "RELOAD" then prefix = "🔁" end
    
    print("[" .. timestamp .. "] " .. prefix .. " " .. message)
end

-- ============================================
-- FUNÇÃO EXECUTAR SCRIPT COM CACHE
-- ============================================

local function executeCustomScript(isReload)
    isReload = isReload or false
    
    if not CUSTOM_SCRIPT or CUSTOM_SCRIPT == "" then
        log("Nenhum script configurado", "WARNING")
        return false
    end
    
    if isReload then
        log("🔁 REEXECUTANDO seu script no novo servidor...", "RELOAD")
    else
        log("📥 Carregando ApexFunctionS pela primeira vez...", "CUSTOM")
    end
    
    log("URL: " .. CUSTOM_SCRIPT, "INFO")
    
    local success, result = pcall(function()
        -- Sempre recarregar do link (não usar cache)
        if string.find(CUSTOM_SCRIPT, "http://") or string.find(CUSTOM_SCRIPT, "https://") then
            log("Carregando script do link...", "CUSTOM")
            local response = game:HttpGet(CUSTOM_SCRIPT)
            
            if not response or response == "" then
                log("❌ Resposta vazia do servidor!", "ERROR")
                return false
            end
            
            local chunk = loadstring(response)
            if not chunk then
                log("❌ Erro ao compilar script!", "ERROR")
                return false
            end
            
            chunk()
        else
            -- Se for código direto
            log("Carregando script do código...", "CUSTOM")
            local chunk = loadstring(CUSTOM_SCRIPT)
            chunk()
        end
    end)
    
    if success then
        if isReload then
            log("✅ Script REEXECUTADO com sucesso no novo servidor!", "SUCCESS")
        else
            log("✅ Script carregado com sucesso!", "SUCCESS")
        end
        scriptExecuted = true
        return true
    else
        log("❌ Erro ao executar script: " .. tostring(result), "ERROR")
        return false
    end
end

-- ============================================
-- FUNÇÕES DE SERVEHOP
-- ============================================

local function makeRequest(url, retries)
    retries = retries or 3
    
    for attempt = 1, retries do
        local success, result = pcall(function()
            return HttpService:GetAsync(url, false)
        end)
        
        if success then
            return result
        else
            wait(0.5)
        end
    end
    
    return nil
end

local function decodeJSON(jsonString)
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    
    if success then
        return result
    else
        return nil
    end
end

local function getAvailableServers()
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local response = makeRequest(url)
    
    if not response then
        log("Erro ao buscar servidores", "ERROR")
        return nil
    end
    
    local data = decodeJSON(response)
    
    if not data or not data.data then
        log("Resposta da API inválida", "ERROR")
        return nil
    end
    
    return data.data
end

local function findBestServer(servers)
    if not servers or #servers == 0 then
        return nil
    end
    
    local validServers = {}
    for _, server in pairs(servers) do
        if server.id and server.id ~= lastJobId then
            local playerCount = server.playerCount or 0
            
            if playerCount >= CONFIG.MIN_PLAYERS and playerCount <= CONFIG.MAX_PLAYERS then
                table.insert(validServers, {
                    id = server.id,
                    playerCount = playerCount
                })
            end
        end
    end
    
    table.sort(validServers, function(a, b)
        return a.playerCount < b.playerCount
    end)
    
    if #validServers > 0 then
        return validServers[1]
    end
    
    return nil
end

local function executeServerHop(server)
    if isHopping then
        return false
    end
    
    isHopping = true
    
    log("🔄 Conectando ao servidor: " .. server.id .. " (" .. server.playerCount .. " jogadores)", "HOP")
    log("⏳ Seu script será reexecutado em " .. CONFIG.SCRIPT_RELOAD_DELAY .. "s", "INFO")
    
    local success = false
    local result = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, server.id, localPlayer)
        success = true
    end)
    
    if success and result then
        successfulHops = successfulHops + 1
        log("✅ Hop iniciado! (Total: " .. successfulHops .. ")", "SUCCESS")
    else
        log("❌ Erro ao fazer hop", "ERROR")
        isHopping = false
    end
    
    return success
end

-- ============================================
-- MONITOR DE DETECÇÃO DE SERVIDOR (MELHORADO)
-- ============================================

local function setupServerChangeDetector()
    local lastDetectedJobId = lastJobId
    
    -- Usar RunService para detecção mais rápida
    RunService.Heartbeat:Connect(function()
        if game.JobId ~= lastDetectedJobId then
            log("🌍 SERVIDOR MUDOU! JobId antigo: " .. lastDetectedJobId, "RELOAD")
            log("🌍 JobId novo: " .. game.JobId, "RELOAD")
            
            lastDetectedJobId = game.JobId
            lastJobId = game.JobId
            isHopping = false
            scriptExecuted = false
            
            wait(CONFIG.SCRIPT_RELOAD_DELAY)
            
            -- Reexecutar o script no novo servidor
            executeCustomScript(true)
        end
    end)
end

-- ============================================
-- THREAD PARA SERVEHOP
-- ============================================

local function startServerHopThread()
    task.spawn(function()
        wait(2) -- Esperar um pouco
        
        log("========================================", "SUCCESS")
        log("SERVEHOP INICIADO (A CADA 5 SEGUNDOS)", "HOP")
        log("========================================", "SUCCESS")
        log("Jogo: " .. placeId, "INFO")
        log("Jogador: " .. localPlayer.Name, "INFO")
        log("Min Jogadores: " .. CONFIG.MIN_PLAYERS, "INFO")
        log("Max Jogadores: " .. CONFIG.MAX_PLAYERS, "INFO")
        log("Delay entre hops: " .. CONFIG.DELAY_HOP .. "s", "INFO")
        
        while true do
            if not isHopping then
                local servers = getAvailableServers()
                
                if servers then
                    local bestServer = findBestServer(servers)
                    
                    if bestServer then
                        executeServerHop(bestServer)
                        wait(CONFIG.DELAY_HOP)
                    else
                        wait(CONFIG.DELAY_RETRY)
                    end
                else
                    wait(CONFIG.DELAY_RETRY)
                end
            else
                wait(1)
            end
        end
    end)
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================

log("", "INFO")
log("╔════════════════════════════════════════╗", "SUCCESS")
log("║   APEX SERVEHOP v3 - AUTO RELOAD       ║", "SUCCESS")
log("║   by: apexscripters                    ║", "SUCCESS")
log("║   Delay: 5 segundos                    ║", "SUCCESS")
log("╚════════════════════════════════════════╝", "SUCCESS")
log("", "INFO")

-- Executar script customizado PRIMEIRA VEZ
log("🚀 INICIALIZANDO SISTEMA...", "SUCCESS")
executeCustomScript(false)

wait(1)

-- Configurar detector de mudança de servidor
log("👁️ Ativando monitor de servidor...", "INFO")
setupServerChangeDetector()

wait(1)

-- Iniciar servehop
log("🔄 Iniciando SERVEHOP (a cada 5 segundos)...", "HOP")
startServerHopThread()

log("", "INFO")
log("✅ TUDO ATIVADO COM SUCESSO!", "SUCCESS")
log("📌 ApexFunctionS vai reexecutar a cada mudança!", "CUSTOM")
log("⏱️  Servehop a cada 5 segundos", "HOP")
log("", "INFO")
