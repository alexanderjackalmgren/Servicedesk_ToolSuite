# ==========================================
# UNIFIED NETWORK DIAGNOSTIC SUITE
# ==========================================

# Load dependencies once for all tools
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================================
# TOOL 1: DNS INSPECTOR
# ==========================================
function Launch-DnsInspector {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick DNS Inspector"
    $form.Size = New-Object System.Drawing.Size(550, 540)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $lblDomain = New-Object System.Windows.Forms.Label
    $lblDomain.Text = "Target Domain:"
    $lblDomain.Location = New-Object System.Drawing.Point(10, 10)
    $lblDomain.AutoSize = $true
    $form.Controls.Add($lblDomain)

    $txtDomain = New-Object System.Windows.Forms.TextBox
    $txtDomain.Location = New-Object System.Drawing.Point(10, 30)
    $txtDomain.Size = New-Object System.Drawing.Size(250, 20)
    $txtDomain.Text = "google.com"
    $form.Controls.Add($txtDomain)

    $cmbType = New-Object System.Windows.Forms.ComboBox
    $cmbType.Location = New-Object System.Drawing.Point(280, 30)
    $cmbType.Size = New-Object System.Drawing.Size(100, 20)
    $cmbType.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $cmbType.Items.AddRange(@("ALL", "A", "AAAA", "MX", "TXT", "CNAME", "NS", "SOA"))
    $cmbType.SelectedIndex = 0
    $form.Controls.Add($cmbType)

    $btnInspect = New-Object System.Windows.Forms.Button
    $btnInspect.Location = New-Object System.Drawing.Point(10, 60)
    $btnInspect.Size = New-Object System.Drawing.Size(100, 30)
    $btnInspect.Text = "Inspect"
    $btnInspect.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnInspect)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 100)
    $txtOutput.Size = New-Object System.Drawing.Size(510, 340)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Both"
    $txtOutput.WordWrap = $false
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 450)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_dns\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a scan first.") }
    })

    $btnInspect.Add_Click({
        $btnInspect.Enabled = $false
        $domain = $txtDomain.Text.Trim()
        $recordType = $cmbType.SelectedItem.ToString()
        $txtOutput.Text = "Querying $recordType records for $domain...`r`n`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        try {
            if ($recordType -eq "ALL") { $results = Resolve-DnsName -Name $domain -ErrorAction Stop } 
            else { $results = Resolve-DnsName -Name $domain -Type $recordType -ErrorAction Stop }
            $txtOutput.AppendText(($results | Format-Table -AutoSize | Out-String -Width 256).Trim() + "`r`n")
        } catch { $txtOutput.AppendText("Failed to resolve records.`r`nError: $($_.Exception.Message)`r`n") }

        $txtOutput.AppendText("`r`nInspection complete.`r`n")

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_dns\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnInspect.Enabled = $true
    })

    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 2: NETSTAT VISUALIZER
# ==========================================
function Launch-NetstatVisualizer {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick Netstat Visualizer"
    $form.Size = New-Object System.Drawing.Size(650, 540)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $btnRefresh = New-Object System.Windows.Forms.Button
    $btnRefresh.Location = New-Object System.Drawing.Point(10, 10)
    $btnRefresh.Size = New-Object System.Drawing.Size(150, 30)
    $btnRefresh.Text = "Refresh Connections"
    $btnRefresh.BackColor = [System.Drawing.Color]::LightGreen
    $form.Controls.Add($btnRefresh)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 50)
    $txtOutput.Size = New-Object System.Drawing.Size(610, 390)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Both"
    $txtOutput.WordWrap = $false
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 450)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_netstat\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a scan first.") }
    })

    $btnRefresh.Add_Click({
        $btnRefresh.Enabled = $false
        $txtOutput.Text = "Querying active TCP connections... Please wait.`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $connections = Get-NetTCPConnection -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, @{Name="ProcessName";Expression={ if ($_.OwningProcess -eq 0) { "System Idle" } elseif ($_.OwningProcess -eq 4) { "System" } else { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name } }}
            $txtOutput.Text = ($connections | Format-Table -AutoSize | Out-String -Width 256).Trim() + "`r`n"
        } catch { $txtOutput.Text = "Error retrieving network statistics: $($_.Exception.Message)`r`n" }

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_netstat\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnRefresh.Enabled = $true
    })

    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 3: PING LOGGER
