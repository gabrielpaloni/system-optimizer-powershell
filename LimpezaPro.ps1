# --- AUTO-ELEVATE TO ADMIN (Silent) ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- CONFIGURATION ---
$pastaBase = "C:\ScriptLimpeza"
$arquivoData = "$pastaBase\ultima_limpeza.txt"
$arquivoLog  = "$pastaBase\historico_limpeza.log"
$diasIntervalo = 10
# ---------------------

# --- MAGIC PARA ARRASTAR JANELA SEM BORDA ---
$code = @"
    [DllImport("user32.dll")] public static extern bool ReleaseCapture();
    [DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
"@
$win32 = Add-Type -MemberDefinition $code -Name "Win32" -Namespace Win32 -PassThru

# Verifica Data
$devePerguntar = $true
if (Test-Path $arquivoData) {
    $ultimaData = Get-Content $arquivoData
    $dataSalva = [DateTime]::Parse($ultimaData)
    $diferenca = (Get-Date) - $dataSalva
    if ($diferenca.Days -lt $diasIntervalo) { $devePerguntar = $false }
}

# -----------------------------------------------------------
# ADICIONE O '#' ABAIXO PARA ATIVAR O MODO TESTE
if (-not $devePerguntar) { exit }
# -----------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Media.SystemSounds]::Asterisk.Play()

# === ESTILO VISUAL SIMÉTRICO V5 (Slow + Log Pro) ===
$corFundo       = "#1E1E1E"
$corHeader      = "#252526"
$corAccent      = "#0078D7"
$corAccentHover = "#1C97EA"
$corTextoMain   = "#FFFFFF"
$corTextoDesc   = "#BBBBBB"
$corBtnGray     = "#333333"
$corBtnGrayHover= "#444444"
$corSucesso     = "#28a745"

# FONTS
$fontTitle = New-Object System.Drawing.Font("Segoe UI Semibold", 11)
$fontMain  = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Regular)
$fontDesc  = New-Object System.Drawing.Font("Segoe UI", 10.5)
$fontBtn   = New-Object System.Drawing.Font("Segoe UI Bold", 10)
$fontClose = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)

# 1. FORM SETUP
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Optimizer"
$form.Size = New-Object System.Drawing.Size(520, 360)
$form.StartPosition = "CenterScreen"
$form.BackColor = $corFundo
$form.FormBorderStyle = "None"
$form.TopMost = $true 

# 2. HEADER PANEL
$header = New-Object System.Windows.Forms.Panel
$header.Size = New-Object System.Drawing.Size(520, 45)
$header.Location = New-Object System.Drawing.Point(0, 0)
$header.BackColor = $corHeader
$form.Controls.Add($header)

$header.Add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $win32::ReleaseCapture()
        $win32::SendMessage($form.Handle, 0xA1, 2, 0)
    }
})

$titleIcon = New-Object System.Windows.Forms.Label
$titleIcon.Text = "SYSTEM OPTIMIZER"
$titleIcon.Font = $fontTitle
$titleIcon.ForeColor = $corAccent
$titleIcon.Location = New-Object System.Drawing.Point(20, 12)
$titleIcon.AutoSize = $true
$header.Controls.Add($titleIcon)

$btnCloseX = New-Object System.Windows.Forms.Label
$btnCloseX.Text = "X"
$btnCloseX.Font = $fontClose
$btnCloseX.ForeColor = "#888888"
$btnCloseX.Location = New-Object System.Drawing.Point(480, 10)
$btnCloseX.Size = New-Object System.Drawing.Size(30, 30)
$btnCloseX.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnCloseX.Add_Click({ $form.Close() })
$btnCloseX.Add_MouseEnter({ $btnCloseX.ForeColor = "#FF5555" })
$btnCloseX.Add_MouseLeave({ $btnCloseX.ForeColor = "#888888" })
$header.Controls.Add($btnCloseX)

$linePanel = New-Object System.Windows.Forms.Panel
$linePanel.Size = New-Object System.Drawing.Size(520, 2)
$linePanel.Location = New-Object System.Drawing.Point(0, 45)
$linePanel.BackColor = $corAccent
$form.Controls.Add($linePanel)

# 3. CONTEÚDO CENTRAL
$panelContent = New-Object System.Windows.Forms.Panel
$panelContent.Location = New-Object System.Drawing.Point(40, 70)
$panelContent.Size = New-Object System.Drawing.Size(440, 180)
$form.Controls.Add($panelContent)

