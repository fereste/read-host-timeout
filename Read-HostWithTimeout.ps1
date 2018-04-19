function Read-HostWithTimeout {
    <#
    .SYNOPSIS
    Text input with timeout.

    .DESCRIPTION
    Text input with timeout. If a key is not pressed before the configured timeout, input will end.
    
    .PARAMETER Prompt
    Prompt for input.  Will have a ': ' appended, but no linefeed.
    
    .PARAMETER Timeout
    Seconds to wait for input.
    
    .NOTES
    Based on https://blogs.msdn.microsoft.com/timid/2014/01/29/read-host-with-a-timeout-kind-of/
    #>

    Param (
        [Parameter(Mandatory = $false)]
        [string]$Prompt = '',
        [Parameter(Mandatory = $true)]
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
