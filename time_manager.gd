extends Node
class_name TimeManager

static var I: TimeManager

const SECONDS_PER_MINUTE = 60
const MINUTES_PER_HOUR = 60
const HOURS_PER_DAY = 24
const MINUTES_PER_DAY = HOURS_PER_DAY * MINUTES_PER_HOUR
const SECONDS_PER_HOUR = MINUTES_PER_HOUR * SECONDS_PER_MINUTE
const SECONDS_PER_DAY = HOURS_PER_DAY * SECONDS_PER_HOUR

@export var real_minutes_per_day: float = 20.0
@export var start_day: int = 0
@export_range(0, 23) var start_hour: int = 8
@export_range(0, 59) var start_minute: int = 0

signal time_scale_changed(new_scale)
signal minute_passed(last_minute)

var time_scale: float = 1.0

# Total seconds passed since Day 0, 00:00:00
var total_seconds: float = 0.0
var total_minutes: float = 0.0
var real_seconds_to_game_seconds: float
var real_seconds_to_game_minutes: float
var real_seconds_to_game_hours: float

var last_whole_minute: int = 0

func _enter_tree() -> void:
	I = self
	
	real_seconds_to_game_seconds = SECONDS_PER_DAY / (real_minutes_per_day * SECONDS_PER_MINUTE)
	real_seconds_to_game_minutes = real_seconds_to_game_seconds / SECONDS_PER_MINUTE
	real_seconds_to_game_hours = real_seconds_to_game_minutes / MINUTES_PER_HOUR
	load_default_time()

func load_default_time():
	set_time(start_day, start_hour, start_minute)

func _process(delta: float) -> void:
	var scaled_delta = delta * time_scale
	total_seconds += scaled_delta * real_seconds_to_game_seconds
	total_minutes += scaled_delta * real_seconds_to_game_minutes

	var new_minute = floori(total_minutes)
	if  new_minute > last_whole_minute:
		last_whole_minute = floori(total_minutes)
		minute_passed.emit(last_whole_minute)

func get_save_data() -> Dictionary:
	return {"type_id": "time", "total_seconds": total_seconds}

func load_save_data(save_data: Dictionary):
	total_seconds = save_data["total_seconds"]
	total_minutes = total_seconds / TimeManager.I.SECONDS_PER_MINUTE
	last_whole_minute = floori(total_minutes)

func set_time(target_day: int, target_hour: int, target_minute: int) -> void:
	total_seconds = (target_day * SECONDS_PER_DAY) + \
					(target_hour * SECONDS_PER_HOUR) + \
					(target_minute * SECONDS_PER_MINUTE)
	total_minutes = total_seconds / TimeManager.I.SECONDS_PER_MINUTE
	last_whole_minute = floori(total_minutes)

func set_time_scale(new_scale: float) -> void:
	time_scale = max(0.0, new_scale)
	time_scale_changed.emit(time_scale)

func get_game_seconds_per_second() -> float:
	return real_seconds_to_game_seconds * time_scale

func get_game_minutes_per_second() -> float:
	return real_seconds_to_game_minutes * time_scale

func get_game_hours_per_second() -> float:
	return real_seconds_to_game_hours * time_scale

func get_day() -> int:
	return int(total_seconds / SECONDS_PER_DAY)

func get_hour() -> int:
	return int(fmod(total_seconds, SECONDS_PER_DAY) / SECONDS_PER_HOUR)

func get_minute() -> int:
	return int(fmod(total_seconds, SECONDS_PER_HOUR) / SECONDS_PER_MINUTE)

func get_day_completion_percentage() -> float:
	return fmod(total_seconds, SECONDS_PER_DAY) / SECONDS_PER_DAY

func get_time_string() -> String:
	var h = get_hour()
	var m = get_minute()
	var am_pm = "AM" if h < 12 else "PM"
	var display_hour = h % 12
	if display_hour == 0: display_hour = 12
	
	return "Day %d - %d:%02d %s" % [get_day(), display_hour, m, am_pm]
