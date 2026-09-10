--[[
    ⚙️ AUTO SERVEHOP + AUTO EXECUTE UNIVERSAL
    
    ✨ Features:
    • Funciona em TODOS os executores (Delta, Synapse, etc)
    • Sem gerar spam de arquivos
    • Otimizado e melhorado
    • Anti-lag e anti-crash
    • Configuração fácil
    
    📝 Criador: apexscripters
    🔗 Repositório: github.com/apexscripters/lua-auto-servehop-executor
]]

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
local CONFIG = {
    MIN_PLAYERS = 5,           -- Mínimo de jogadores
    MAX_PLAYERS = 25,          -- Máximo de jogadores
    DELAY_HOP = 2,             -- Delay entre hops (segundos)
    DELAY_RETRY = 5,           -- Delay para nova tentativa
    TIMEOUT = 10,              -- Timeout para requisições
    DEBUG = true               -- Mostrar mensagens de debug
}

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
local currentJobId = game.JobId
local isHopping = false
local hopAttempts = 0
local successfulHops = 0

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================

-- Log com timestamp
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
    
    print("[" .. timestamp .. "] " .. prefix .. " " .. message)
end

-- Sanitizar JobId
local function sanitizeJobId(jobId)
    if not jobId or jobId == "" then return nil end
    if jobId == currentJobId then return nil end
    return jobId
end

-- Fazer requisição HTTP com retry
local function makeRequest(url, retries)
    retries = retries or 3
    local response = nil
    
    for attempt = 1, retries do
        local success, result = pcall(function()
            return HttpService:GetAsync(url, false)
        end)
        
        if success then
            response = result
            break
        else
            log("Tentativa " .. attempt .. "/" .. retries .. " falhou. Tentando novamente...", "WARNING")
            wait(1)
        end
    end
    
    return response
end

-- Decodificar JSON com segurança
local function decodeJSON(jsonString)
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    
    if success then
        return result
    else
        log("Erro ao decodificar JSON", "ERROR")
        return nil
    end
end

-- ============================================
-- FUNÇÃO PRINCIPAL DE SERVEHOP
-- ============================================

local function getAvailableServers()
    log("Buscando servidores disponíveis...", "INFO")
    
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local response = makeRequest(url)
    
    if not response then
        log("Erro ao conectar na API do Roblox", "ERROR")
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
    
    -- Filtrar servidores adequados
    local validServers = {}
    for _, server in pairs(servers) do
        if server.id and sanitizeJobId(server.id) then
            local playerCount = server.playerCount or 0
            
            if playerCount >= CONFIG.MIN_PLAYERS and playerCount <= CONFIG.MAX_PLAYERS then
                table.insert(validServers, {
                    id = server.id,
                    playerCount = playerCount,
                    ping = server.ping or 0
                })
            end
        end
    end
    
    -- Ordenar por número de jogadores (preferência)
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
        log("Já está fazendo hop, aguarde...", "WARNING")
        return false
    end
    
    isHopping = true
    hopAttempts = hopAttempts + 1
    
    log("Conectando ao servidor: " .. server.id .. " (" .. server.playerCount .. " jogadores)", "HOP")
    
    local success = false
    local result = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, server.id, localPlayer)
        success = true
    end)
    
    if success and result then
        successfulHops = successfulHops + 1
        log("Hop realizado com sucesso! (Total: " .. successfulHops .. ")", "SUCCESS")
    else
        log("Erro ao fazer hop. Tentando novamente...", "ERROR")
        isHopping = false
    end
    
    return success
end

-- ============================================
-- LOOP PRINCIPAL
-- ============================================

local function startAutoServerHop()
    log("=== SERVEHOP UNIVERSAL INICIADO ===", "SUCCESS")
    log("Jogo: " .. placeId, "INFO")
    log("Jogador: " .. localPlayer.Name, "INFO")
    log("Min Jogadores: " .. CONFIG.MIN_PLAYERS, "INFO")
    log("Max Jogadores: " .. CONFIG.MAX_PLAYERS, "INFO")
    log("================================", "SUCCESS")
    
    while true do
        if not isHopping then
            local servers = getAvailableServers()
            
            if servers then
                local bestServer = findBestServer(servers)
                
                if bestServer then
                    executeServerHop(bestServer)
                    wait(CONFIG.DELAY_HOP)
                else
                    log("Nenhum servidor disponível nos critérios. Tentando novamente em " .. CONFIG.DELAY_RETRY .. "s", "WARNING")
                    wait(CONFIG.DELAY_RETRY)
                end
            else
                log("Erro ao buscar servidores. Tentando novamente em " .. CONFIG.DELAY_RETRY .. "s", "ERROR")
                wait(CONFIG.DELAY_RETRY)
            end
        else
            wait(1)
        end
    end
end

-- ============================================
-- PROTEÇÃO CONTRA SPAM E MÚLTIPLAS EXECUÇÕES
-- ============================================

local SCRIPT_KEY = "AutoServehopRunning_" .. placeId
local isScriptRunning = getgenv()[SCRIPT_KEY]

if isScriptRunning then
    log("Script já está em execução! Encerrando instância duplicada...", "WARNING")
    return
end

getgenv()[SCRIPT_KEY] = true

-- Cleanup ao descarregar
local function cleanup()
    log("Script encerrado. Limpando...", "INFO")
    getgenv()[SCRIPT_KEY] = nil
end

-- Detectar se o script foi descarregado
if game:GetService("Players").LocalPlayer then
    game:GetService("Players").LocalPlayer.ChildRemoved:Connect(function()
        cleanup()
    end)
end

-- ============================================
-- INICIAR
-- ============================================

startAutoServerHop()