$lblMain = New-Object System.Windows.Forms.Label
$lblMain.Text = "Maintenance Required"
$lblMain.Dock = "Top"
$lblMain.TextAlign = "MiddleCenter"
$lblMain.Height = 40
$lblMain.ForeColor = $corTextoMain
$lblMain.Font = $fontMain
$panelContent.Controls.Add($lblMain)

$lblDesc = New-Object System.Windows.Forms.Label
$lblDesc.Text = "Your system needs a periodic cleanup to maintain performance.`nTargets: Temp Files, Cache, and Recycle Bin."
$lblDesc.Dock = "Top"
$lblDesc.TextAlign = "MiddleCenter"
$lblDesc.Height = 60
$lblDesc.ForeColor = $corTextoDesc
$lblDesc.Font = $fontDesc
$panelContent.Controls.Add($lblDesc)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "" 
$lblStatus.Dock = "Bottom"
$lblStatus.TextAlign = "MiddleCenter"
$lblStatus.Height = 30
$lblStatus.ForeColor = $corAccent
$lblStatus.Font = $fontDesc
$panelContent.Controls.Add($lblStatus)

# Barra de Progresso
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(40, 260)
$progressBar.Size = New-Object System.Drawing.Size(440, 15)
$progressBar.Style = "Continuous"
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

# 4. BOTÕES (SIMÉTRICOS)
$btnPanel = New-Object System.Windows.Forms.Panel
$btnPanel.Location = New-Object System.Drawing.Point(0, 290)
$btnPanel.Size = New-Object System.Drawing.Size(520, 50)
$form.Controls.Add($btnPanel)

# Botão 1
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "OPTIMIZE NOW"
$btnRun.Size = New-Object System.Drawing.Size(170, 45)
$btnRun.Location = New-Object System.Drawing.Point(80, 0) 
$btnRun.BackColor = $corAccent
$btnRun.ForeColor = "White"
$btnRun.FlatStyle = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Font = $fontBtn
$btnRun.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnRun.Add_MouseEnter({ if($btnRun.Enabled){$btnRun.BackColor = $corAccentHover} })
$btnRun.Add_MouseLeave({ if($btnRun.Enabled){$btnRun.BackColor = $corAccent} })
$btnPanel.Controls.Add($btnRun)

# Botão 2
$btnSkip = New-Object System.Windows.Forms.Button
$btnSkip.Text = "LATER"
$btnSkip.Size = New-Object System.Drawing.Size(170, 45)
$btnSkip.Location = New-Object System.Drawing.Point(270, 0)
$btnSkip.BackColor = $corBtnGray
$btnSkip.ForeColor = $corTextoDesc
$btnSkip.FlatStyle = "Flat"
$btnSkip.FlatAppearance.BorderSize = 0
$btnSkip.Font = $fontBtn
$btnSkip.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnSkip.Add_MouseEnter({ $btnSkip.BackColor = $corBtnGrayHover; $btnSkip.ForeColor = "White" })
$btnSkip.Add_MouseLeave({ $btnSkip.BackColor = $corBtnGray; $btnSkip.ForeColor = $corTextoDesc })
$btnPanel.Controls.Add($btnSkip)

# --- LOGIC ---
$form.Add_FormClosing({ if ($form.DialogResult -eq [System.Windows.Forms.DialogResult]::None) { $form.Dispose() } })
$btnSkip.Add_Click({ $form.Close() })

