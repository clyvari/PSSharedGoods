#requires -Module PSWriteColor
<#
    .SYNOPSIS
    Returns an instance of the logger object.

    .EXAMPLE
    $Logger = Get-Logger -ShowTime -LogPath 'C:\temp\test.log'
    $Logger.AddErrorRecord("test error")
    $Logger.AddInfoRecord("test info")
    $Logger.AddSuccessRecord("test success")
    $Logger.AddRecord("test record")
#>

function Get-Logger {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string] $LogPath,
        [switch] $ShowTime,
        [string] $TimeFormat = 'yyyy-MM-dd HH:mm:ss'
    )
    if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
        $LogsDir = [System.IO.Path]::GetDirectoryName($LogPath)
        New-Item $LogsDir -ItemType Directory -Force | Out-Null
        New-Item $LogPath -ItemType File -Force | Out-Null
    }

    $Logger = [PSCustomObject]@{
        LogPath    = $LogPath
        ShowTime   = $ShowTime
        TimeFormat = $TimeFormat
    }

    Add-Member -InputObject $Logger -MemberType ScriptMethod AddErrorRecord -Value {
        param(
            [Parameter(Mandatory = $true)]
            [string]$String
        )
        if ([string]::IsNullOrWhiteSpace($this.LogPath)) {
            Write-Color -Text "[Error] ", $String -Color Red, White -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        } else {
            Write-Color -Text "[Error] ", $String -Color Red, White -LogFile:$this.LogPath -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        }
    }

    Add-Member -InputObject $Logger -MemberType ScriptMethod AddInfoRecord -Value {
        param(
            [Parameter(Mandatory = $true)]
            [string]$String
        )
        if ([string]::IsNullOrWhiteSpace($this.LogPath)) {
            Write-Color -Text "[Info] ", $String -Color Yellow, White -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        } else {
            Write-Color -Text "[Info] ", $String -Color Yellow, White -LogFile:$this.LogPath -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        }
    }

    Add-Member -InputObject $Logger -MemberType ScriptMethod AddWarningRecord -Value {
        param(
            [Parameter(Mandatory = $true)]
            [string]$String
        )
        if ([string]::IsNullOrWhiteSpace($this.LogPath)) {
            Write-Color -Text "[Warning] ", $String -Color Yellow, White -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        } else {
            Write-Color -Text "[Warning] ", $String -Color Magenta, White -LogFile:$this.LogPath -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        }
    }

    Add-Member -InputObject $Logger -MemberType ScriptMethod AddRecord -Value {
        param(
            [Parameter(Mandatory = $true)]
            [string]$String
        )
        if ([string]::IsNullOrWhiteSpace($this.LogPath)) {
            Write-Color -Text $String -Color Yellow, White -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        } else {
            Write-Color -Text $String -Color White -LogFile:$this.LogPath -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        }
    }
    Add-Member -InputObject $Logger -MemberType ScriptMethod AddSuccessRecord -Value {
        param(
            [Parameter(Mandatory = $true)]
            [string]$String
        )
        if ([string]::IsNullOrWhiteSpace($this.LogPath)) {
            Write-Color -Text "[Success] ", $String -Color Yellow, White -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        } else {
            Write-Color -Text "[Success] ", $String -Color Green, White -LogFile:$this.LogPath -ShowTime:$this.ShowTime -TimeFormat $this:TimeFormat
        }
    }
    return $Logger
}