# ==========================================
function Launch-PingLogger {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick Ping Logger"
    $form.Size = New-Object System.Drawing.Size(400, 480)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $txtTarget = New-Object System.Windows.Forms.TextBox
    $txtTarget.Location = New-Object System.Drawing.Point(10, 30)
    $txtTarget.Size = New-Object System.Drawing.Size(360, 20)
    $txtTarget.Text = "8.8.8.8"
    $form.Controls.Add($txtTarget)

    $btnStart = New-Object System.Windows.Forms.Button
    $btnStart.Location = New-Object System.Drawing.Point(10, 60)
    $btnStart.Size = New-Object System.Drawing.Size(100, 30)
    $btnStart.Text = "Start Logging"
    $btnStart.BackColor = [System.Drawing.Color]::LightGreen
    $form.Controls.Add($btnStart)

    $btnStop = New-Object System.Windows.Forms.Button
    $btnStop.Location = New-Object System.Drawing.Point(120, 60)
    $btnStop.Size = New-Object System.Drawing.Size(100, 30)
    $btnStop.Text = "Stop Logging"
    $btnStop.BackColor = [System.Drawing.Color]::LightPink
    $btnStop.Enabled = $false
    $form.Controls.Add($btnStop)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 100)
    $txtOutput.Size = New-Object System.Drawing.Size(360, 290)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 400)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_pinglog\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Start a log first.") }
    })

    $pingTimer = New-Object System.Windows.Forms.Timer
    $pingTimer.Interval = 1000
    $pinger = New-Object System.Net.NetworkInformation.Ping
    $global:currentPingLogFile = ""

    $pingTimer.Add_Tick({
        $target = $txtTarget.Text.Trim()
        $ts = Get-Date -Format "HH:mm:ss"
        try {
            $reply = $pinger.Send($target, 1000)
            if ($reply.Status -eq 'Success') { $msg = "[$ts] Reply from $target : time=$($reply.RoundtripTime)ms" } 
            else { $msg = "[$ts] Request timed out. ($($reply.Status))" }
        } catch { $msg = "[$ts] Ping failed. Check hostname/IP." }
        
        $txtOutput.AppendText("$msg`r`n")
        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        
        if ($global:currentPingLogFile) { Add-Content -Path $global:currentPingLogFile -Value $msg -ErrorAction SilentlyContinue }
    })

    $btnStart.Add_Click({
        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_pinglog\$systemDate"
        $global:currentPingLogFile = "$folderPath\$timeStamp.txt"

        if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }

        $btnStart.Enabled = $false; $txtTarget.Enabled = $false; $btnStop.Enabled = $true
        
        $headerMsg = "=== Started Ping Log ===`r`nTarget: $($txtTarget.Text)`r`nLog saved to: $($global:currentPingLogFile)`r`n---------------------------"
        $txtOutput.AppendText("$headerMsg`r`n")
        Add-Content -Path $global:currentPingLogFile -Value $headerMsg
        
        $pingTimer.Start()
    })

    $btnStop.Add_Click({
        $pingTimer.Stop()
        $footerMsg = "---------------------------`r`n=== Stopped Ping Log ===`r`n`r`n"
        $txtOutput.AppendText($footerMsg)
        if ($global:currentPingLogFile) { Add-Content -Path $global:currentPingLogFile -Value $footerMsg }
        $btnStart.Enabled = $true; $txtTarget.Enabled = $true; $btnStop.Enabled = $false
    })

    $form.Add_FormClosing({ if ($pingTimer.Enabled) { $pingTimer.Stop() }; $pinger.Dispose() })
    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 4: PORT SCANNER
# ==========================================
function Launch-PortScanner {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick Port Scanner"
    $form.Size = New-Object System.Drawing.Size(400, 480)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $txtIPs = New-Object System.Windows.Forms.TextBox
    $txtIPs.Location = New-Object System.Drawing.Point(10, 30)
    $txtIPs.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($txtIPs)

    $txtPorts = New-Object System.Windows.Forms.TextBox
    $txtPorts.Location = New-Object System.Drawing.Point(10, 80)
    $txtPorts.Size = New-Object System.Drawing.Size(360, 20)
    $txtPorts.Text = "80, 443, 22, 23"
    $form.Controls.Add($txtPorts)

    $btnScan = New-Object System.Windows.Forms.Button
    $btnScan.Location = New-Object System.Drawing.Point(10, 110)
    $btnScan.Size = New-Object System.Drawing.Size(100, 30)
    $btnScan.Text = "Scan"
    $btnScan.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnScan)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 150)
    $txtOutput.Size = New-Object System.Drawing.Size(360, 240)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 400)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Log Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_portscan\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a scan first.") }
    })

    $btnScan.Add_Click({
        $btnScan.Enabled = $false
        $txtOutput.Text = "Starting scan...`r`n`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        $ips = $txtIPs.Text -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
        $ports = $txtPorts.Text -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

        foreach ($ip in $ips) {
            foreach ($port in $ports) {
                try {
                    $tcp = New-Object System.Net.Sockets.TcpClient
                    $connect = $tcp.BeginConnect($ip, $port, $null, $null)
                    $wait = $connect.AsyncWaitHandle.WaitOne(500, $false) 
                    if ($tcp.Connected) { $txtOutput.AppendText("[ OPEN ] $ip : $port`r`n"); $tcp.Close() } 
                    else { $txtOutput.AppendText("[CLOSED] $ip : $port`r`n") }
                } catch { $txtOutput.AppendText("[ERROR ] $ip : $port`r`n") }
                [System.Windows.Forms.Application]::DoEvents()
            }
            $txtOutput.AppendText("---------------------------`r`n")
        }
        $txtOutput.AppendText("Scan complete.`r`n")

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_portscan\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnScan.Enabled = $true
    })

    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 5: TRACEROUTE
