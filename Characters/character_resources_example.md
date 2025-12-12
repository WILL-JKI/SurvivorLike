# Como Criar Resources de Personagem

## Criando Resources no Editor

1. **No FileSystem**, clique com botão direito
2. **New Resource**
3. **Selecione "CharacterResource"**
4. **Configure as propriedades:**

### Berserker Resource
```
Character Name: "Berserker"
Character ID: "berserker"
Description: "[color=red][b]GUERREIRO FURIOSO[/b][/color]..."
Player Scene Path: "res://Characters/Berserker/BerserkerPlayer.tscn"
Base Health: 120
Base Speed: 100
Base Damage: 25
Weapon Type: "Vórtice de Lâminas"
Character Class: "Melee DPS"
Difficulty: "Medium"
Special Ability: "Fúria Crescente"
```

### Rat King Resource
```
Character Name: "Rei dos Ratos"
Character ID: "rat_king"
Description: "[color=purple][b]INVOCADOR SOMBRIO[/b][/color]..."
Player Scene Path: "res://Characters/RatKing/RatKing.tscn"
Base Health: 100
Base Speed: 120
Base Damage: 10
Weapon Type: "Horda de Minions"
Character Class: "Summoner"
Difficulty: "Easy"
Special Ability: "Invocação Automática"
```

## Adicionando ao CharacterSelect

1. **Abra CharacterSelection.tscn**
2. **Selecione o nó raiz "CharacterSelection"**
3. **No Inspector**, encontre "Available Characters"
4. **Adicione os Resources criados**

## Criando Portraits

1. **Crie texturas 128x128** para portraits pequenos
2. **Crie texturas 256x256** para portraits grandes
3. **Salve em Characters/[Nome]/portraits/**
4. **Atribua nos Resources**