extends Control

var image_size: Vector2
var pixel_size

func get_parameter(parameter):
	if OS.has_feature("JavaScript"):
		return JavaScript.eval(
			"var url_string = window.location.href;" +
			"var url = new URL(url_string);" +
			"url.searchParams.get('" + parameter + "');")
	return null

func _ready():
	# Trigger resize() function when window is resized
	get_tree().get_root().connect("size_changed", self, "resize")
	
	var url = get_parameter("url")
	if url == null:
		url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Mona_Lisa.jpg/396px-Mona_Lisa.jpg"
	
	# Create an HTTP request node and connect its completion signal
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	
	# Perform the HTTP request. The URL below returns a PNG image as of writing
#	var http_error = http_request.request("https://via.placeholder.com/500")
	var http_error = http_request.request(url)
	if http_error != OK:
		print("An error occurred in the HTTP request")
	
	# Update pixel shader
	pixel_size = get_parameter("pixel-size")
	if pixel_size == null:
		pixel_size = 20.0
	pixel_size = clamp(float(pixel_size), 4.0, 100.0)
	get_node("ColorRect").material.set_shader_param("pixel_size", pixel_size)

# Called when the HTTP request is completed
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var format = get_parameter("format")
	if format == null:
		format = "jpg"
	var image_error
	match format:
		"jpg", "jpeg":
			image_error = image.load_jpg_from_buffer(body)
		"bmp":
			image_error = image.load_bmp_from_buffer(body)
		"tga":
			image_error = image.load_tga_from_buffer(body)
		"webp":
			image_error = image.load_webp_from_buffer(body)
		_, "png":
			image_error = image.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image")
	
	image_size = image.get_size()
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	# Assign to the child TextureRect node
	get_node("CenterContainer/TextureRect").texture = texture
	resize()

func resize():
	var size = rect_size
	var scale = size / image_size
	var object_fit = get_parameter("object-fit")
	if object_fit == null:
		object_fit = "cover"
	match object_fit:
		"contain":
			scale = min(scale.x, scale.y)
		_, "cover":
			scale = max(scale.x, scale.y)
	var texture_rect = get_node("CenterContainer/TextureRect")
	texture_rect.rect_min_size = image_size * scale
	texture_rect.rect_size = texture_rect.rect_min_size
	
	var num_pixels = Vector2(
		floor(size.x / pixel_size),
		floor(size.y / pixel_size)
	)
	var delta = size - num_pixels * pixel_size
	get_node("ColorRect").material.set_shader_param("border", 0.5 * delta)
