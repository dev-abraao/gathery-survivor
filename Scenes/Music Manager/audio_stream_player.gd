extends AudioStreamPlayer

func _ready():
    print("🎵 Music Manager carregando...")

    process_mode = Node.PROCESS_MODE_ALWAYS
    var music_path = "res://Audio/Music/castle_crashers_theme.ogg"
    var music_file = load(music_path)
    
    if music_file:
        print("✅ Arquivo de música encontrado!")
        stream = music_file
        stream.loop = true
        print("✅ Loop configurado!")

        volume_db = -20.0
        autoplay = true

        play()
        print("✅ Música iniciada! Playing:", playing)
    else:
        print("❌ Arquivo de música NÃO encontrado em:", music_path)
        print("❌ Verifique se o arquivo existe na pasta Audio/Music/")

func _process(delta):
    if Engine.get_process_frames() % 300 == 0:
        if stream:
            print("🎵 Status - Playing:", playing, "| Position:", snappedf(get_playback_position(), 1), "s | Volume:", volume_db, "dB")
        else:
            print("❌ Nenhum stream carregado!")

func start_music():
    if stream:
        play()
        print("▶️ Música iniciada")
    else:
        print("❌ Não há música para tocar")

func stop_music():
    stop()
    print("⏹️ Música parada")

func pause_music():
    stream_paused = !stream_paused
    print("⏸️ Música pausada:", stream_paused)

func set_music_volume(volume: float):
    volume_db = linear_to_db(volume)
    print("🔊 Volume alterado para:", volume_db, "dB")

func fade_in(duration: float = 2.0):
    volume_db = -80.0 
    play()
    var tween = create_tween()
    tween.tween_property(self, "volume_db", -5.0, duration)
    print("🔄 Fade in iniciado")

func fade_out(duration: float = 1.0):
    var tween = create_tween()
    tween.tween_property(self, "volume_db", -80.0, duration)
    tween.tween_callback(stop)
    print("🔄 Fade out iniciado")