Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\ScriptLimpeza\LimpezaPro.ps1""", 0
Set WinScriptHost = Nothing