# ==========================================
function Launch-Traceroute {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick Traceroute"
    $form.Size = New-Object System.Drawing.Size(450, 540)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $txtTarget = New-Object System.Windows.Forms.TextBox
    $txtTarget.Location = New-Object System.Drawing.Point(10, 30)
    $txtTarget.Size = New-Object System.Drawing.Size(260, 20)
    $txtTarget.Text = "8.8.8.8"
    $form.Controls.Add($txtTarget)

    $chkResolve = New-Object System.Windows.Forms.CheckBox
    $chkResolve.Text = "Resolve Hostnames (Slower)"
    $chkResolve.Location = New-Object System.Drawing.Point(280, 28)
    $chkResolve.Size = New-Object System.Drawing.Size(160, 24)
    $chkResolve.Checked = $false
    $form.Controls.Add($chkResolve)

    $btnTrace = New-Object System.Windows.Forms.Button
    $btnTrace.Location = New-Object System.Drawing.Point(10, 60)
    $btnTrace.Size = New-Object System.Drawing.Size(100, 30)
    $btnTrace.Text = "Trace"
    $btnTrace.BackColor = [System.Drawing.Color]::LightGreen
    $form.Controls.Add($btnTrace)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(120, 60)
    $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
    $btnCancel.Text = "Cancel"
    $btnCancel.BackColor = [System.Drawing.Color]::LightPink
    $btnCancel.Enabled = $false
    $form.Controls.Add($btnCancel)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 100)
    $txtOutput.Size = New-Object System.Drawing.Size(410, 340)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 450)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $global:cancelTrace = $false
    $btnCancel.Add_Click({ $global:cancelTrace = $true; $btnCancel.Enabled = $false })

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_tracert\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a trace first.") }
    })

    $btnTrace.Add_Click({
        $btnTrace.Enabled = $false; $btnCancel.Enabled = $true; $global:cancelTrace = $false
        $txtOutput.Clear(); [System.Windows.Forms.Application]::DoEvents()
        
        $target = $txtTarget.Text.Trim()
        $pinger = New-Object System.Net.NetworkInformation.Ping
        $buffer = [System.Text.Encoding]::ASCII.GetBytes("QuickTracertToolDataBuffer")
        $options = New-Object System.Net.NetworkInformation.PingOptions(1, $true)

        try { 
            $targetIP = [System.Net.Dns]::GetHostAddresses($target)[0].ToString() 
            $txtOutput.AppendText("Tracing route to $target [$targetIP]`r`nover a maximum of 30 hops:`r`n`r`n")
        } catch { 
            $txtOutput.AppendText("Unable to resolve target system name '$target'.`r`n")
            $btnTrace.Enabled = $true; $btnCancel.Enabled = $false; return 
        }

        for ($hop = 1; $hop -le 30; $hop++) {
            if ($global:cancelTrace) { $txtOutput.AppendText("`r`nTrace cancelled by user.`r`n"); break }
            $options.Ttl = $hop
            
            try {
                $reply = $pinger.Send($targetIP, 1000, $buffer, $options)
                $hopStr = $hop.ToString().PadLeft(2, '0')
                
                if ($reply.Status -eq 'TtlExpired' -or $reply.Status -eq 'Success') {
                    $hopIP = $reply.Address.ToString()
                    $hopPing = $pinger.Send($hopIP, 1000)
                    $ms = if ($hopPing.Status -eq 'Success') { $hopPing.RoundtripTime.ToString().PadLeft(4, ' ') + " ms" } else { "   * " }

                    $hostName = $hopIP
                    if ($chkResolve.Checked) { try { $hostName = [System.Net.Dns]::GetHostEntry($hopIP).HostName } catch {} }

                    if ($hostName -ne $hopIP) { $txtOutput.AppendText("  $hopStr    $ms`t$hostName [$hopIP]`r`n") } 
                    else { $txtOutput.AppendText("  $hopStr    $ms`t$hopIP`r`n") }
                    
                    if ($reply.Status -eq 'Success') { $txtOutput.AppendText("`r`nTrace complete.`r`n"); break }
                } elseif ($reply.Status -eq 'TimedOut') { $txtOutput.AppendText("  $hopStr       * `tRequest timed out.`r`n") } 
                else { $txtOutput.AppendText("  $hopStr       * `t$($reply.Status)`r`n") }
            } catch { $txtOutput.AppendText("  $hopStr       * `tGeneral failure.`r`n") }
            
            $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
            [System.Windows.Forms.Application]::DoEvents()
        }

        if ($hop -gt 30 -and -not $global:cancelTrace) { $txtOutput.AppendText("`r`nTrace aborted: Max hops (30) reached.`r`n") }

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_tracert\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $pinger.Dispose(); $btnTrace.Enabled = $true; $btnCancel.Enabled = $false
    })

    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 6: SYSTEM PROFILER
