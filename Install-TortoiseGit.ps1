<#
.Synopsis
   Short description
    This script will be used for installing silently TortoiseGit installer with getting latest version from web.
.DESCRIPTION
   Long description
    2020-11-16 Sukri Created.
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

#import the external functions from the external script files.
. "$PSScriptRoot\Get-AdministrationRight"
. "$PSScriptRoot\Get-OSArchitecture"
. "$PSScriptRoot\Get-TortoiseGit"
. "$PSScriptRoot\Get-TortoiseGitBinary"

#throw exception if no administration right.
$IsAdministrator = Get-AdministrationRight

if ($IsAdministrator -ne $true)
{
    Write-Warning -Message "You are currently running this script WITHOUT the administration right. Please run with administration right. Exit." -WarningAction Stop
}

#function to install the TortoiseGit application.
function Install-TortoiseGit
{
    Param
    (

    #Parameter for TortoiseGit installer file name.
        [ValidateNotNullOrEmpty()]
        [String]
        $BinaryFileName = "TortoiseGit-2.11.0.0-32bit.msi",

    #Parameter for TortoiseGit installer source path or uri.
        [ValidateNotNullOrEmpty()]
        [String]
        $InstallerSourceDirectory = "https://download.tortoisegit.org/tgit"
    )

    Begin
    {
        #validate if TortoiseGit installed or not from target system.
        $ApplicationInstallationStatus = Get-TortoiseGit

        if ($ApplicationInstallationStatus[0] -eq $true)
        {
            Write-Warning -Message "[$( $ApplicationInstallationStatus[1] )] already installed." -WarningAction Continue
        }

        #validate if TortoiseGit is not installed from target system.
        if ($ApplicationInstallationStatus[0] -eq $false)
        {
            #if TortoiseGit installer source directory is local directory.
            if ($( Test-Path -Path $InstallerSourceDirectory -PathType Any ))
            {
                Write-Warning -Message "[$InstallerSourceDirectory] is local directory."

                #get full path of TortoiseGit binary file.
                $BinaryFile = "$InstallerSourceDirectory\$BinaryFileName"
            }

            #if TortoiseGit installer source directory is url.
            if (!$( Test-Path -Path $InstallerSourceDirectory -PathType Any ))
            {
                Write-Warning -Message "[$InstallerSourceDirectory] is url link." -WarningAction Continue

                #get full path of TortoiseGit binary file.
                $BinaryFile = Get-TortoiseGitBinary -InstallerSourceUrl $InstallerSourceDirectory
            }
        }

    }
    Process
    {

        #if TortoiseGit is not installed from target system.
        if ($ApplicationInstallationStatus[0] -eq $false)
        {
            #install TortoiseGit binary.
            $InstallationProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $BinaryFile, "/passive", "/norestart" -Wait -NoNewWindow -Verbose -ErrorAction Stop

            #throw exception if failed to install TortoiseGit binary.
            if ($InstallationProcess.ExitCode -ne 0)
            {
                Write-Error -Message "[$BinaryFile] failed to install with exit code [$( $InstallationProcess.ExitCode )]." -ErrorAction Stop
            }
        }

    }
    End
    {
        Write-Host "Done."
    }
}

#log the logging into log file.
Start-Transcript -Path "$PSScriptRoot\$( $MyInvocation.ScriptName )"

#execute the function.
Install-TortoiseGit

#stop to log the logging.
Stop-Transcript