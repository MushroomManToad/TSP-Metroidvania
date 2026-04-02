class_name Runtime_State_Handler

extends Node

## SET THIS VARIABLE TO AFFECT HOW THE GAME LAUNCHES
var run_mode : RunMode = RunMode.QUICKSTART

func _on_ready():
	match run_mode:
		RunMode.QUICKSTART_0:
			pass
		RunMode.QUICKSTART:
			GameManager.LevelManager.load_scene("dev/demo_stage", Vector2(0.0, 26.0))
		RunMode.TITLE:
			pass

enum RunMode {
	QUICKSTART_0,
	QUICKSTART,
	TITLE,
}
