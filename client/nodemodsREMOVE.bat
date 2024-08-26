@ECHO OFF

:choice
set /P c=Are you sure you want to delete node_modules[Y/N]?
if /I "%c%" EQU "Y" goto :deletenode
if /I "%c%" EQU "N" goto :doexit
goto :choice


:deletenode

mkdir empty
robocopy empty node_modules /s /mir
rmdir empty
rmdir node_modules

echo "node_modules folder deleted."

cmd /k



:doexit

echo "node_modules folder NOT deleted."
cmd /k

