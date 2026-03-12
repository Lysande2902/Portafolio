# Script mejorado - Descargar música de fuentes públicas alternativas
Write-Host "🎵 Descargando música de terror desde repositorios públicos..." -ForegroundColor Cyan

$musicDir = "humano\assets\music"
$soundsDir = "humano\assets\sounds"
$envyDir = "humano\assets\sounds\envy"

# Crear carpeta de Envidia
if (-not (Test-Path $envyDir)) {
    New-Item -ItemType Directory -Path $envyDir -Force | Out-Null
}

# Archivos de dominio público (GitHub, Archive.org)
$downloads = @(
    @{
        # Dark Ambient Loop - CC0
        Url = "https://github.com/KellyPared/game-assets-horror/raw/main/audio/dark_ambient_loop.mp3"
        Destination = "$musicDir\envy_ambience.mp3"
        Description = "Ambient oscuro para Envidia"
    },
    @{
        # Horror Drone - CC0
        Url = "https://github.com/Free-Game-Assets/music-horror/raw/master/horror_drone.mp3"
        Destination = "$musicDir\horror_drone.mp3"
        Description = "Drone de horror general"
    },
    @{
        # Glass Break Sound Effect - Public Domain
        Url = "https://archive.org/download/GlassBreak/glass-break-sound.mp3"
        Destination = "$envyDir\mirror_shatter.mp3"
        Description = "Cristal rompiéndose (Espejos)"
    },
    @{
        # Creepy Whisper Loop - CC0
        Url = "https://github.com/Horror-Game-Assets/audio/raw/main/whisper_loop.mp3"
        Destination = "$envyDir\whispers.mp3"
        Description = "Susurros para Envidia"
    }
)

$successCount = 0
foreach ($item in $downloads) {
    Write-Host "`n⬇️  Descargando: $($item.Description)" -ForegroundColor Yellow
    
    try {
        Invoke-WebRequest -Uri $item.Url -OutFile $item.Destination -ErrorAction Stop
        Write-Host "   ✅ OK: $($item.Destination)" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "   ⚠️  No disponible (intentar manualmente)" -ForegroundColor DarkYellow
    }
}

Write-Host "`n🎉 Proceso completado: $successCount/$($downloads.Count) archivos descargados" -ForegroundColor Cyan

if ($successCount -eq 0) {
    Write-Host "`n💡 ALTERNATIVA:" -ForegroundColor Yellow
    Write-Host "Visita estos sitios para descargar música gratuita manualmente:" -ForegroundColor White
    Write-Host "  • https://incompetech.com/music/royalty-free/ (Horror/Dark)" -ForegroundColor Gray
    Write-Host "  • https://freesound.org/ (Efectos de sonido)" -ForegroundColor Gray
    Write-Host "  • https://opengameart.org/ (Assets de juegos)" -ForegroundColor Gray
}
