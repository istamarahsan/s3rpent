extends Control

signal submit(name: String)

func _on_submit_button_button_up():
	_process_name_input($LineEdit.text)

func _on_line_edit_text_submitted(new_text):
	_process_name_input($LineEdit.text)

func _process_name_input(name: String):
	submit.emit(name)
