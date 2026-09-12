--[[
    ⚙️ AUTO SERVEHOP + CUSTOM SCRIPT EXECUTOR (v2 MELHORADA)
    
    ✨ Features:
    • Execute seu script + servehop simultaneamente
    • Script REEXECUTA em cada novo servidor
    • Sem conflitos
    • Anti-lag
    
    📝 Criador: apexscripters
    🔗 Repositório: github.com/apexscripters/lua-auto-servehop-executor
]]

-- ============================================
-- ⚙️ CONFIGURAÇÕES
-- ============================================

local CONFIG = {
    MIN_PLAYERS = 5,
    MAX_PLAYERS = 25,
    DELAY_HOP = 2,
    DELAY_RETRY = 5,
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

-- ============================================
-- VARIÁVEIS
-- ============================================

local localPlayer = Players.LocalPlayer
local placeId = game.PlaceId
local currentJobId = game.JobId
local isHopping = false
local successfulHops = 0

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
    
    print("[" .. timestamp .. "] " .. prefix .. " " .. message)
end

-- ============================================
-- FUNÇÃO EXECUTAR SCRIPT CUSTOMIZADO
-- ============================================

local function executeCustomScript()
    if not CUSTOM_SCRIPT or CUSTOM_SCRIPT == "" then
        log("Nenhum script configurado", "WARNING")
        return false
    end
    
    log("Executando seu script customizado...", "CUSTOM")
    log("URL: " .. CUSTOM_SCRIPT, "INFO")
    
    local success, result = pcall(function()
        -- Se for um link (URL)
        if string.find(CUSTOM_SCRIPT, "http://") or string.find(CUSTOM_SCRIPT, "https://") then
            log("Carregando script do link...", "CUSTOM")
            local response = game:HttpGet(CUSTOM_SCRIPT)
            local chunk = loadstring(response)
            chunk()
        else
            -- Se for código direto
            log("Carregando script do código...", "CUSTOM")
            local chunk = loadstring(CUSTOM_SCRIPT)
            chunk()
        end
    end)
    
    if success then
        log("✅ Seu script foi executado com sucesso!", "SUCCESS")
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
            wait(1)
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
        log("Nenhum servidor encontrado", "WARNING")
        return nil
    end
    
    local validServers = {}
    for _, server in pairs(servers) do
        if server.id and server.id ~= currentJobId then
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
    log("⏳ Seu script será reexecutado no novo servidor...", "INFO")
    
    local success = false
    local result = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, server.id, localPlayer)
        success = true
    end)
    
    if success and result then
        successfulHops = successfulHops + 1
        log("✅ Hop realizado com sucesso! (Total: " .. successfulHops .. ")", "SUCCESS")
    else
        log("❌ Erro ao fazer hop. Tentando novamente...", "ERROR")
        isHopping = false
    end
    
    return success
end

-- ============================================
-- THREAD PARA SERVEHOP
-- ============================================

local function startServerHopThread()
    task.spawn(function()
        log("========================================", "SUCCESS")
        log("SERVEHOP INICIADO", "HOP")
        log("========================================", "SUCCESS")
        log("Jogo: " .. placeId, "INFO")
        log("Jogador: " .. localPlayer.Name, "INFO")
        log("Min Jogadores: " .. CONFIG.MIN_PLAYERS, "INFO")
        log("Max Jogadores: " .. CONFIG.MAX_PLAYERS, "INFO")
        
        while true do
            if not isHopping then
                local servers = getAvailableServers()
                
                if servers then
                    local bestServer = findBestServer(servers)
                    
                    if bestServer then
                        executeServerHop(bestServer)
                        wait(CONFIG.DELAY_HOP)
                    else
                        log("Procurando servidor melhor...", "INFO")
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
-- MONITORAR MUDANÇA DE SERVIDOR
-- ============================================

local function monitorServerChange()
    task.spawn(function()
        local lastJobId = currentJobId
        
        while true do
            wait(1)
            
            -- Se o JobId mudou, significa que mudou de servidor
            if game.JobId ~= lastJobId then
                log("🌍 Detectado mudança de servidor!", "HOP")
                log("Reexecutando seu script no novo servidor...", "CUSTOM")
                
                wait(2) -- Dar tempo para carregar
                
                -- Reexecutar o script no novo servidor
                executeCustomScript()
                
                lastJobId = game.JobId
            end
        end
    end)
end

-- ============================================
-- INICIAR TUDO
-- ============================================

log("", "INFO")
log("╔════════════════════════════════════════╗", "SUCCESS")
log("║   APEX SERVEHOP + CUSTOM SCRIPT v2     ║", "SUCCESS")
log("║   by: apexscripters                    ║", "SUCCESS")
log("╚════════════════════════════════════════╝", "SUCCESS")
log("", "INFO")

-- Executar script customizado primeira vez
log("📥 Carregando ApexFunctionS...", "CUSTOM")
executeCustomScript()

wait(1)

-- Depois iniciar o servehop em thread separada
log("🚀 Iniciando Servehop...", "HOP")
startServerHopThread()

-- Monitorar mudança de servidor
log("👁️ Monitorando mudanças de servidor...", "INFO")
monitorServerChange()

log("", "INFO")
log("✅ TUDO PRONTO!", "SUCCESS")
log("Seu script ApexFunctionS + Servehop rodando!", "CUSTOM")
log("📌 Quando trocar de servidor, seu script será reexecutado!", "INFO")
log("", "INFO")
