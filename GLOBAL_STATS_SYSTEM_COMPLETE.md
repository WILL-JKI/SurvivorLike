# Sistema de Status Globais e Itens Passivos - IMPLEMENTAÇÃO COMPLETA

## Visão Geral
Implementado sistema completo de **Status Globais** e **10 Itens Passivos** que afetam todos os personagens do jogo de forma universal. Sistema modular e escalável para futuras expansões.

## Arquivos Implementados

### ✅ Core System
- **`_Core/GameManager.gd`** - Sistema de stats globais com dicionário e funções
- **`_Core/ItemData.gd`** - Resource class para definir itens passivos
- **`_Core/ItemManager.gd`** - Gerenciador de todos os itens do jogo
- **`_Core/ItemSystemTest.gd`** - Script de teste para validar o sistema

### ✅ Character Integration
- **`Characters/RatKing/RatKing.gd`** - Integração completa com stats globais
- **`Characters/Berserker/BerserkerPlayer.gd`** - Integração completa com stats globais

## Sistema de Stats Globais

### Dicionário Base (GameManager.global_stats)
```gdscript
{
    "area_size": 1.0,           # Multiplicador de tamanho de área
    "luck": 1.0,                # Multiplicador de sorte  
    "cooldown_reduction": 0.0,  # Redução de cooldown (0.0 a 1.0)
    "move_speed": 1.0,          # Multiplicador de velocidade
    "projectile_speed": 1.0,    # Multiplicador de velocidade de projétil
    "knockback": 1.0,           # Multiplicador de knockback
    "pickup_range": 1.0,        # Multiplicador de alcance de coleta
    "max_health_mult": 1.0,     # Multiplicador de vida máxima
    "thorns_damage": 0.0,       # Dano de retaliação base
    "xp_gain": 1.0              # Multiplicador de ganho de XP
}
```

### Funções Principais
- **`apply_stat_upgrade(stat_key, value)`** - Aplica upgrade a um stat
- **`get_stat(stat_key)`** - Obtém valor atual de um stat
- **`reset_global_stats()`** - Reseta stats para valores padrão
- **`stat_changed` signal** - Notifica mudanças de stats

## 10 Itens Passivos Implementados

| Item | Stat | Valor | Descrição |
|------|------|-------|-----------|
| **Sanduíche de Jake** | area_size | +0.10 | +10% Tamanho de Área |
| **Trevo de 7 Folhas** | luck | +0.07 | +7% Sorte |
| **Café Expresso** | cooldown_reduction | +0.10 | -10% Tempo de Recarga |
| **Bota de Hermes** | move_speed | +0.10 | +10% Velocidade de Movimento |
| **Óculos de Precisão** | projectile_speed | +0.20 | +20% Velocidade de Projétil |
| **Manopla de Titã** | knockback | +1.0 | +100% Força de Knockback |
| **Imã de Sucata** | pickup_range | +0.30 | +30% Alcance de Coleta |
| **Coração de Dragão** | max_health_mult | +0.20 | +20% Vida Máxima |
| **Anel de Espinhos** | thorns_damage | +0.10 | +10% Dano de Retaliação |
| **Pergaminho Proibido** | xp_gain | +0.10 | +10% Ganho de XP |

## Integração com Personagens

### RatKing (Summoner)
```gdscript
# Stats Afetados:
- effective_max_health = max_health * max_health_mult
- effective_movement_speed = movement_speed * move_speed  
- effective_xp_multiplier = xp_gain
- minion_scale = area_size (aplicado aos ratos)

# Reação a Mudanças:
- Vida máxima atualizada proporcionalmente
- Velocidade aplicada imediatamente
- Area size aplicado a todos os minions ativos
- XP multiplicado em gain_experience()
```

