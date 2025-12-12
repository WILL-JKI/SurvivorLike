# Como Adicionar Fontes Personalizadas

## 1. Adicionando Arquivos de Fonte

Coloque seus arquivos de fonte (.ttf, .otf, .woff2) nesta pasta:
- `PixelFont.ttf` - Para elementos de gameplay (números de dano, etc.)
- `UIFont.ttf` - Para interface do usuário
- `TitleFont.ttf` - Para títulos e menus

## 2. Configurando no FontManager

Edite o arquivo `_Core/FontManager.gd` e descomente/modifique estas linhas:

```gdscript
func setup_fonts():
    # Carregar fontes personalizadas
    pixel_font = load("res://Assets/Fonts/PixelFont.ttf")
    ui_font = load("res://Assets/Fonts/UIFont.ttf")
```

## 3. Fontes Recomendadas para Pixel Art

### Gratuitas:
- **Pixel Operator** - Fonte monospace pixel perfeita
- **m5x7** - Fonte bitmap clássica
- **Silkscreen** - Fonte pixel art moderna
- **Press Start 2P** - Estilo arcade clássico

### Onde Encontrar:
- Google Fonts (Press Start 2P, Silkscreen)
- itch.io (muitas fontes pixel art gratuitas)
- dafont.com (seção bitmap/pixel)

## 4. Configurações Importantes

Para pixel art, sempre configure:
- `Hinting`: None
- `Subpixel Positioning`: Disabled
- `Antialiasing`: None
- `Filter`: Off

## 5. Aplicando Fontes

### Automaticamente (recomendado):
```gdscript
FontManager.apply_pixel_font(meu_label, 12)
```

### Manualmente:
```gdscript
meu_label.add_theme_font_override("font", FontManager.pixel_font)
meu_label.add_theme_font_size_override("font_size", 12)
```

## 6. Tema Global

Para aplicar uma fonte globalmente, edite `project.godot`:

```ini
[gui]
theme/custom="res://_Core/GameTheme.tres"
```

E configure o tema no arquivo .tres com sua fonte personalizada.