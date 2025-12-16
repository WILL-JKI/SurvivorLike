# Instruções para Criar UniversalTestLevel.tscn

Siga estas instruções para criar o level de teste universal no editor do Godot:

## 1. Criar UniversalTestLevel.tscn

1. **Crie uma nova cena** (Scene > New Scene)
2. **Adicione um nó Node2D** como raiz
3. **Renomeie para "UniversalTestLevel"**
4. **Anexe o script** `UniversalTestLevel.gd`

## 2. Adicionar Componentes do Level

### EnemySpawner
5. **Adicione Node2D como filho** de UniversalTestLevel
6. **Renomeie para "EnemySpawner"**
7. **Anexe o script** `_Core/EnemySpawner.gd`
8. **Configure no Inspector:**
   - Enemy Scene: `res://Enemies/SimpleEnemy.tscn`
   - Spawn Rate: 3.0 (spawn a cada 3 segundos)
   - Max Enemies: 25 (máximo de inimigos na tela)
   - Spawn Radius: 400.0

### Boss Spawn Timer
9. **Adicione Timer como filho** de UniversalTestLevel
10. **Renomeie para "BossSpawnTimer"**
11. **Configure no Inspector:**
    - Wait Time: 30.0 (boss spawna após 30 segundos)
    - One Shot: true (marque a checkbox)

### UI Layer
12. **Adicione CanvasLayer como filho** de UniversalTestLevel
13. **Renomeie para "UI"**

### Instructions Label
14. **Adicione Label como filho** de UI
15. **Renomeie para "Instructions"**
16. **Configure no Inspector:**
    - Anchors Preset: Bottom Left
    - Position: (10, -120)
    - Size: (400, 100)
    - Text: 
    ```
    UNIVERSAL TEST LEVEL
    
    ENTER: Spawn extra enemies
    SPACE: Force boss spawn
    ESC: Return to character selection
    F3: Debug UI
    ```
    - Font Size: 12

## 3. Configurar Properties do Level

17. **Selecione o nó raiz "UniversalTestLevel"**
18. **No Inspector, configure:**
    - Initial Enemies: 5
    - Boss Spawn Delay: 30.0
    - Spawn Positions Radius: 400.0

## 4. Salvar e Configurar

19. **Salve como** `levels/Debug/UniversalTestLevel.tscn`

## 5. Atualizar GameManager

O GameManager já foi configurado para usar este level. Agora você precisa atualizar para que todos os personagens usem este level universal.

## Funcionalidades do Level

### Spawn Automático
- **Personagem**: Spawna automaticamente o personagem selecionado no centro
- **Inimigos Iniciais**: 5 inimigos ao redor do player
- **Spawn Contínuo**: EnemySpawner adiciona inimigos constantemente
- **Boss**: Spawna automaticamente após 30 segundos

### Controles de Teste
- **ENTER**: Spawna 3 inimigos extras para teste
- **SPACE**: Força o spawn do boss imediatamente
- **ESC**: Volta ao menu de seleção de personagens
- **F3**: Debug UI (se disponível)

### Compatibilidade
- ✅ **Berserker**: Espada direcional
- ✅ **Rat King**: Sistema de minions otimizado
- ✅ **Ice Lord**: Projéteis de gelo com frost stacks
- ✅ **Futuros personagens**: Sistema modular

### Aviso de Boss
- **Aviso visual** quando o boss spawna
- **Animação** de alerta vermelho piscando
- **Sistema de câmera** se ajusta automaticamente (RatKing)

## Teste Completo

1. **Execute o jogo** (F5)
2. **Selecione qualquer personagem** na tela de seleção
3. **Clique "Start Game"**
4. **Teste as mecânicas** específicas de cada personagem
5. **Aguarde 30s** para o boss spawnar automaticamente
6. **Use os controles** para testar spawn extra de inimigos

Este level serve como ambiente de teste completo para todos os personagens implementados!