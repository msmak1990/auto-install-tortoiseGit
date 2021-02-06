<#
.Synopsis
   Short description
    This script will be used for validating the TortoiseGit in the target system.
.DESCRIPTION
   Long description
    2021-02-06 Sukri Created.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
    Author : Sukri Kadir
    Email  : msmak1990@gmail.com
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

function Get-TortoiseGit
{
    Param
    (
    #Parameter for registry path for installed software..
        [ValidateNotNullOrEmpty()]
        [Array]
        $UninstallRegistries = @("HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
    )

    Begin
    {
        #throw exception if registry path is not available.
        foreach ($UninstallRegistry in $UninstallRegistries)
        {
            #write warning if only not exist.
            if (!$( Test-Path -Path $UninstallRegistry -PathType Any ))
            {
                Write-Warning -Message "[$UninstallRegistry] does not exist." -WarningAction Continue
            }

        }
    }
    Process
    {
        #recusively search TortoiseGit through registry key.
        foreach ($UninstallRegistry in $UninstallRegistries)
        {
            #get TortoiseGit registry properties.
            $RegistryProperties = Get-ItemProperty -Path "$UninstallRegistry\*"

            foreach ($RegistryProperty in $RegistryProperties)
            {
                if ($( $RegistryProperty.DisplayName ) -like "*TortoiseGit*")
                {
                    $ApplicationName = $( $RegistryProperty.DisplayName )
                }
            }

        }
    }
    End
    {
        #return true if TortoiseGit installed in target system.
        if ($ApplicationName)
        {
            return $true, $ApplicationName
        }

        #return false if no TortoiseGit installed in target system.
        if (!$ApplicationName)
        {
            return $false
        }
    }
}