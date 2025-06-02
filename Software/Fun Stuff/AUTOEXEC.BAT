@ECHO OFF
CLS
ECHO MiniCamel DOS Working Environment - V1.00
ECHO Copyright(C) Matt Schultz aka 'SnipE'- 2025
ECHO.
CHOICE /C:YN /T:Y,3 >NUL
ECHO Initializing system...
CHOICE /C:YN /T:Y,3 >NUL
ECHO Loading system drivers...
ECHO.
ECHO SET BLASTER=A220 I5 D1 T4 P330
ECHO.
C:\DRIVERS\MOUSE\CTM20A4\CTMOUSE.EXE
ECHO.
REM unisound /vf99 /vc99 /vl99 /XOFi
ECHO.
C:\DOS\SMARTDRV.EXE /X
CHOICE /C:YN /T:Y,1 >NUL
ECHO Loading environmental variables...
CHOICE /C:YN /T:Y,3 >NUL
PROMPT $e[1;31m$p$g$e[0m
PATH %PATH%;C:\WATCOM\BINW;C:\DOS
SET INCLUDE=C:\WATCOM\H
SET WATCOM=C:\WATCOM
SET EDPATH=C:\WATCOM\EDDAT
SET WIPFC=C:\WATCOM\WIPFC
CHOICE /C:YN /T:Y,1 >NUL
CLS
ECHO System ready. Enjoy!