# ==========================================
function Launch-SystemProfiler {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick System Profiler"
    $form.Size = New-Object System.Drawing.Size(500, 640)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $btnFetch = New-Object System.Windows.Forms.Button
    $btnFetch.Location = New-Object System.Drawing.Point(10, 10)
    $btnFetch.Size = New-Object System.Drawing.Size(150, 30)
    $btnFetch.Text = "Profile System"
    $btnFetch.BackColor = [System.Drawing.Color]::LightBlue
    $form.Controls.Add($btnFetch)

    $btnCopy = New-Object System.Windows.Forms.Button
    $btnCopy.Location = New-Object System.Drawing.Point(170, 10)
    $btnCopy.Size = New-Object System.Drawing.Size(120, 30)
    $btnCopy.Text = "Copy Output"
    $btnCopy.BackColor = [System.Drawing.Color]::LightGreen
    $form.Controls.Add($btnCopy)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 50)
    $txtOutput.Size = New-Object System.Drawing.Size(460, 490)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 555)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_sysprofile\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a profile first.") }
    })

    $btnCopy.Add_Click({
        if (-not [string]::IsNullOrWhiteSpace($txtOutput.Text)) {
            [System.Windows.Forms.Clipboard]::SetText($txtOutput.Text)
            $btnCopy.Text = "Copied!"
            Start-Sleep -Milliseconds 750
            $btnCopy.Text = "Copy Output"
        }
    })

    $btnFetch.Add_Click({
        $btnFetch.Enabled = $false
        $txtOutput.Text = "Gathering system info...`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $os = Get-CimInstance Win32_OperatingSystem
            $cs = Get-CimInstance Win32_ComputerSystem
            $bios = Get-CimInstance Win32_BIOS
            $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

            $baseUser = (Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" | Invoke-CimMethod -MethodName GetOwner).User | Select-Object -Unique
            
            if (-not $baseUser) { 
                $activeUser = "Unknown or Elevated" 
            } else {
                $wmiUser = Get-CimInstance Win32_UserAccount -Filter "Name='$baseUser'" -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($wmiUser -and $wmiUser.FullName) {
                    $activeUser = "$($wmiUser.FullName) ($baseUser)"
                } else {
                    $activeUser = $baseUser
                }
            }

            $ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
            $diskTotal = [math]::Round($disk.Size / 1GB, 2)
            $diskFree = [math]::Round($disk.FreeSpace / 1GB, 2)
            $diskPct = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
            $uptime = (Get-Date) - $os.LastBootUpTime

            $hwMake = $cs.Manufacturer
            $hwModel = $cs.Model

            $bitlockerStatus = "Unknown (Requires Elevation)"
            try {
                $bde = manage-bde -status c: | Out-String
                if ($bde -match "Protection On") { $bitlockerStatus = "Encrypted (On)" }
                elseif ($bde -match "Protection Off") { $bitlockerStatus = "Decrypted (Off)" }
            } catch { }

            $netInfo = "=== NETWORK ===`r`n"
            try {
                $activeAdapter = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1
                if ($activeAdapter) {
                    $ip = $activeAdapter.IPv4Address.IPAddress
                    $mac = $activeAdapter.NetAdapter.MacAddress
                    $gateway = $activeAdapter.IPv4DefaultGateway.NextHop
                    $dns = ($activeAdapter.DNSServer | Select-Object -ExpandProperty ServerAddresses) -join ', '
                    $desc = $activeAdapter.InterfaceDescription
                    $alias = $activeAdapter.InterfaceAlias
                    
                    $netType = "Ethernet / Other"
                    $wifiDetails = ""
                    
                    if ($desc -match "Wi-Fi|Wireless|802.11" -or $alias -match "Wi-Fi|Wireless") {
                        $netType = "Wi-Fi"
                        $wlan = netsh wlan show interfaces
                        $ssidMatch = $wlan | Select-String "\bSSID\b\s*:\s*(.*)"
                        $sigMatch = $wlan | Select-String "\bSignal\b\s*:\s*(.*)"
                        $ssid = if ($ssidMatch) { $ssidMatch[0].Line.Split(':')[1].Trim() } else { "Unknown" }
                        $signal = if ($sigMatch) { $sigMatch[0].Line.Split(':')[1].Trim() } else { "Unknown" }
                        $wifiDetails = " (SSID: $ssid, Signal: $signal)"
                    }
                    
                    $netInfo += "IP Address     : $ip`r`n"
                    $netInfo += "MAC Address    : $mac`r`n"
                    $netInfo += "Connection     : $netType$wifiDetails`r`n"
                    $netInfo += "Gateway        : $gateway`r`n"
                    $netInfo += "DNS Servers    : $dns`r`n"
                    $netInfo += "Adapter        : $desc`r`n"
                } else { $netInfo += "No active internet connection found.`r`n" }
            } catch { $netInfo += "Error retrieving network details.`r`n" }

            $report = @"
=== SYSTEM PROFILE ===
Hostname       : $($cs.Name)
Logged In User : $activeUser
Domain/Workgrp : $($cs.Domain)
OS Version     : $($os.Caption) ($($os.OSArchitecture))

=== HARDWARE ===
Manufacturer   : $hwMake
Model          : $hwModel
BIOS Serial    : $($bios.SerialNumber)

$netInfo
=== RESOURCES ===
Total RAM      : $ramGB GB
C: Drive Total : $diskTotal GB
C: Drive Free  : $diskFree GB ($diskPct% Free)
BitLocker (C:) : $bitlockerStatus

=== HEALTH ===
Last Boot Time : $($os.LastBootUpTime)
System Uptime  : $($uptime.Days) Days, $($uptime.Hours) Hours
"@
            $txtOutput.Text = $report
        } catch { $txtOutput.Text = "Error gathering profile: $($_.Exception.Message)" }

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_sysprofile\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnFetch.Enabled = $true
    })
    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 7: EVENT LOG INSPECTOR
# ==========================================
function Launch-EventLogInspector {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick Event Log Inspector (Critical/Error Only)"
    $form.Size = New-Object System.Drawing.Size(700, 540)
    $form.StartPosition = "CenterParent"

    $cmbTime = New-Object System.Windows.Forms.ComboBox
    $cmbTime.Location = New-Object System.Drawing.Point(10, 15)
    $cmbTime.Size = New-Object System.Drawing.Size(120, 20)
    $cmbTime.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $cmbTime.Items.AddRange(@("Last 1 Hour", "Last 24 Hours", "Last 7 Days"))
    $cmbTime.SelectedIndex = 1
    $form.Controls.Add($cmbTime)

    $btnFetch = New-Object System.Windows.Forms.Button
    $btnFetch.Location = New-Object System.Drawing.Point(140, 10)
    $btnFetch.Size = New-Object System.Drawing.Size(120, 30)
    $btnFetch.Text = "Fetch Logs"
    $btnFetch.BackColor = [System.Drawing.Color]::LightBlue
    $form.Controls.Add($btnFetch)

    $btnHelp = New-Object System.Windows.Forms.Button
    $btnHelp.Location = New-Object System.Drawing.Point(270, 10)
    $btnHelp.Size = New-Object System.Drawing.Size(30, 30)
    $btnHelp.Text = "?"
    $btnHelp.BackColor = [System.Drawing.Color]::LightYellow
    $form.Controls.Add($btnHelp)

    $toolTip = New-Object System.Windows.Forms.ToolTip
    $shortHelp = "Fetches the 50 most recent Critical, Error, and Warning events`r`nfrom the Windows System and Application logs."
    $toolTip.SetToolTip($btnHelp, $shortHelp)

    $btnHelp.Add_Click({
        [System.Windows.Forms.MessageBox]::Show("This tool fetches the 50 most recent Critical (Level 1), Error (Level 2), and Warning (Level 3) events from the Windows 'System' and 'Application' logs based on your selected timeframe.", "What does this tool do?", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
    })

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 50)
    $txtOutput.Size = New-Object System.Drawing.Size(660, 390)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Both"
    $txtOutput.WordWrap = $false
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 455)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_eventlog\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a log fetch first.") }
    })

    $btnFetch.Add_Click({
        $btnFetch.Enabled = $false
        $txtOutput.Text = "Querying Event Logs... This may take a moment.`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        $hours = switch ($cmbTime.SelectedItem) {
            "Last 1 Hour" { 1 }
            "Last 24 Hours" { 24 }
            "Last 7 Days" { 168 }
        }

        try {
            $startTime = (Get-Date).AddHours(-$hours)
            $events = Get-WinEvent -FilterHashtable @{LogName='System','Application'; Level=1,2,3; StartTime=$startTime} -MaxEvents 50 -ErrorAction Stop
            
            $output = $events | Select-Object TimeCreated, ProviderName, LevelDisplayName, Message | Format-Table -AutoSize | Out-String -Width 512
            $txtOutput.Text = "Top 50 Errors/Warnings in the $($cmbTime.SelectedItem):`r`n`r`n" + $output.Trim() + "`r`n"
        } catch { 
            if ($_.Exception.Message -match "No events were found") { $txtOutput.Text = "No Critical/Error events found in the specified timeframe.`r`n" }
            else { $txtOutput.Text = "Error: $($_.Exception.Message)`r`n" }
        }

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_eventlog\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnFetch.Enabled = $true
    })
    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 8: ACCOUNT STATUS (CURRENT LOGGED IN)
