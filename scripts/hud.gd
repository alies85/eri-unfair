extends CanvasLayer

func level(num):
	$CurrentLevel.text = "Level: " + str(num)
	
func score(num):
	$Score.text = "Gems: " + str(num)
