extends CanvasLayer

func level(num):
	$CurrentLevel.text = "Level: " + str(num)
	
func score(num):
	$Score.text = "Score: " + str(num)
	
func health(num):
	$Health.text = "Health: " + str(num)
