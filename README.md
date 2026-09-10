# 🔄 Auto Servehop Universal - Lua

Script Lua **universal** para auto servehop e auto-execute que funciona em **TODOS os executores**.

## ✨ Features

✅ **Funciona em todos executores** (Delta Executor, Synapse, etc)  
✅ **Sem spam de arquivos** - Gera apenas 1 arquivo  
✅ **Código otimizado** - Performático e leve  
✅ **Anti-crash** - Proteção contra múltiplas execuções  
✅ **Anti-lag** - Sistema de delay inteligente  
✅ **Configurável** - Ajuste min/max de jogadores  
✅ **Debug ativado** - Mensagens de status em tempo real  

## 🚀 Como Usar

### 1️⃣ **Copiar o Script**
```lua
-- Copie todo o conteúdo de: auto-servehop.lua
```

### 2️⃣ **No Delta Executor (ou outro)**
- Abra o executor
- Cole o script
- Clique em "Execute" ou "Executar"
- ✅ Pronto! Vai fazer servehop automaticamente

### 3️⃣ **Parar o Script**
- Saia do jogo ou
- Feche o executor

## ⚙️ Configurações

Edite as configurações no topo do script:

```lua
local CONFIG = {
    MIN_PLAYERS = 5,           -- Mínimo de jogadores (padrão: 5)
    MAX_PLAYERS = 25,          -- Máximo de jogadores (padrão: 25)
    DELAY_HOP = 2,             -- Delay entre hops em segundos (padrão: 2)
    DELAY_RETRY = 5,           -- Delay para nova tentativa (padrão: 5)
    TIMEOUT = 10,              -- Timeout para requisições (padrão: 10)
    DEBUG = true               -- Mostrar mensagens (padrão: true)
}
```

### Exemplos de Configuração

**Para salas vazias:**
```lua
MIN_PLAYERS = 1
MAX_PLAYERS = 10
```

**Para salas cheias:**
```lua
MIN_PLAYERS = 20
MAX_PLAYERS = 50
```

**Mais rápido:**
```lua
DELAY_HOP = 1
```

**Mais lento:**
```lua
DELAY_HOP = 5
```

## 📊 Logs e Status

O script mostra em tempo real:
- 🟢 Servidores encontrados
- 🔄 Hops realizados com sucesso
- ⚠️ Avisos e erros
- 📊 Total de hops bem-sucedidos

Exemplo:
```
[14:32:15] ✅ === SERVEHOP UNIVERSAL INICIADO ===
[14:32:15] ℹ️ Jogo: 123456789
[14:32:15] ℹ️ Jogador: seu_usuario
[14:32:16] 🔄 Conectando ao servidor: abc123 (12 jogadores)
[14:32:20] ✅ Hop realizado com sucesso! (Total: 1)
```

## 🛡️ Proteção

✅ **Sem spam de arquivos** - Armazena estado em memória  
✅ **Sem múltiplas instâncias** - Previne execução duplicada  
✅ **Cleanup automático** - Limpa variáveis ao descarregar  
✅ **Error handling** - Trata erros sem crashar  

## 🔧 Compatibilidade

| Executor | Status |
|----------|--------|
| Delta Executor | ✅ Funciona |
| Synapse X | ✅ Funciona |
| Script-Ware | ✅ Funciona |
| Krnl | ✅ Funciona |
| JJSploit | ✅ Funciona |
| Exploit X | ✅ Funciona |
| Outros | ✅ Funciona |

## 📝 Changelog

### v1.0.0 (Inicial)
- ✅ Script base completo
- ✅ Auto servehop funcional
- ✅ Sistema de proteção contra spam
- ✅ Debug e logs em tempo real
- ✅ Compatibilidade universal

## ⚠️ Aviso Legal

Este script é para **fins educacionais**. Use por sua conta e risco.

## 🤝 Contribuir

Encontrou um bug? Quer melhorias?  
Abra uma [issue](https://github.com/apexscripters/lua-auto-servehop-executor/issues) ou faça um [pull request](https://github.com/apexscripters/lua-auto-servehop-executor/pulls)

## 📧 Contato

GitHub: [@apexscripters](https://github.com/apexscripters)

---

**⭐ Se gostou, deixe uma estrela no repositório!**
