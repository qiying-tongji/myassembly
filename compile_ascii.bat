@echo off
REM 用 MSVC 生成带 C 源码对照的汇编列表 ascii.asm
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
cd /d D:\myassembly
cl /c /FAs /utf-8 ascii.c
pause
