# Sistema Rat King - Survivor-like Game

## Visão Geral
O Rat King é uma classe de invocador (summoner) para um jogo survivor-like na Godot 4. O personagem não ataca diretamente, mas invoca ratos minions que atacam os inimigos automaticamente.

## Arquitetura do Sistema

### Componentes Principais

1. **RatKing.gd** - Personagem principal jogável
2. **RatMinion.gd** - Minions invocados (Area2D para performance)
3. **UpgradeData.gd** - Estrutura de dados para upgrades
4. **UpgradeManager.gd** - Gerenciador do sistema de upgrades

### Características Técnicas

- **Performance Otimizada**: Minions usam Area2D ao invés de CharacterBody2D
- **Sistema de Estados**: Minions têm máquina de estados (Idle, Chase, Attack)
- **Limite de Minions**: Controle automático do número máximo de ratos ativos
- **Sistema de Upgrades**: Pool de upgrades com raridades e condições

## Como Usar

### 1. Configuração Inicial

```gdscript
# Instanciar o Rat King
var rat_king_scene = preload("res://Characters/RatKing/RatKing.tscn")
var rat_king = rat_king_scene.instantiate()
add_child(rat_king)

# Configurar gerenciador de upgrades
var upgrade_manager = UpgradeManager.new()
add_child(upgrade_manager)
```

### 2. Input Actions Necessárias

Configure no Input Map do projeto:
- `move_up` (W, Seta para cima)
- `move_down` (S, Seta para baixo)
- `move_left` (A, Seta para esquerda)
- `move_right` (D, Seta para direita)

### 3. Sistema de Grupos

Configure os grupos no seu jogo:
- `"players"` - Para o Rat King
- `"enemies"` - Para inimigos
- `"minions"` - Para os ratos invocados

### 4. Collision Layers

- **Layer 1**: Player (Rat King)
- **Layer 2**: Enemies
- **Layer 4**: Minions

## Sistema de Upgrades

### Upgrades Básicos (Nível 1-9)

- **stats_amount**: +5 ratos máximos
- **stats_speed**: +20% velocidade dos ratos
- **stats_damage**: +30% dano dos ratos
- **effect_poison**: 30% chance de veneno
- **effect_kamikaze**: 15% chance de explosão
- **stats_burst**: +1 rato por spawn
- **stats_spawn_rate**: -20% tempo entre spawns

### Evoluções (Nível 10)

- **evo_swarm**: Rota do Enxame (dobra quantidade, reduz dano)
- **evo_beast**: Rota das Bestas (menos quantidade, muito mais dano)

### Ultimates (Nível 25)

- **ultimate_plague_lord**: Senhor da Praga (100% veneno, spawn dobrado)
- **ultimate_rat_emperor**: Imperador dos Ratos (dano dobrado, mais kamikazes)

## Exemplo de Integração

```gdscript
# Conectar sinais do Rat King
rat_king.level_up.connect(_on_level_up)
rat_king.evolution_available.connect(_on_evolution_available)

func _on_level_up(new_level: int):
    # Oferecer upgrades aleatórios
    var upgrades = upgrade_manager.get_available_upgrades(
        rat_king.current_level, 
        rat_king.evolution_route, 
        3
    )
    # Mostrar UI de seleção de upgrades

func _on_evolution_available(evolution_type: String):
    if evolution_type == "route_selection":
        # Mostrar escolha entre Enxame vs Bestas
        pass
    elif evolution_type == "ultimate":
        # Aplicar ultimate baseado na rota escolhida
        pass
```

## Configuração de Inimigos

Para que o sistema funcione, os inimigos devem:

1. Estar no grupo `"enemies"`
2. Ter o método `take_damage(amount: float)`
3. Opcionalmente ter `apply_poison(damage: float, duration: float)`

Exemplo de inimigo básico:

```gdscript
extends CharacterBody2D

func _ready():
    add_to_group("enemies")

func take_damage(amount: float):
    health -= amount
    if health <= 0:
        queue_free()

func apply_poison(damage: float, duration: float):
    # Implementar lógica de veneno
    pass
```

## Balanceamento

### Valores Base Recomendados
- **Max Minions**: 10-15 inicial
- **Spawn Rate**: 2-3 segundos
- **Minion Speed**: 100-150
- **Minion Damage**: 10-20
- **Minion Lifetime**: 30 segundos

### Progressão de Dificuldade
- Experiência necessária aumenta 20% por nível
- Upgrades ficam mais raros em níveis altos
- Evoluções mudam drasticamente o gameplay

## Extensibilidade

O sistema foi projetado para ser facilmente extensível:

1. **Novos Upgrades**: Adicione no `UpgradeManager.initialize_upgrade_pool()`
2. **Novos Efeitos**: Implemente no `RatKing.apply_upgrade()`
3. **Novos Tipos de Minion**: Herde de `RatMinion` ou crie variações
4. **Novas Evoluções**: Adicione novas rotas no sistema

## Troubleshooting

### Performance
- Se muitos ratos causarem lag, reduza `max_minions`
- Considere usar object pooling para minions
- Ajuste `lifetime` dos minions para controlar quantidade

### Balanceamento
- Monitor a taxa de spawn vs morte de minions
- Ajuste dano baseado no número de inimigos
- Considere cooldowns para evitar spam de upgrades

### Debug
- Use `rat_king.get_player_info()` para monitorar status
- Ative prints nos upgrades para verificar aplicação
- Monitore `active_minions.size()` para controle de quantidade