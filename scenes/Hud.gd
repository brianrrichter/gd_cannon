extends CanvasLayer

func _ready():
	$Message.hide()

func show_message(text):
	$Message.text = text
	$AnimationPlayer.play("show_message")

func set_score(name1, score1, name2, score2):
	$ScoreLabel.text = str(name1, ': ', score1, '\n', name2, ': ', score2)
