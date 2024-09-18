extends CanvasLayer

@onready var pairs_container = $PanelContainer/MarginContainer/PairsContainer
@onready var winner_container = $PanelContainer/MarginContainer/WinnerContainer

@onready var file_dialog_dir = $FileDialogDir

@onready var left_button: TextureButton = %LeftTextureButton
@onready var right_button: TextureButton = %RightTextureButton

@onready var winner_texture_rect = %WinnerTextureRect
@onready var winner_texture_name_label = %WinnerTextureNameLabel

var images_array: Array[ImageTexture]
var temp_images_array: Array[ImageTexture]

var left_image: ImageTexture
var right_image: ImageTexture


func _ready():
	file_dialog_dir.current_dir = "/"

	left_button.pressed.connect(button_pressed.bind("left_image"))
	right_button.pressed.connect(button_pressed.bind("right_image"))

	file_dialog_dir.show()
	winner_container.hide()


func button_pressed(image):
	match image:
		"left_image":
			temp_images_array.append(left_image)
		
		"right_image":
			temp_images_array.append(right_image)

	if check_for_pairs():
		set_pair_of_images()
	else:
		temp_images_array.append_array(images_array)
		if temp_images_array.size() > 1:
			images_array = temp_images_array
			temp_images_array = []
			set_pair_of_images()
		else:
			var winner_texture = temp_images_array.pop_front()
			winner_texture_rect.texture = winner_texture
			winner_texture_name_label.text = winner_texture.resource_name
			
			pairs_container.hide()
			winner_container.show()


func set_pair_of_images():
	var images_for_buttons = give_two()
	left_image = images_for_buttons.pop_front()
	right_image = images_for_buttons.pop_front()
	
	left_button.texture_normal = left_image
	right_button.texture_normal = right_image


func get_images_from_dir(path):
	var array_of_images_from_dir: Array[ImageTexture]
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print("Found file: " + dir.get_current_dir() + "/" + file_name)
			if ["png", "jpeg", "jpg"].has(file_name.get_extension()):
				var image = Image.load_from_file(dir.get_current_dir() + "/" + file_name)
				var texture := ImageTexture.create_from_image(image)
				texture.resource_name = file_name
				array_of_images_from_dir.append(texture)
			
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	images_array = array_of_images_from_dir
	winner_container.hide()
	pairs_container.show()
	set_pair_of_images()


func pop_random_image():
	return images_array.pop_at(images_array.find(images_array.pick_random()))
	
	
func give_two():
	if check_for_pairs():
		return [pop_random_image(), pop_random_image()]


func check_for_pairs() -> bool:
	if images_array.size() >= 2:
		return true
	
	return false


func _on_file_dialog_dir_dir_selected(dir):
	get_images_from_dir(dir)


func _on_file_dialog_dir_canceled():
	get_tree().quit()


func _on_button_pressed():
	file_dialog_dir.show()
