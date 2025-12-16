# Instruções para Configurar o Ice Lord no Editor

Siga estas instruções para criar as cenas do Ice Lord (Mago de Controle) no editor do Godot:

## 1. Criar IceProjectile.tscn

1. **Crie uma nova cena** (Scene > New Scene)
2. **Adicione um nó Area2D** como raiz
3. **Renomeie para "IceProjectile"**
4. **Anexe o script** `IceProjectile.gd`
5. **Adicione os nós filhos:**
   - `Sprite2D` (filho de IceProjectile)
   - `CollisionShape2D` (filho de IceProjectile)
   - `Timer` (filho de IceProjectile, renomeie para "LifetimeTimer")

6. **Configure o Sprite2D:**
   - Texture: res://icon.svg
   - Modulate: Color(0.7, 0.9, 1.0, 1.0) - azul gelo
   - Scale: Vector2(0.3, 0.1) - formato alongado de projétil

7. **Configure o CollisionShape2D:**
   - Shape: New RectangleShape2D
   - Size: Vector2(16, 8) - projétil pequeno e alongado

8. **Configure o LifetimeTimer:**
   - Wait Time: 3.0
   - One Shot: true (marque a checkbox)

9. **Salve como** `Characters/IceLord/IceProjectile.tscn`

## 2. Criar IceLordPlayer.tscn

1. **Crie uma nova cena** (Scene > New Scene)
2. **Adicione um nó CharacterBody2D** como raiz
3. **Renomeie para "IceLordPlayer"**
4. **Anexe o script** `IceLordPlayer.gd`
5. **Adicione os nós filhos:**
   - `Sprite2D` (filho de IceLordPlayer)
   - `CollisionShape2D` (filho de IceLordPlayer)
   - `Timer` (filho de IceLordPlayer, renomeie para "AttackTimer")
   - `Camera2D` (filho de IceLordPlayer)
   - `Area2D` (filho de IceLordPlayer, renomeie para "BlizzardArea")

6. **Configure o Sprite2D:**
   - Texture: res://icon.svg
   - Modulate: Color(0.8, 0.9, 1.0, 1) - azul claro mágico
   - Scale: Vector2(0.25, 0.25)

7. **Configure o CollisionShape2D:**
   - Shape: New CircleShape2D
   - Radius: 8

8. **Configure o AttackTimer:**
   - Wait Time: 1.0
   - One Shot: true

9. **Configure o Camera2D:**
   - Zoom: Vector2(1.5, 1.5)

10. **Configure o BlizzardArea (para evolução):**
	- Adicione um `CollisionShape2D` como filho
	- Shape: New CircleShape2D
	- Radius: 150
	- Modulate: Color(0.5, 0.7, 1.0, 0.3) - azul translúcido
	- Monitoring: false (desabilitado inicialmente)

11. **Salve como** `Characters/IceLord/IceLordPlayer.tscn`

## 3. Criar IceLordTest.tscn

1. **Crie uma nova cena** (Scene > New Scene)
2. **Adicione um nó Node2D** como raiz
3. **Renomeie para "IceLordTestLevel"**
4. **Instancie o IceLordPlayer:**
   - Clique com botão direito em IceLordTestLevel
   - Instance Child Scene
   - Selecione `IceLordPlayer.tscn`

5. **Adicione alguns inimigos para teste:**
   - Instance Child Scene
   - Selecione `Enemies/SimpleEnemy.tscn`
   - Posicione em diferentes locais (100,0), (-100,0), (0,100), etc.

6. **Adicione EnemySpawner:**
   - Adicione Node2D como filho
   - Renomeie para "EnemySpawner"
   - Anexe script `_Core/EnemySpawner.gd`
   - Configure:
	 - Enemy Scene: `Enemies/SimpleEnemy.tscn`
	 - Spawn Rate: 2.0
	 - Max Enemies: 20

7. **Salve como** `levels/Debug/IceLordTest.tscn`

## 4. Testar

1. **Mude a main scene** no Project Settings para `IceLordTest.tscn`
2. **Execute o projeto** (F5)
3. **Teste as mecânicas:**
   - WASD para mover
   - Projéteis de gelo disparam automaticamente no inimigo mais próximo
   - Observe os frost stacks se acumulando nos inimigos
   - Inimigos ficam azuis e param quando congelados (3+ stacks)
   - Dano em inimigos congelados causa "Shatter" (dano aumentado)
   - ESC para debug UI

## Mecânicas do Ice Lord

### Sistema de Frost Stacks
- **Projéteis aplicam frost stacks** nos inimigos
- **Cada stack reduz velocidade** do inimigo em 10%
- **3+ stacks = CONGELADO** (velocidade = 0, azul)
- **Stacks decaem** gradualmente se não receber mais frost

### Sistema de Shatter
- **Inimigos congelados** recebem +50% de dano
- **Shatter quebra o gelo** imediatamente
- **Efeito visual especial** azul brilhante

### Evoluções (Level 10)
- **Blizzard**: Aura congelante ao redor do player
- **Lance**: Projétil perfurante infinito mais rápido

## Scripts Já Prontos

Os scripts já estão criados e funcionais:
- ✅ `IceProjectile.gd` - Projétil com frost stacks
- ✅ `IceLordPlayer.gd` - Mago com mira automática
- ✅ `IceLordUpgrades.gd` - Sistema completo de upgrades
- ✅ `SimpleEnemy.gd` - Atualizado com sistema de frost

Apenas as cenas (.tscn) precisam ser criadas no editor seguindo as instruções acima.

## Diferencial do Ice Lord

### Jogabilidade Única
- **Controle de Campo**: Foca em desacelerar e controlar inimigos
- **Combo System**: Frost stacks → Freeze → Shatter
- **Mira Automática**: Projéteis miram no inimigo mais próximo
- **Estratégia**: Acumular stacks para maximizar controle

### Comparação com Outros Personagens
- **Summoner (RatKing)**: Quantidade e enxame
- **Berserker**: Dano direto e knockback
- **Ice Lord**: Controle e combos de status