### Berserker (Melee)
```gdscript
# Stats Afetados:
- effective_max_health = max_health * max_health_mult
- effective_movement_speed = movement_speed * move_speed
- effective_base_cooldown = base_cooldown * (1.0 - cooldown_reduction)
- effective_xp_multiplier = xp_gain
- weapon.area_size = area_size (aplicado à espada)
- weapon.knockback_force *= knockback

# Reação a Mudanças:
- Cooldown de ataque reduzido
- Área da espada modificada
- Knockback da espada aumentado
- Velocidade e vida aplicadas imediatamente
```

### Ice Lord (Control Mage)
```gdscript
# Integração Futura:
- projectile_speed afetará velocidade dos projéteis de gelo
- area_size afetará área de congelamento da evolução Blizzard
- cooldown_reduction afetará taxa de disparo
- move_speed e max_health_mult aplicados normalmente
```

## Sistema de Sinais

### GameManager.stat_changed
```gdscript
# Emitido quando um stat é modificado
signal stat_changed(stat_key: String, new_value: float)

# Personagens conectam para reagir imediatamente:
GameManager.stat_changed.connect(_on_global_stat_changed)
```

### Reação Inteligente
- **Vida máxima**: Atualiza proporcionalmente sem perder vida atual
- **Velocidade**: Aplicada imediatamente ao movimento
- **Area size**: Aplicada a armas/minions em tempo real
- **Cooldown**: Afeta próximos ataques

## Funcionalidades Avançadas

### ItemManager
- **Inicialização automática** de todos os 10 itens
- **Busca por nome** ou stat_key
- **Seleção aleatória** para sistema de level up
- **Validação** de itens antes da aplicação
- **Debug tools** para desenvolvimento

### ItemData Resource
- **Descrições formatadas** com placeholders {value}
- **Validação automática** de stat_keys
- **Aplicação segura** com verificações
- **Suporte a ícones** (placeholder atual)

## Exemplos de Uso

### Aplicar Item Manualmente
```gdscript
var item = ItemManager.get_item_by_name("Sanduíche de Jake")
ItemManager.apply_item(item)
# Resultado: area_size aumenta de 1.0 para 1.10
```

### Obter Itens Aleatórios (Level Up)
```gdscript
var random_items = ItemManager.get_random_items(3)
# Retorna 3 itens diferentes para escolha do player
```

### Aplicar Stat Diretamente
```gdscript
GameManager.apply_stat_upgrade("move_speed", 0.15)
# Aumenta velocidade em 15% imediatamente
```

## Benefícios do Sistema

### Modularidade
- **Fácil adição** de novos itens
- **Stats independentes** dos personagens
- **Sistema universal** para todos os characters

### Performance
- **Sinais eficientes** para notificação
- **Cálculos otimizados** apenas quando necessário
- **Cache de stats** nos personagens

### Escalabilidade
- **Suporte ilimitado** de novos stats
- **Integração simples** com novos personagens
- **Sistema de validação** robusto

## Testes Implementados

### ItemSystemTest.gd
- **Inicialização** dos 10 itens
- **Aplicação** de itens específicos
- **Validação** de valores de stats
- **Seleção aleatória** de itens
- **Debug completo** do sistema

### Como Testar
1. Execute o jogo
2. Adicione ItemSystemTest a uma cena
3. Observe console para resultados dos testes
4. Use `apply_test_items()` para teste manual

## Status da Implementação

### ✅ Completo
- Sistema de stats globais funcional
- 10 itens passivos implementados
- Integração com RatKing e Berserker
- Sistema de sinais para reação em tempo real
- Testes e validação implementados

### 🎯 Próximos Passos
1. **UI de Level Up** para seleção de itens
2. **Integração com Ice Lord** 
3. **Ícones personalizados** para cada item
4. **Efeitos visuais** para aplicação de itens
5. **Sistema de raridade** de itens

---
**Status**: SISTEMA COMPLETO ✅  
**Itens**: 10 passivos implementados  
**Integração**: RatKing + Berserker funcionais  
**Escalabilidade**: Pronto para expansão  