# ==========================================
function Launch-AccountStatus {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick Account Status"
    $form.Size = New-Object System.Drawing.Size(400, 360)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"

    $btnFetch = New-Object System.Windows.Forms.Button
    $btnFetch.Location = New-Object System.Drawing.Point(10, 10)
    $btnFetch.Size = New-Object System.Drawing.Size(200, 30)
    $btnFetch.Text = "Check Logged-In User"
    $btnFetch.BackColor = [System.Drawing.Color]::LightBlue
    $form.Controls.Add($btnFetch)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 50)
    $txtOutput.Size = New-Object System.Drawing.Size(360, 190)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 260)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_account\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a status check first.") }
    })

    $btnFetch.Add_Click({
        $btnFetch.Enabled = $false
        $txtOutput.Text = "Querying account details for $env:USERDOMAIN\$env:USERNAME...`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $adsi = [ADSI]"WinNT://$env:USERDOMAIN/$env:USERNAME,user"
            $lockedOut = if ($adsi.IsAccountLocked.Value) { "YES" } else { "NO" }
            $disabled = if ($adsi.UserFlags.Value -band 2) { "YES" } else { "NO" }
            
            $fullName = $adsi.FullName.Value
            $desc = $adsi.Description.Value
            $lastLogin = $adsi.LastLogin.Value

            if ($env:USERDOMAIN -eq "AzureAD") {
                $wmiUser = Get-CimInstance Win32_UserAccount -Filter "Name='$env:USERNAME'" -ErrorAction SilentlyContinue
                if (-not $fullName -and $wmiUser.FullName) { $fullName = $wmiUser.FullName + " (Cached)" }
                if (-not $desc -and $wmiUser.Description) { $desc = $wmiUser.Description }
                if (-not $lastLogin) { $lastLogin = "Cloud Account - Check Entra ID" }
            }

            $report = @"
=== ACCOUNT STATUS ===
Username     : $($env:USERNAME)
Domain       : $($env:USERDOMAIN)

Account Lock : $lockedOut
Disabled     : $disabled

Full Name    : $fullName
Description  : $desc
Last Login   : $lastLogin
"@
            $txtOutput.Text = $report
        } catch { $txtOutput.Text = "Failed to query account details: $($_.Exception.Message)" }

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_account\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnFetch.Enabled = $true
    })
    $form.ShowDialog() | Null
}

# ==========================================
# TOOL 9: ADAPTER & WI-FI DETAILS
# ==========================================
function Launch-AdapterInfo {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick Adapter & Wi-Fi Details"
    $form.Size = New-Object System.Drawing.Size(550, 460)
    $form.StartPosition = "CenterParent"

    $btnFetch = New-Object System.Windows.Forms.Button
    $btnFetch.Location = New-Object System.Drawing.Point(10, 10)
    $btnFetch.Size = New-Object System.Drawing.Size(150, 30)
    $btnFetch.Text = "Fetch Adapters"
    $btnFetch.BackColor = [System.Drawing.Color]::LightBlue
    $form.Controls.Add($btnFetch)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 50)
    $txtOutput.Size = New-Object System.Drawing.Size(510, 290)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 360)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_adapter\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Fetch adapters first.") }
    })

    $btnFetch.Add_Click({
        $btnFetch.Enabled = $false
        $txtOutput.Text = "Querying active adapters...`r`n`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        try {
            $ipConfig = Get-NetIPConfiguration | Where-Object { $_.IPv4Address }
            
            foreach ($adapter in $ipConfig) {
                $txtOutput.AppendText("=== $($adapter.InterfaceAlias) ===`r`n")
                $txtOutput.AppendText("Description : $($adapter.InterfaceDescription)`r`n")
                $txtOutput.AppendText("MAC Address : $($adapter.NetAdapter.MacAddress)`r`n") # <-- Added MAC extraction
                $txtOutput.AppendText("IPv4 Address: $($adapter.IPv4Address.IPAddress)`r`n")
                $txtOutput.AppendText("IPv4 Gateway: $($adapter.IPv4DefaultGateway.NextHop)`r`n")
                $txtOutput.AppendText("DNS Servers : $(($adapter.DNSServer | Select-Object -ExpandProperty ServerAddresses) -join ', ')`r`n`r`n")
            }

            $wifi = netsh wlan show interfaces | Select-String -Pattern "SSID|Signal|Radio type"
            if ($wifi) {
                $txtOutput.AppendText("=== WI-FI SPECIFICS ===`r`n")
                $txtOutput.AppendText(($wifi | Out-String).Trim() + "`r`n")
            }
        } catch { $txtOutput.AppendText("Error: $($_.Exception.Message)") }

        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_adapter\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnFetch.Enabled = $true
    })
    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 10: ARP DISCOVERY
