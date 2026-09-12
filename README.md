# 🚀 APEX SERVEHOP - Guia de Uso Completo

## 📋 Arquivos Disponíveis

### 1️⃣ **auto-servehop.lua** (Servehop Puro)
- ✅ Apenas servehop automático
- ✅ Sem nenhum script customizado
- 👉 Use se quiser APENAS fazer servehop

### 2️⃣ **auto-servehop-apex.lua** (✨ RECOMENDADO PARA VOCÊ)
- ✅ **ApexFunctionS já integrado**
- ✅ Servehop + seu script rodando juntos
- ✅ Sem conflitos
- 👉 **ESTE É O QUE VOCÊ PRECISA!**

### 3️⃣ **auto-servehop-custom.lua** (Para Outros Scripts)
- ✅ Customizável para qualquer script
- ✅ Suporta Link, Loadstring ou Código
- 👉 Use se quiser outro script que não seja ApexFunctionS

---

## 🎯 PASSO A PASSO PARA VOCÊ

### Opção 1: Use o APEX (Recomendado)

```
1. Clique em: auto-servehop-apex.lua
2. Copie TODO o código (Ctrl+A + Ctrl+C)
3. Abra Delta Executor
4. Cole no editor (Ctrl+V)
5. Clique em "Execute"
6. ✅ Pronto! ApexFunctionS + Servehop rodando!
```

---

## ⚙️ Configurações

Se quiser ajustar o servehop, edite no topo do arquivo:

```lua
local CONFIG = {
    MIN_PLAYERS = 5,      -- Mínimo de jogadores (mude para 1-10)
    MAX_PLAYERS = 25,     -- Máximo de jogadores (mude para 20-50)
    DELAY_HOP = 2,        -- Segundos entre hops (1 = mais rápido)
    DELAY_RETRY = 5,      -- Segundos para nova tentativa
    DEBUG = true          -- Mostrar logs (deixe true)
}
```

---

## 📊 Logs Esperados

Ao executar, você verá algo assim:

```
╔════════════════════════════════════════╗
║   APEX SERVEHOP + CUSTOM SCRIPT        ║
║   by: apexscripters                    ║
╚════════════════════════════════════════╝

📥 Carregando ApexFunctionS...
✅ Seu script foi executado com sucesso!

🚀 Iniciando Servehop...
========================================
SERVEHOP INICIADO
========================================
ℹ️ Jogo: 123456789
ℹ️ Jogador: seu_usuario
ℹ️ Min Jogadores: 5
ℹ️ Max Jogadores: 25

✅ TUDO PRONTO!
Seu script ApexFunctionS + Servehop rodando!

🔄 Conectando ao servidor: abc123 (12 jogadores)
✅ Hop realizado com sucesso! (Total: 1)
```

---

## ✅ Funcionalidades

| Feature | Status |
|---------|--------|
| ApexFunctionS Executando | ✅ Sim |
| Servehop Automático | ✅ Sim |
| Anti-Crash | ✅ Sim |
| Anti-Lag | ✅ Sim |
| Sem Spam de Arquivos | ✅ Sim |
| Compatível com Delta Executor | ✅ Sim |

---

## ❓ FAQ

**P: Pode parar o script?**
R: Feche o Delta Executor ou saia do jogo.

**P: Quer mudar para outro script?**
R: Use `auto-servehop-custom.lua` e mude a URL.

**P: Crashou?**
R: Execute novamente, tem proteção contra duplicação.

**P: Muito lento ou rápido?**
R: Mude `DELAY_HOP` de 2 para 1 (mais rápido) ou 5 (mais lento).

---

## 🔗 Links Úteis

- 📂 Repositório: https://github.com/apexscripters/lua-auto-servehop-executor
- 💻 ApexFunctionS: https://github.com/apexscripters/ApexFunctionS

---

**⭐ Gostou? Deixe uma estrela no repositório!**
