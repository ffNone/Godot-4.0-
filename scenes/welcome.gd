
extends Node2D
var data
var path = "user://save.save"
var path2 = "user://scene.save"  
var email
var password

func load_game():
	
	var file = FileAccess.open("user://save.save",FileAccess.READ) 
	var json_str = file.get_as_text()
	var json = JSON.new()
	var data = json.parse_string(json_str)
	email = data["email"]
	password = data["password"]
	file.close()
var scene = null
var file
@onready var firestore_collection : FirestoreCollection = Firebase.Firestore.collection('userdata')
func _enter_tree():
	$OK.visible = false 
	$username.editable = false
	load_game()
	$OptionButton.add_item("White",0)
	$OptionButton.add_item("Green",1)
	$OptionButton.add_item("Red",2)
var names: Array = []
var color 

func get_list(): 
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection("userdata")
	var documents =await Firebase.Firestore.list('userdata').listed_documents
	for doc in documents:
		var list = doc.doc_fields.name
		print(list)
		names.append(list)
func user_name(): 
	firestore_collection.get(email)
	var document : FirestoreDocument = await firestore_collection.get_document
	username = document.doc_fields.name
	$username.text = str(username)
#var color = "" 
#for doc in documents:
#		names.append(doc.doc_fields.name)
#	print(names)
func get_colorr():
	firestore_collection.get_doc(email)
	var document : FirestoreDocument = await firestore_collection.get_document
	var color_str = document.doc_fields.color_rect
	var selected = document.doc_fields.button_option
	$OptionButton.select(int(selected))
	var color = Color(color_str)
	$ColorRect2.color = color
	print(document)
func update():
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection('userdata')
	var up_task : FirestoreTask = firestore_collection.update(email, {'name':$username.text})
	var document : FirestoreDocument = await up_task.task_finished

func update_color():
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection('userdata')
	var up_task : FirestoreTask = firestore_collection.update(email, {'color_rect' : $ColorRect2.color.to_html(), "button_option": $OptionButton.selected})
	var document : FirestoreDocument = await up_task.task_finished
	
func _on_ok_button_up():
	if $username.text in names :
		var x = Label.new()
		x.text = "Username Already Exists!"
		add_child(x)
		await get_tree().create_timer(1.1).timeout
		remove_child(x)
	else :
		update() 
		$username.editable = false
		$OK.disabled = true
 
	

	
 
var username
func _ready():
	load_game()
	await get_tree().create_timer(2).timeout



	Firebase.Auth.login_with_email_and_password(email,password)
	Firebase.Auth.login_succeeded.connect(_on_FirebaseAuth_login_succeeded)
	Firebase.Auth.login_failed.connect(_on_FirebaseAuth_login_failed)

	user_name()
	get_colorr()
	get_list()
	await get_tree().create_timer(2).timeout
	$username.text = str(username)

	if $username.text == "" or $username.text == "username" :
		$username.editable = true
		$OK.visible = true
	else :
		$OK.visible = false 
		$username.editable = false
func _on_FirebaseAuth_login_failed(code,message):
	print(str(code) + " " + str(message))
func _on_FirebaseAuth_login_succeeded(auth_info):
	print("Success!")
	Firebase.Auth.save_auth(auth_info)


func _on_option_button_item_selected(index):
	if index == 0 :
		$ColorRect2.color = Color.AQUA
	elif index == 1 :
		$ColorRect2.color = Color.GREEN
	elif index == 2 :
		$ColorRect2.color = Color.RED
	update_color()


func _on_quit_button_up():
	get_tree().change_scene_to_file("res://Control.tscn")