# ==========================================
function Launch-ArpDiscovery {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Quick ARP Discovery"
    $form.Size = New-Object System.Drawing.Size(550, 540)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $lblSubnet = New-Object System.Windows.Forms.Label
    $lblSubnet.Text = "Subnet Base (e.g., 192.168.0.0/24):"
    $lblSubnet.Location = New-Object System.Drawing.Point(10, 10)
    $lblSubnet.AutoSize = $true
    $form.Controls.Add($lblSubnet)

    $txtSubnet = New-Object System.Windows.Forms.TextBox
    $txtSubnet.Location = New-Object System.Drawing.Point(10, 30)
    $txtSubnet.Size = New-Object System.Drawing.Size(200, 20)
    
    try {
        $activeIP = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1
        if ($activeIP) {
            $ipOctets = $activeIP.IPv4Address.IPAddress -split '\.'
            $txtSubnet.Text = "$($ipOctets[0]).$($ipOctets[1]).$($ipOctets[2])"
        } else { $txtSubnet.Text = "192.168.1" }
    } catch { $txtSubnet.Text = "192.168.1" }
    $form.Controls.Add($txtSubnet)

    # --- FIX: Re-assembled and Registered Scan Button ---
    $btnScan = New-Object System.Windows.Forms.Button
    $btnScan.Location = New-Object System.Drawing.Point(220, 25)
    $btnScan.Size = New-Object System.Drawing.Size(120, 25)
    $btnScan.Text = "Scan Subnet"
    $btnScan.BackColor = [System.Drawing.Color]::LightBlue
    $form.Controls.Add($btnScan)

    # --- ADDED: Help Button and Multi-Layered State Tooltip ---
    $btnHelp = New-Object System.Windows.Forms.Button
    $btnHelp.Location = New-Object System.Drawing.Point(345, 22)
    $btnHelp.Size = New-Object System.Drawing.Size(25, 25)
    $btnHelp.Text = "?"
    $btnHelp.BackColor = [System.Drawing.Color]::LightYellow
    $form.Controls.Add($btnHelp)

    $toolTip = New-Object System.Windows.Forms.ToolTip
    $shortHelp = "REACHABLE: Confirmed live device.`r`nPROBE: Proactively verifying if device is still there.`r`nPERMANENT: Statically mapped (like the gateway/broadcast)."
    $toolTip.SetToolTip($btnHelp, $shortHelp)

    $btnHelp.Add_Click({
        $helpText = "Understanding ARP Cache States:`n`n" +
                    "• REACHABLE:`n" +
                    "The OS has positive confirmation that the device is live. Packets are sent directly with zero overhead.`n`n" +
                    "• PROBE:`n" +
                    "The entry's active timer expired. Windows is sending direct unicast requests to verify if the device is still sitting on that port.`n`n" +
                    "• PERMANENT:`n" +
                    "A static mapping that never expires. This includes local broadcast addresses and hardcoded infrastructure entries."
        
        [System.Windows.Forms.MessageBox]::Show($helpText, "What do these states mean?", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
    })

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 70)
    $txtOutput.Size = New-Object System.Drawing.Size(510, 370)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Both"
    $txtOutput.WordWrap = $false
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 455)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_arp\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a scan first.") }
    })

    $btnScan.Add_Click({
        $btnScan.Enabled = $false
        $userInput = $txtSubnet.Text.Trim()
        
        # Regex to match the first 3 octets, ignoring any trailing host IPs, /24, or spaces
        if ($userInput -match '^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})') {
            $subnet = $Matches[1]
        } else {
            [System.Windows.Forms.MessageBox]::Show("Invalid IP or Subnet format. Please use x.x.x.x or x.x.x.x/24", "Input Error", 0, [System.Windows.Forms.MessageBoxIcon]::Error)
            $btnScan.Enabled = $true
            return
        }

        $txtOutput.Text = "Initializing Ping Sweep across $subnet.1 to $subnet.254...`r`n"
        $txtOutput.AppendText("Please wait, this handles multi-threaded drops to stay responsive...`r`n`r`n")
        [System.Windows.Forms.Application]::DoEvents()

        $pingTasks = foreach ($i in 1..254) {
            $targetIP = "$subnet.$i"
            $pinger = New-Object System.Net.NetworkInformation.Ping
            $pinger.SendAsync($targetIP, 150, $null)
        }
        
        Start-Sleep -Seconds 2
        [System.Windows.Forms.Application]::DoEvents()

        $txtOutput.AppendText("Sweep complete. Querying live neighbor cache...`r`n`r`n")
        
        try {
            $arpCache = Get-NetNeighbor -AddressFamily IPv4 | 
                Where-Object { $_.IPAddress -like "$subnet.*" -and $_.State -ne 'Unreachable' } | 
                Select-Object IPAddress, LinkLayerAddress, State | 
                Sort-Object IPAddress

            if ($arpCache) {
                $txtOutput.AppendText(($arpCache | Format-Table -AutoSize | Out-String -Width 256).Trim() + "`r`n")
            } else {
                $txtOutput.AppendText("No active ARP records found for subnet base: $subnet.0/24`r`n")
            }
        } catch {
            $txtOutput.AppendText("Error querying ARP table: $($_.Exception.Message)`r`n")
        }

        # --- Structured CSV Logging Logic ---
        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_arp\$systemDate"
        $filePath = "$folderPath\$timeStamp.csv"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            
            # Export the structured object cache directly to CSV
            $arpCache | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8
            
            $txtOutput.AppendText("`r`n[!] CSV Log saved to: $filePath`r`n")
        } catch { 
            $txtOutput.AppendText("`r`n[!] Error saving CSV log to: $filePath`r`n") 
        }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnScan.Enabled = $true
    })

    $form.ShowDialog() | Out-Null
}

