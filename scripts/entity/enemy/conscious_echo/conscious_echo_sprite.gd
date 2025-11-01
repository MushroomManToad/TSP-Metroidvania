extends AbstractAnimator

const IDLE : String = "idle"
const WALK : String = "walk"
const ATTACK : String = "attack"
const TURN : String = "turn"

### SECTION FOR ANIMATOR DATA ###
func queue_idle() -> void:
	flags["idle"].set_active()
func queue_walk() -> void:
	flags["walk"].set_active()
func queue_attack() -> void:
	flags["attack"].set_active()
func queue_turn() -> void:
	flags["turn"].set_active()

var ref := self

func register_states():
	## Register Flags before States
	flags.get_or_add("idle", AnimationFlag.new())
	flags.get_or_add("walk", AnimationFlag.new())
	flags.get_or_add("attack", AnimationFlag.new())
	flags.get_or_add("turn", AnimationFlag.new())
	
	## Register States
	animation_states.get_or_add(IDLE, \
		AnimState.new([IDLE], [
				AnimState.Transition.new(
					TURN, 
					func() :  return flags["turn"].active),
				AnimState.Transition.new(
					IDLE, 
					func() : return flags["idle"].active),
				AnimState.Transition.new(
					WALK, 
					func() : return flags["walk"].active),
				AnimState.Transition.new(
					ATTACK, 
					func() :  return flags["attack"].active)
		]))
	animation_states.get_or_add(WALK, \
		AnimState.new([WALK], [
				AnimState.Transition.new(
					TURN, 
					func() :  return flags["turn"].active),
				AnimState.Transition.new(
					IDLE, 
					func() : return flags["idle"].active),
				AnimState.Transition.new(
					WALK, 
					func() : return flags["walk"].active),
				AnimState.Transition.new(
					ATTACK, 
					func() :  return flags["attack"].active)
		]))
	animation_states.get_or_add(ATTACK, \
		AnimState.new([ATTACK],[
				AnimState.Transition.new(
					TURN, 
					func() :  return flags["turn"].active),
				AnimState.Transition.new(
					IDLE, 
					func() : return flags["idle"].active),
				AnimState.Transition.new(
					WALK, 
					func() : return flags["walk"].active),
				AnimState.Transition.new(
					ATTACK, 
					func() :  return flags["attack"].active)
		]))
	animation_states.get_or_add(TURN, \
		AnimState.new([TURN],[
				AnimState.Transition.new(
					TURN, 
					func() :  return flags["turn"].active),
				AnimState.Transition.new(
					IDLE, 
					func() : return flags["idle"].active),
				AnimState.Transition.new(
					WALK, 
					func() : return flags["walk"].active),
				AnimState.Transition.new(
					ATTACK, 
					func() :  return flags["attack"].active)
		]))
	pass

func get_default_state() -> String:
	return IDLE

func read_in_state():
	pass

func post_process():
	pass