$btnRun.Add_Click({
    if ($btnRun.Text -eq "CLOSE") { $form.Close(); return }

    # UI State
    $form.TopMost = $false
    $btnRun.Enabled = $false
    $btnSkip.Visible = $false
    $btnRun.Text = "PROCESSING..."
    $btnRun.BackColor = $corBtnGrayHover
    
    # Move para o centro
    $btnRun.Location = New-Object System.Drawing.Point(175, 0)
    
    $progressBar.Visible = $true
    $lblStatus.ForeColor = $corTextoDesc
    
    # Init Logs Arrays
    $listActions = New-Object System.Collections.Generic.List[string]
    $listDeleted = New-Object System.Collections.Generic.List[string]
    $listLocked  = New-Object System.Collections.Generic.List[string]

    # 1. Recycle Bin
    $lblStatus.Text = "Emptying Trash..."
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    $listActions.Add("- Recycle Bin Emptied")
    $progressBar.Value = 10

    # 2. Scanning
    $lblStatus.Text = "Scanning Directories..."
    $form.Refresh()
    Start-Sleep -Milliseconds 500 
    $folders = @("$env:TEMP", "C:\Windows\Temp", "C:\Windows\Prefetch", "$env:LOCALAPPDATA\NVIDIA\GLCache", "$env:LOCALAPPDATA\AMD\DxCache", "$env:LOCALAPPDATA\D3DSCache")
    $allFiles = @()
    foreach ($path in $folders) {
        if (Test-Path $path) {
            $f = @(Get-ChildItem -Path $path -Recurse -File -Force -ErrorAction SilentlyContinue)
            if ($f.Count -gt 0) { $allFiles += $f.FullName }
        }
    }

    # 3. Deleting
    $total = $allFiles.Count
    $removidos = 0; $bloqueados = 0
    if ($total -gt 0) {
        $current = 0
        foreach ($file in $allFiles) {
            $current++
            if ($current % 10 -eq 0) { 
                $progresso = 10 + [int](($current / $total) * 80)
                $progressBar.Value = $progresso
                $n = Split-Path $file -Leaf
                if ($n.Length -gt 40) { $n = $n.Substring(0,37) + "..." }
                $lblStatus.Text = "Removing: $n"
                [System.Windows.Forms.Application]::DoEvents() 
                
                Start-Sleep -Milliseconds 30 
            }
            try { Remove-Item -LiteralPath $file -Force -ErrorAction Stop; $removidos++; $listDeleted.Add($file) } 
            catch { $bloqueados++; $listLocked.Add($file) }
        }
    }

    # 4. CleanMgr
    $progressBar.Value = 95
    $lblStatus.Text = "Running Windows Deep Clean..."
    $form.Refresh()
    Start-Sleep -Milliseconds 1000
    Start-Process "cleanmgr.exe" -ArgumentList "/d c: /verylowdisk" -WindowStyle Hidden
    $listActions.Add("- Windows Deep Clean (CleanMgr) Triggered")

    # FINISH & GENERATE PRO LOG
    $progressBar.Value = 100
    [System.Media.SystemSounds]::Exclamation.Play()
    
    $finalLog = New-Object System.Collections.Generic.List[string]
    $finalLog.Add("==================================================================================")
    $finalLog.Add("                       SYSTEM OPTIMIZER  |  CLEANUP REPORT                        ")
    $finalLog.Add("==================================================================================")
    $finalLog.Add("")
    $finalLog.Add("  [ EXECUTION DATA ]")
    $finalLog.Add("  Date:       $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $finalLog.Add("  User:       $([System.Environment]::UserName)")
    $finalLog.Add("  Machine:    $([System.Environment]::MachineName)")
    $finalLog.Add("")
    $finalLog.Add("  [ SUMMARY STATISTICS ]")
    $finalLog.Add("  --------------------------------------------------------------------------------")
    $finalLog.Add("  Files Scanned:   $total")
    $finalLog.Add("  Files Deleted:   $removidos")
    $finalLog.Add("  Files Locked:    $bloqueados")
    $finalLog.Add("")
    $finalLog.Add("  [ SYSTEM ACTIONS ]")
    $finalLog.Add("  --------------------------------------------------------------------------------")
    $finalLog.AddRange($listActions)
    $finalLog.Add("")
    
    $finalLog.Add("  [ DELETED FILES ]")
    $finalLog.Add("  --------------------------------------------------------------------------------")
    if($listDeleted.Count -gt 0) { $finalLog.AddRange($listDeleted) } else { $finalLog.Add("  (None)") }
    $finalLog.Add("")
    
    $finalLog.Add("  [ LOCKED FILES (IN USE / SKIPPED) ]")
    $finalLog.Add("  --------------------------------------------------------------------------------")
    if($listLocked.Count -gt 0) { $finalLog.AddRange($listLocked) } else { $finalLog.Add("  (None)") }
    
    try { Set-Content -Path $arquivoLog -Value $finalLog -Encoding UTF8 } catch {}

    $lblStatus.ForeColor = $corSucesso
    $lblStatus.Text = "SUCCESS. System Optimized."
    $lblDesc.Text = "Deleted: $removidos files.`nLocked/Skipped: $bloqueados files."
    
    $btnRun.Text = "CLOSE"
    $btnRun.BackColor = $corSucesso
    $btnRun.Enabled = $true
    $btnRun.Add_MouseEnter({ $btnRun.BackColor = "#34ce57" })
    $btnRun.Add_MouseLeave({ $btnRun.BackColor = $corSucesso })
    
    Set-Content -Path $arquivoData -Value (Get-Date).ToString()
})

$form.ShowDialog()