# ==========================================
# TOOL 11: WAN & ISP TRIAGE
# ==========================================
function Launch-IspTriage {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "WAN & ISP Triage"
    $form.Size = New-Object System.Drawing.Size(550, 540)
    $form.StartPosition = "CenterParent"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $btnRun = New-Object System.Windows.Forms.Button
    $btnRun.Location = New-Object System.Drawing.Point(10, 15)
    $btnRun.Size = New-Object System.Drawing.Size(150, 30)
    $btnRun.Text = "Run ISP Diagnostics"
    $btnRun.BackColor = [System.Drawing.Color]::LightBlue
    $form.Controls.Add($btnRun)

    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Location = New-Object System.Drawing.Point(10, 60)
    $txtOutput.Size = New-Object System.Drawing.Size(510, 380)
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Both"
    $txtOutput.WordWrap = $false
    $txtOutput.ReadOnly = $true
    $txtOutput.BackColor = [System.Drawing.Color]::White
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    $btnOpenLoc = New-Object System.Windows.Forms.Button
    $btnOpenLoc.Location = New-Object System.Drawing.Point(10, 455)
    $btnOpenLoc.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenLoc.Text = "Open Location"
    $btnOpenLoc.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($btnOpenLoc)

    $btnOpenLoc.Add_Click({
        $targetPath = "C:\temp\quick_isptriage\"
        if (Test-Path -Path $targetPath) { Invoke-Item $targetPath } 
        else { [System.Windows.Forms.MessageBox]::Show("Directory not found. Run a check first.") }
    })

    $btnRun.Add_Click({
        $btnRun.Enabled = $false
        $txtOutput.Text = "Starting WAN & ISP Triage... Please wait.`r`n`r`n"
        [System.Windows.Forms.Application]::DoEvents()

        # 1. Gather Public IP and ISP Information
        $txtOutput.AppendText("[1/3] Querying external WAN metrics...`r`n")
        [System.Windows.Forms.Application]::DoEvents()
        
        try {
            # Direct text-only fallback for IP
            $publicIp = (Invoke-RestMethod -Uri "https://icanhazip.com" -TimeoutSec 4).Trim()
            
            # Detailed JSON lookup for geolocation and ISP
            $ipDetails = Invoke-RestMethod -Uri "https://ipinfo.io/json" -TimeoutSec 4
            $isp = $ipDetails.org
            $location = "$($ipDetails.city), $($ipDetails.region), $($ipDetails.country)"
            
            $txtOutput.AppendText("  -> Public IP : $publicIp`r`n")
            $txtOutput.AppendText("  -> ISP / Org : $isp`r`n")
            $txtOutput.AppendText("  -> Location  : $location`r`n`r`n")
        } catch {
            $txtOutput.AppendText("  [!] Failed to query public WAN details. (Off-line or blocked routing)`r`n`r`n")
        }
        [System.Windows.Forms.Application]::DoEvents()

        # Helper function to run a quick internal ping assessment
        function Test-TargetPing($targetName, $targetAddress) {
            $pinger = New-Object System.Net.NetworkInformation.Ping
            $totalMs = 0
            $successCount = 0
            $iterations = 3

            for ($i = 0; $i -lt $iterations; $i++) {
                try {
                    $reply = $pinger.Send($targetAddress, 1000)
                    if ($reply.Status -eq 'Success') {
                        $totalMs += $reply.RoundtripTime
                        $successCount++
                    }
                } catch {}
            }

            if ($successCount -gt 0) {
                $avgMs = [math]::Round($totalMs / $successCount, 1)
                return "  -> $targetName ($targetAddress): REACHABLE | Avg Latency: $avgMs ms"
            } else {
                return "  -> $targetName ($targetAddress): UNREACHABLE"
            }
        }

        # 2. Check Gateway Connectivity
        $txtOutput.AppendText("[2/3] Checking internal gateway hops...`r`n")
        try {
            $activeNet = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1
            if ($activeNet) {
                $gateway = $activeNet.IPv4DefaultGateway.NextHop
                $gwResult = Test-TargetPing "Local Gateway" $gateway
                $txtOutput.AppendText("$gwResult`r`n`r`n")
            } else {
                $txtOutput.AppendText("  [!] No active IPv4 default gateway found on host adapter.`r`n`r`n")
            }
        } catch {
            $txtOutput.AppendText("  [!] Error querying default gateway infrastructure.`r`n`r`n")
        }
        [System.Windows.Forms.Application]::DoEvents()

        # 3. Check Public Backbone Infrastructure
        $txtOutput.AppendText("[3/3] Checking public internet backbone latency...`r`n")
        
        $googleDns = Test-TargetPing "Google Public DNS" "8.8.8.8"
        $txtOutput.AppendText("$googleDns`r`n")
        [System.Windows.Forms.Application]::DoEvents()

        $cloudflareDns = Test-TargetPing "Cloudflare DNS" "1.1.1.1"
        $txtOutput.AppendText("$cloudflareDns`r`n`r`n")
        
        $txtOutput.AppendText("Triage scan complete.`r`n")

        # --- Standard Log Saving Logic ---
        $systemDate = Get-Date -Format "yyyy-MM-dd"
        $timeStamp = Get-Date -Format "HH-mm-ss"
        $folderPath = "C:\temp\quick_isptriage\$systemDate"
        $filePath = "$folderPath\$timeStamp.txt"

        try {
            if (-not (Test-Path -Path $folderPath)) { New-Item -ItemType Directory -Force -Path $folderPath | Out-Null }
            $txtOutput.Text | Out-File -FilePath $filePath -Encoding UTF8
            $txtOutput.AppendText("`r`n[!] Log saved to: $filePath`r`n")
        } catch { $txtOutput.AppendText("`r`n[!] Error saving log to: $filePath`r`n") }

        $txtOutput.SelectionStart = $txtOutput.Text.Length; $txtOutput.ScrollToCaret()
        $btnRun.Enabled = $true
    })

    $form.ShowDialog() | Out-Null
}

