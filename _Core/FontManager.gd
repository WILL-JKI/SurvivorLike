extends Node
# Gerenciador global de fontes para o jogo

# Singleton para gerenciar fontes do jogo
# Adicione este script como AutoLoad no projeto

var default_font: Font
var pixel_font: Font
var ui_font: Font

func _ready():
	setup_fonts()

func setup_fonts():
	# Configurar fonte padrão do sistema (fallback)
	default_font = ThemeDB.fallback_font
	
	# Tentar carregar fontes personalizadas
	if ResourceLoader.exists("res://Assets/Fonts/PixelFont.ttf"):
		pixel_font = load("res://Assets/Fonts/PixelFont.ttf")
		print("FontManager: Fonte pixel personalizada carregada")
	else:
		# Usar fonte padrão com configurações pixel art
		pixel_font = default_font
		print("FontManager: Usando fonte padrão para pixel art")
	
	if ResourceLoader.exists("res://Assets/Fonts/UIFont.ttf"):
		ui_font = load("res://Assets/Fonts/UIFont.ttf")
		print("FontManager: Fonte UI personalizada carregada")
	else:
		ui_font = default_font
		print("FontManager: Usando fonte padrão para UI")
	
	print("FontManager: Fontes configuradas")

# Função para aplicar fonte pixel art a um Label
func apply_pixel_font(label: Label, size: int = 12):
	if pixel_font:
		label.add_theme_font_override("font", pixel_font)
	
	label.add_theme_font_size_override("font_size", size)
	
	# Configurações para pixel art
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)

# Função para aplicar fonte de UI
func apply_ui_font(control: Control, size: int = 14):
	if ui_font:
		control.add_theme_font_override("font", ui_font)
	
	control.add_theme_font_size_override("font_size", size)

# Função para criar tema personalizado
func create_pixel_theme() -> Theme:
	var theme = Theme.new()
	
	# Configurar fonte padrão
	if pixel_font:
		theme.default_font = pixel_font
	
	theme.default_font_size = 12
	
	# Configurações para Labels
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("font_outline_color", "Label", Color.BLACK)
	theme.set_constant("outline_size", "Label", 1)
	
	return theme