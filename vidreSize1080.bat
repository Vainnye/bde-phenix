@echo off

Setlocal EnableDelayedExpansion


ECHO "      .__    .___                  _________.__                 ___________     ______ _______   "
ECHO "___  _|__| __| _/ _______   ____  /   _____/|__|_______ ____   /_   \   _  \   /  __  \\   _  \  "
ECHO "\  \/ /  |/ __ |  \_  __ \_/ __ \ \_____  \ |  \___   // __ \   |   /  /_\  \  >      </  /_\  \ "
ECHO " \   /|  / /_/ |   |  | \/\  ___/ /        \|  |/    /\  ___/   |   \  \_/   \/   --   \  \_/   \"
ECHO "  \_/ |__\____ |   |__|    \___  >_______  /|__/_____ \\___  >  |___|\_____  /\______  /\_____  /"
ECHO "              \/               \/        \/          \/    \/              \/        \/       \/ "
ECHO -----------------------------------
ECHO Auteur : Vianney Jacquemot
ECHO github : https://github.com/Vainnye
ECHO -----------------------------------
ECHO Ce script prends TOUTES les videos d'un dossier (pas de ses sous-dossiers), les redimensionne* de facon a ce que le plus petit cote soit egal a 1080 pixels, et les copie toutes dans un dossier "resized" dans le dossier des videos
ECHO *(sauf celles qui dont le plus petit cote est ^<= 1080 pixels)



:: définition du filtre (demande à l'utilisateur le filtre n'est pas passé en paramètre)
set "filtre=%1"
if [%filtre%]==[] (
    ECHO exemples : mp4 mkv mov
    SET /p "ext=entrez l'extension des videos a chercher : "
    set "filtre=*.!ext!"
)

set count=0
ECHO TRAITEMENT EN COURS...
ECHO ^(^[q^] annule le traitement du fichier en cours et en laisse une carcasse dans le dossier de destination^)
ECHO N'APPUYER SUR AUCUNE TOUCHE POUR EVITER LES PROBLEMES

:: crée le dossier "resized" dans le répertoire des vidéos s'il n'existe pas 
if NOT EXIST "%~dp1resized\" (mkdir "%~dp1resized\")

:: resize toutes les vidéos
for %%a in (%filtre%) do (
    echo %%~nxa en cours de traitement
    call :resize "%%a"
    set /A count=%count% + 1
)
ECHO %count% fichier(s) traite(s)
PAUSE
exit /B


:: --------------------
:: FONCTIONS ci-dessous
:: --------------------



:: fonction qui prends en param %1 le chemin de la vidéo
:: et copie la vidéo dans un fichier en changeant ses dimensions
:: son plus petit côté fera 1080 pixels
:: si le plus petit côté est déjà <= 1080 pixels, elle copie la vidéo sans en  change les dimensions

:resize
FOR /F "tokens=1-3 USEBACKQ" %%a IN (`ffprobe -v "error" -select_streams "v:0" -show_entries "stream=width,height,display_aspect_ratio" -of "csv=p=0:s=' '" "test.mkv"`) DO (
    SET width=%%a
    SET height=%%b
    SET ratio=%%c
)
:: resize la vidéo si =1, sinon ne la resize pas
SET willResize=1
:: valeurs par défaut pour la nouvelle largeur et nouvelle hauteur
SET newWidth=%width%
SET newHeight=%height%
:: ratio Height & ratio Width
SET "ratioH=%ratio:*:=%"
CALL SET "ratioW=%%ratio::%ratioH%=%%"
:: Détection de l'orientation de la vidéo (portrait ou paysage)
if %width% LEQ %height% (
    SET orientation=portrait
    :: ne pas resize la vidéo si le plus petit côté est inférieur à 1080 pixels
    if %width% LEQ 1080 ( SET willResize=0 )
) else (
    SET orientation=paysage
    :: ne pas resize la vidéo si le plus petit côté est inférieur à 1080 pixels
    if %height% LEQ 1080 ( SET willResize=0 )
)
:: resize video or copy it
if %willResize% EQU 1 (
    :: calcul des dimensions de la nouvelle vidéo
    if %orientation%==portrait (
        SET newWidth=1080
        SET /A newHeight = %newWidth% / %ratioW% * %ratioH%	
    ) else (
    if %orientation%==paysage (
        SET newHeight=1080
        SET /A newWidth = %newHeight% / %ratioH% * %ratioW%
    ))
    ffmpeg -y -i %1 -vf scale="%newWidth%:%newHeight%" "%~dp1resized\%~nx1"
) else (
    copy /b/y/v %1 "%~dp1resized\%~nx1" > nul
)
:: fin de la fonction resize
EXIT /B
