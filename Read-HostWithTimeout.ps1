function Read-HostWithTimeout {
    <#
    .SYNOPSIS
    Text input with timeout.

    .DESCRIPTION
    An unholy union of $host.UI.RawUI.ReadKey() and Read-Host.  It is usable, but that's good enough for my current needs.
    Here are the limitations I've hit so far:
    - Keyboard buffer doesn't.  If you type too fast, the second (or more) character(s) will be lost.
    - Keyboard buffer is not contiguious.  The first character is captured by ReadKey(), and the rest by Read-Host.  This means up-arrow will only show the characters captured by Read-Host.
    - This also means you can't back up over the first character.
    Still, all I need is a Y/N with a timeout, and that works.
    
    .PARAMETER Prompt
    Prompt for input.  Will have a ': ' appended, but no linefeed.
    
    .PARAMETER Timeout
    Seconds to wait for input.  If no input received, will return $null.  If the -NoNewLine parameter is not specified, once the user starts typing, the timeout is suspended until the user presses [Enter].
    
    .NOTES
    Based on https://blogs.msdn.microsoft.com/timid/2014/01/29/read-host-with-a-timeout-kind-of/
    #>

    Param (
        [string]$Prompt = '',
        [ValidateRange(1, 60)]
        [int]$Timeout = 10
    );
    
    Write-Host "${Prompt}: " -NoNewline;

    $key = '';
    $first = $true;
    $end = (Get-Date).AddSeconds($Timeout)
    $fullString='';
    while ((Get-Date) -lt $end)
    {
        if ($host.ui.RawUI.KeyAvailable)
        {
            $key = $host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp").Character;
            
            if ($first -eq $false) 
            {
                Write-Host $key -NoNewline
                if ([System.Text.Encoding]::ASCII.GetBytes($key.ToString())[0] -eq 13 -and $first -eq $false)
                {
                    Write-Host 'fue enter'
                    break;
                }

                $fullString += $key;
                $end = (Get-Date).AddSeconds($Timeout)
            }
            else 
            {
                $first = $false;                
            }
        }

        Start-Sleep -Milliseconds 50;        
    }

    return $fullString;
}