extends AudioStreamPlayer

func _ready():

    process_mode = Node.PROCESS_MODE_ALWAYS
    var music_path = "res://Audio/Music/castle_crashers_theme.ogg"
    var music_file = load(music_path)
    
    if music_file:
        stream = music_file
        stream.loop = true
        volume_db = -20.0
        autoplay = true
        play()

func start_music():
    if stream:
        play()

func stop_music():
    stop()

func pause_music():
    stream_paused = !stream_paused

func set_music_volume(volume: float):
    volume_db = linear_to_db(volume)

func fade_in(duration: float = 2.0):
    volume_db = -80.0 
    play()
    var tween = create_tween()
    tween.tween_property(self, "volume_db", -5.0, duration)

func fade_out(duration: float = 1.0):
    var tween = create_tween()
    tween.tween_property(self, "volume_db", -80.0, duration)
    tween.tween_callback(stop)
