# Instruções para Configurar o Berserker no Editor

Como os arquivos .tscn estão com problemas de parse, siga estas instruções para criar as cenas no editor do Godot:

## 1. Criar BerserkerWeapon.tscn

1. **Crie uma nova cena** (Scene > New Scene)
2. **Adicione um nó Area2D** como raiz
3. **Renomeie para "BerserkerWeapon"**
4. **Anexe o script** `BerserkerWeapon.gd`
5. **Adicione os nós filhos:**
   - `CollisionShape2D` (filho de BerserkerWeapon)
   - `Sprite2D` (filho de BerserkerWeapon)  
   - `Timer` (filho de BerserkerWeapon, renomeie para "AttackTimer")

6. **Configure o CollisionShape2D:**
   - Shape: New CircleShape2D
   - Radius: 50
   - Disabled: true (marque a checkbox)

7. **Configure o Sprite2D:**
   - Texture: res://icon.svg
   - Modulate: Color(1, 0.5, 0.5, 0.8) - vermelho translúcido
   - Scale: Vector2(0.5, 0.5)

8. **Configure o AttackTimer:**
   - Wait Time: 0.3
   - One Shot: true (marque a checkbox)

9. **Salve como** `Characters/Berserker/BerserkerWeapon.tscn`

## 2. Criar BerserkerPlayer.tscn

1. **Crie uma nova cena** (Scene > New Scene)
2. **Adicione um nó CharacterBody2D** como raiz
3. **Renomeie para "BerserkerPlayer"**
4. **Anexe o script** `BerserkerPlayer.gd`
5. **Adicione os nós filhos:**
   - `Sprite2D` (filho de BerserkerPlayer)
   - `CollisionShape2D` (filho de BerserkerPlayer)
   - `Area2D` (filho de BerserkerPlayer, renomeie para "FuryDetector")
   - `Timer` (filho de BerserkerPlayer, renomeie para "AttackTimer")
   - `Camera2D` (filho de BerserkerPlayer)

6. **Configure o Sprite2D:**
   - Texture: res://icon.svg
   - Modulate: Color(1, 0.7, 0.7, 1) - rosa claro
   - Scale: Vector2(0.25, 0.25)

7. **Configure o CollisionShape2D:**
   - Shape: New CircleShape2D
   - Radius: 8

8. **Configure o FuryDetector:**
   - Adicione um `CollisionShape2D` como filho
   - Shape: New CircleShape2D
   - Radius: 100
   - Modulate: Color(1, 0, 0, 0.2) - vermelho translúcido

9. **Configure o AttackTimer:**
   - Wait Time: 1.5
   - One Shot: true

10. **Configure o Camera2D:**
    - Zoom: Vector2(1.5, 1.5)

11. **Instancie a BerserkerWeapon:**
    - Clique com botão direito em BerserkerPlayer
    - Instance Child Scene
    - Selecione `BerserkerWeapon.tscn`

12. **Salve como** `Characters/Berserker/BerserkerPlayer.tscn`

## 3. Criar BerserkerTest.tscn

1. **Crie uma nova cena** (Scene > New Scene)
2. **Adicione um nó Node2D** como raiz
3. **Renomeie para "BerserkerTestLevel"**
4. **Instancie o BerserkerPlayer:**
   - Clique com botão direito em BerserkerTestLevel
   - Instance Child Scene
   - Selecione `BerserkerPlayer.tscn`

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

7. **Salve como** `levels/Debug/BerserkerTest.tscn`

## 4. Testar

1. **Mude a main scene** no Project Settings para `BerserkerTest.tscn`
2. **Execute o projeto** (F5)
3. **Teste as mecânicas:**
   - WASD para mover
   - Aproxime-se dos inimigos
   - Ataque automático deve ativar
   - ESC para debug UI

## Scripts Já Prontos

Os scripts já estão criados e funcionais:
- ✅ `BerserkerWeapon.gd`
- ✅ `BerserkerPlayer.gd`
- ✅ `BerserkerUpgrades.gd`

Apenas as cenas (.tscn) precisam ser criadas no editor seguindo as instruções acima.