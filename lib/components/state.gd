@abstract 
class_name State
extends Node

@abstract func process_frame(delta: float) -> void
@abstract func start(prev: State) -> void
