@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title LEGACY PACK DEPLOY

set "REPO_DIR=%USERPROFILE%\Downloads\Legacy-Party-Pack"
set "SERVER_DIR=%USERPROFILE%\Downloads\26.2-199"
set "REPO_URL=https://github.com/yoonsin6919689-alt/-.git"

echo ==========================================
echo   LEGACY PACK DEPLOY (업로드 없이 적용만)
echo ==========================================
echo.

if not exist "%REPO_DIR%" mkdir "%REPO_DIR%"
if not exist "%REPO_DIR%\.git" git -C "%REPO_DIR%" init
git -C "%REPO_DIR%" remote get-url origin >nul 2>&1
if errorlevel 1 git -C "%REPO_DIR%" remote add origin "%REPO_URL%"
git -C "%REPO_DIR%" fetch origin main
git -C "%REPO_DIR%" reset --hard origin/main
if errorlevel 1 goto fail

powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO_DIR%\deploy-legacy-pack.ps1" -RepoDir "%REPO_DIR%" -ServerDir "%SERVER_DIR%"
if errorlevel 1 goto fail

echo.
echo 완료 - 서버를 재시작하세요.
pause
exit /b 0

:fail
echo.
echo [ERROR] 작업 실패
pause
exit /b 1
