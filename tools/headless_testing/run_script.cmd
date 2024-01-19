set WORKING_DIR=C:\Users\Josh\Documents\IdeaProjects\BAR_headless
set SCRIPT_PATH=%cd%\%1
cd /d %WORKING_DIR%
rmdir /s /q "%WORKING_DIR%\LuaUI\Config"
"%WORKING_DIR%\engine\105.1.1-2240-gd01542d bar\spring-headless" --isolation --write-dir %WORKING_DIR% "%SCRIPT_PATH%"