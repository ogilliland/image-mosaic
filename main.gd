extends Control

func get_parameter(parameter):
	if OS.has_feature("JavaScript"):
		return JavaScript.eval(
			"var url_string = window.location.href;" +
			"var url = new URL(url_string);" +
			"url.searchParams.get('" + parameter + "');")
	return null

func _ready():
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
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	# Assign to the child TextureRect node
	get_node("CenterContainer/TextureRect").texture = texture
