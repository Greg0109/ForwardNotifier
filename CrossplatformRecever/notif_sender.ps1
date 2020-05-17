# Params

param ($title, $message)

Add-Type -AssemblyName  System.Windows.Forms

$global:balloon = New-Object System.Windows.Forms.NotifyIcon

$path = (Get-Process -id $pid).Path

$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)

# System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property

$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::info

$balloon.BalloonTipTitle = $title
$balloon.BalloonTipText = $message

$balloon.Visible = $true 

$balloon.ShowBalloonTip(5000) 