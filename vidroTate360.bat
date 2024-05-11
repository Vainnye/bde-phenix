@echo off

Setlocal EnableDelayedExpansion


ECHO "      .__    .___             ___________       __           ________   _______________   "
ECHO "___  _|__| __| _/ _______  ___\__    ___/____ _/  |_  ____   \_____  \ /  _____/\   _  \  "
ECHO "\  \/ /  |/ __ |  \_  __ \/  _ \|    |  \__  \\   __\/ __ \    _(__  </   __  \ /  /_\  \ "
ECHO " \   /|  / /_/ |   |  | \(  <_> )    |   / __ \|  | \  ___/   /       \  |__\  \\  \_/   \"
ECHO "  \_/ |__\____ |   |__|   \____/|____|  (____  /__|  \___  > /______  /\_____  / \_____  /"
ECHO "              \/                             \/          \/         \/       \/        \/ "
ECHO -----------------------------------
ECHO Auteur : Vianney Jacquemot
ECHO github : https://github.com/Vainnye
ECHO -----------------------------------
ECHO Ce script prends TOUTES les videos d'un dossier (pas de ses sous-dossiers), les tourne dans le sens choisi puis les envoie dans le dossier de destination "rotatedLeft", "rotatedRight", ou "rotated180"

:: définition du filtre (demande à l'utilisateur le filtre n'est pas passé en paramètre)
set "filtre=%1"
if [%filtre%]==[] (
    ECHO exemples : mp4 mkv mov
    SET /p "ext=entrez l'extension des videos a chercher : "
    set "filtre=*.!ext!"
)

:: choix du type de rotation (demande à l'utilisateur le type s'il n'est pas passé en paramètre)
set "rotation=%2"
if [%rotation%]==[] (
    ECHO 3 choix : -90, 90, 180 (pour tourner dans le sens anti-horaire, horaire, ou tourner de 180 degres)
    SET /p "rotation=entrez l'angle de rotation a appliquer : "
)

set count=0
ECHO TRAITEMENT EN COURS...
ECHO ^(^[q^] annule le traitement du fichier en cours et en laisse une carcasse dans le dossier de destination^)
ECHO N'APPUYER SUR AUCUNE TOUCHE POUR EVITER LES PROBLEMES

if [%rotation%]==[-90] (
    :: crée le dossier "rotatedLeft" dans le répertoire des vidéos s'il n'existe pas 
    if NOT EXIST "%~dp1rotatedLeft\" (mkdir "%~dp1rotatedLeft\")
    for %%a in (%filtre%) do (
        echo %%~nxa en cours de traitement
        call :rotateLeft "%%a"
        set /A count=%count% + 1
    )
) else (
if [%rotation%]==[90] (
    :: crée le dossier "rotatedRight" dans le répertoire des vidéos s'il n'existe pas 
    if NOT EXIST "%~dp1rotatedRight\" (mkdir "%~dp1rotatedRight\")
    for %%a in (%filtre%) do (
        echo %%~nxa en cours de traitement
        call :rotateRight "%%a"
        set /A count=%count% + 1
    )
) else (
if [%rotation%]==[180] (
    :: crée le dossier "rotated180" dans le répertoire des vidéos s'il n'existe pas 
    if NOT EXIST "%~dp1rotated180\" (mkdir "%~dp1rotated180\")
    for %%a in (%filtre%) do (
        echo %%~nxa en cours de traitement
        call :rotate180 "%%a"
        set /A count=%count% + 1
    )
)))
ECHO %count% fichier(s) traite(s)
PAUSE
exit /B



:rotateLeft
    ffmpeg -y -i %1 -v "error" -vf "transpose=2" "%~dp1rotatedLeft\%~nx1"
EXIT /B

:rotateRight
    ffmpeg -y -i %1 -v "error" -vf "transpose=1" "%~dp1rotatedRight\%~nx1"
EXIT /B

:rotate180
    ffmpeg -y -i %1 -v "error" -vf "hflip, vflip" "%~dp1rotated180\%~nx1"
EXIT /B