# ==========================================
# MAIN MENU DASHBOARD (ULTRA-MODERN UI - TEXT ONLY)
# ==========================================
[System.Windows.Forms.Application]::EnableVisualStyles()

$menu = New-Object System.Windows.Forms.Form
$menu.Text = "Service Desk Diagnostic Suite"
$menu.Size = New-Object System.Drawing.Size(350, 630) # Expanded height to neatly contain the new button
$menu.StartPosition = "CenterScreen"
$menu.FormBorderStyle = "FixedDialog"
$menu.MaximizeBox = $false
$menu.BackColor = [System.Drawing.Color]::White

# --- App Header ---
$lblHeader = New-Object System.Windows.Forms.Label
$lblHeader.Text = "Diagnostic Suite"
$lblHeader.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 16)
$lblHeader.Location = New-Object System.Drawing.Point(15, 15)
$lblHeader.AutoSize = $true
$lblHeader.ForeColor = [System.Drawing.Color]::FromArgb(43, 87, 154)
$menu.Controls.Add($lblHeader)

$lblSubHeader = New-Object System.Windows.Forms.Label
$lblSubHeader.Text = "Select a category and tool below."
$lblSubHeader.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblSubHeader.Location = New-Object System.Drawing.Point(18, 45)
$lblSubHeader.AutoSize = $true
$lblSubHeader.ForeColor = [System.Drawing.Color]::DimGray
$menu.Controls.Add($lblSubHeader)

# --- Custom Navigation Bar (Text Only) ---
$navNetwork = New-Object System.Windows.Forms.Button
$navNetwork.Text = "NETWORK"
$navNetwork.Size = New-Object System.Drawing.Size(150, 35)
$navNetwork.Location = New-Object System.Drawing.Point(15, 75)
$navNetwork.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
$navNetwork.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$navNetwork.FlatAppearance.BorderSize = 0
$navNetwork.Cursor = [System.Windows.Forms.Cursors]::Hand
$menu.Controls.Add($navNetwork)

$navSystem = New-Object System.Windows.Forms.Button
$navSystem.Text = "SYSTEM"
$navSystem.Size = New-Object System.Drawing.Size(150, 35)
$navSystem.Location = New-Object System.Drawing.Point(165, 75)
$navSystem.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
$navSystem.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$navSystem.FlatAppearance.BorderSize = 0
$navSystem.Cursor = [System.Windows.Forms.Cursors]::Hand
$menu.Controls.Add($navSystem)

# Active/Inactive Colors for Nav
$activeColor = [System.Drawing.Color]::FromArgb(230, 240, 255)
$activeText = [System.Drawing.Color]::FromArgb(0, 90, 158)
$inactiveColor = [System.Drawing.Color]::White
$inactiveText = [System.Drawing.Color]::Gray

# --- Panels ---
$pnlNetwork = New-Object System.Windows.Forms.Panel
$pnlNetwork.Location = New-Object System.Drawing.Point(15, 115)
$pnlNetwork.Size = New-Object System.Drawing.Size(300, 450)
$menu.Controls.Add($pnlNetwork)

$pnlSystem = New-Object System.Windows.Forms.Panel
$pnlSystem.Location = New-Object System.Drawing.Point(15, 115)
$pnlSystem.Size = New-Object System.Drawing.Size(300, 450)
$pnlSystem.Visible = $false
$menu.Controls.Add($pnlSystem)

# --- Navigation Logic ---
$navNetwork.Add_Click({
    $pnlNetwork.Visible = $true
    $pnlSystem.Visible = $false
    $navNetwork.BackColor = $activeColor; $navNetwork.ForeColor = $activeText
    $navSystem.BackColor = $inactiveColor; $navSystem.ForeColor = $inactiveText
})

$navSystem.Add_Click({
    $pnlNetwork.Visible = $false
    $pnlSystem.Visible = $true
    $navSystem.BackColor = $activeColor; $navSystem.ForeColor = $activeText
    $navNetwork.BackColor = $inactiveColor; $navNetwork.ForeColor = $inactiveText
})

$navNetwork.PerformClick()

# --- Modern Button Helper (Safe Text) ---
function Add-ModernButton($panel, $text, $top, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "    $text" 
    $btn.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $btn.Size = New-Object System.Drawing.Size(300, 45)
    $btn.Location = New-Object System.Drawing.Point(0, $top)
    
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $btn.BackColor = [System.Drawing.Color]::WhiteSmoke
    $btn.ForeColor = [System.Drawing.Color]::Black
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 0
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240) })
    $btn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::WhiteSmoke })
    $btn.Add_Click($action)
    
    $panel.Controls.Add($btn)
}

# --- Populate Network Panel ---
Add-ModernButton $pnlNetwork "DNS Inspector" 0 { Launch-DnsInspector }
Add-ModernButton $pnlNetwork "Ping Logger" 55 { Launch-PingLogger }
Add-ModernButton $pnlNetwork "Port Scanner" 110 { Launch-PortScanner }
Add-ModernButton $pnlNetwork "Traceroute Tool" 165 { Launch-Traceroute }
Add-ModernButton $pnlNetwork "Adapter Info" 220 { Launch-AdapterInfo }
Add-ModernButton $pnlNetwork "Netstat Visualizer" 275 { Launch-NetstatVisualizer }
Add-ModernButton $pnlNetwork "ARP Discovery" 330 { Launch-ArpDiscovery }
Add-ModernButton $pnlNetwork "WAN & ISP Triage" 385 { Launch-IspTriage } # <-- Add This Line

# --- Populate System Panel ---
Add-ModernButton $pnlSystem "System Profiler" 0 { Launch-SystemProfiler }
Add-ModernButton $pnlSystem "Event Log Inspector" 55 { Launch-EventLogInspector }
Add-ModernButton $pnlSystem "Account Status" 110 { Launch-AccountStatus }

$menu.ShowDialog() | Out-Null