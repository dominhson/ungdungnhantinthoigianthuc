@echo off
REM Script to export all PlantUML diagrams to multiple formats (Windows)
REM Usage: export_diagrams.bat

echo Starting PlantUML diagram export...
echo.

REM Create export directories
if not exist "..\exports\png" mkdir "..\exports\png"
if not exist "..\exports\svg" mkdir "..\exports\svg"
if not exist "..\exports\pdf" mkdir "..\exports\pdf"

REM Check if plantuml is installed
where plantuml >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo PlantUML is not installed!
    echo.
    echo Install PlantUML:
    echo   Windows: choco install plantuml
    echo   Or download from: https://plantuml.com/download
    echo.
    pause
    exit /b 1
)

REM Export to PNG
echo Exporting to PNG...
plantuml -tpng *.puml -o ..\exports\png\
if %ERRORLEVEL% EQU 0 (
    echo PNG export completed!
) else (
    echo PNG export failed!
)
echo.

REM Export to SVG
echo Exporting to SVG...
plantuml -tsvg *.puml -o ..\exports\svg\
if %ERRORLEVEL% EQU 0 (
    echo SVG export completed!
) else (
    echo SVG export failed!
)
echo.

REM Export to PDF
echo Exporting to PDF...
plantuml -tpdf *.puml -o ..\exports\pdf\
if %ERRORLEVEL% EQU 0 (
    echo PDF export completed!
) else (
    echo PDF export failed (may require additional dependencies)
)
echo.

echo Export completed!
echo Files saved to: docs\exports\
echo.

dir /B ..\exports\png\*.png 2>nul
dir /B ..\exports\svg\*.svg 2>nul
dir /B ..\exports\pdf\*.pdf 2>nul

pause
