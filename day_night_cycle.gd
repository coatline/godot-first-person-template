extends Node
class_name DayNightCycle

@export var sun: DirectionalLight3D
@export var world_environment: WorldEnvironment

@export var day_sky_top: Color = Color(0, 0.6217813, 0.9090536, 1)
@export var day_sky_horizon: Color = Color(0.7472643, 0.8484838, 0.9227059, 1)
@export var night_sky_top: Color = Color(0.02, 0.03, 0.09, 1)
@export var night_sky_horizon: Color = Color(0.06, 0.07, 0.14, 1)

@export var day_sun_energy: float = 1.2
@export var night_sun_energy: float = 0.0
@export var day_ambient_energy: float = 1.0
@export var night_ambient_energy: float = 0.12
@export var max_sun_elevation: float = 60.0
@export var sunrise_time: float = 6.5
@export var sunset_time: float = 20.0

@export var sunset_color: Color = Color(1.0, 0.55, 0.3, 1.0)
@export var sunset_horizon_amount: float = 0.65
@export var sunset_top_amount: float = 0.25
@export var sunset_energy_floor: float = 0.7
@export var sunset_range_degrees: float = 22.0

@export var stars_material: ShaderMaterial
@export var moon_light: DirectionalLight3D
@export var moon_mesh: Sprite3D

@export var moon_light_energy: float = 0.35
@export var moon_light_color: Color = Color(0.7, 0.8, 1.0, 1.0)
@export var moon_distance: float = 2000.0
@export var moon_fade_range_degrees: float = 15.0

var sky: ProceduralSkyMaterial

func _ready() -> void:
	sky = world_environment.environment.sky.sky_material

func _process(_delta: float) -> void:
	var t: float = TimeManager.I.get_day_completion_percentage()
	# Day arc: horizon at sunrise, apex at midday, back at horizon at sunset.
	# Night arc mirrors it below the horizon, phase-wrapped so it stays
	# continuous across midnight (no elevation snap when the day wraps).
	var t_sunrise: float = sunrise_time / 24.0
	var t_sunset: float = sunset_time / 24.0
	var day_len: float = t_sunset - t_sunrise
	var night_len: float = 1.0 + t_sunrise - t_sunset
	var elevation: float
	if t >= t_sunrise and t < t_sunset:
		var u: float = (t - t_sunrise) / day_len
		elevation = max_sun_elevation * sin(u * PI)
	else:
		var u_night: float = (t - t_sunset + 1.0) if t < t_sunrise else (t - t_sunset)
		elevation = -max_sun_elevation * sin((u_night / night_len) * PI)
	var day_factor: float = clampf((elevation + 15.0) / 50.0, 0.0, 1.0)
	var night_factor: float = 1.0 - day_factor

	sun.rotation_degrees.x = -elevation

	# Sunset glow: symmetric around the horizon (fades as the sun rises AND lingers
	# briefly as an afterglow once it dips below), smoothed with a smoothstep ease.
	var glow: float = 1.0 - abs(elevation) / sunset_range_degrees
	var sunset_factor: float = clampf(glow, 0.0, 1.0)
	sunset_factor = sunset_factor * sunset_factor * (3.0 - 2.0 * sunset_factor)

	sun.light_color = Color.WHITE.lerp(sunset_color, sunset_factor)
	sun.light_energy = lerpf(night_sun_energy, day_sun_energy * lerpf(1.0, sunset_energy_floor, sunset_factor), day_factor)
	sky.energy_multiplier = lerpf(night_ambient_energy, day_ambient_energy, day_factor)
	sky.sky_top_color = day_sky_top.lerp(night_sky_top, night_factor).lerp(sunset_color, sunset_factor * sunset_top_amount)
	sky.sky_horizon_color = day_sky_horizon.lerp(night_sky_horizon, night_factor).lerp(sunset_color, sunset_factor * sunset_horizon_amount)

	# Moon mirrors the sun: it climbs as the sun dips below the horizon and fades
	# back out as morning approaches.
	var moon_elev: float = -elevation
	var moon_visibility: float = clampf(moon_elev / moon_fade_range_degrees, 0.0, 1.0)
	moon_light.rotation_degrees.x = -moon_elev
	moon_light.light_color = moon_light_color
	moon_light.light_energy = moon_light_energy * moon_visibility
	moon_mesh.modulate.a = moon_visibility

	# Moon orbits the world origin at a far distance so it reads as part of the
	# fixed sky (no parallax from walking, no apparent size change).
	moon_mesh.global_position = Vector3(0.0, sin(deg_to_rad(moon_elev)), cos(deg_to_rad(moon_elev))) * moon_distance

	if stars_material:
		stars_material.set_shader_parameter("night_factor", night_factor)
