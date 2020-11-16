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

#get boolean value if script ran with administration right.
$IsAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

#throw exception if no administration right.
if ($IsAdministrator -ne $true)
{
    Write-Warning -Message "Please run script with administrator right." -WarningAction Stop
    Exit-PSSession
}

<#
.Synopsis
   Short description
    This function will be used for identify OS architecture bit (32-bit or 64-bit) from the target system.
.DESCRIPTION
   Long description
    2020-11-16 Sukri Created.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-OSArchitecture
{
    Param
    (
    #parameter for query statement for OS Architecture.
        [ValidateNotNullOrEmpty()]
        [String]
        $QueryOSArchitecture = "Select OSArchitecture from Win32_OperatingSystem"
    )

    Begin
    {
        #get OS Architecture.
        $OSArchitecture = (Get-WmiObject -Query "Select OSArchitecture from Win32_OperatingSystem").OSArchitecture
    }
    Process
    {
        #identify which OS Architecture.
        if ($OSArchitecture)
        {
            #for 64-bit OS Architecture.
            if ($OSArchitecture -eq "64-bit")
            {
                $OSArchitectureBit = $OSArchitecture
            }

            #for 32-bit OS Architecture.
            if ($OSArchitecture -ne "64-bit")
            {
                $OSArchitectureBit = $OSArchitecture
            }
        }

        #return null if OS Architecture is empty.
        if (!$OSArchitecture)
        {
            $OSArchitectureBit = $null
        }
    }
    End
    {
        #return true if values available.
        if ($OSArchitectureBit)
        {
            return $true, $OSArchitectureBit
        }

        #return true if values available.
        if ($OSArchitectureBit)
        {
            return $false
        }
    }
}

<#
.Synopsis
   Short description
    This function will be used for validating to check either application already installed or not from the target system.
.DESCRIPTION
   Long description
    2020-11-16 Sukri Created.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
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

<#
.Synopsis
   Short description
    This function will be used for downloading the latest version of binary file from web.
.DESCRIPTION
   Long description
    2020-11-16 Sukri Created.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-TortoiseGitBinary
{
    Param
    (
    #parameter for TortoiseGit installer source url.
        [ValidateNotNullOrEmpty()]
        [String]
        $InstallerSourceUrl
    )

    Begin
    {
        #create the request.
        $HttpRequest = [System.Net.WebRequest]::Create($InstallerSourceUrl)

        #get a response from the site.
        $HttpResponse = $HttpRequest.GetResponse()

        #get the HTTP code as an integer.
        $HttpStatusCode = [int]$HttpResponse.StatusCode

        #throw exception if status code is not 200 (OK).
        if ($HttpStatusCode -ne 200)
        {
            Write-Error -Message "[$InstallerSourceUrl] unable to reach out with status code [$HttpStatusCode]." -ErrorAction Stop
        }

        #get OS architecture - 32 or 64-bit?.
        $OSArchitecture = Get-OSArchitecture

    }
    Process
    {
        #get site contents.
        $SiteContents = Invoke-WebRequest -Uri $InstallerSourceUrl -UseBasicParsing

        #get href link.
        $SiteHrefs = $SiteContents.Links

        #dynamic array for storing TortoiseGit version extracted from site.
        $ApplicationVersion = [system.Collections.ArrayList]@()

        #filter only uri contains the TortoiseGit versions.
        foreach ($SiteHref in $SiteHrefs)
        {
            if ($SiteHref.href -match "^\d.*/$")
            {
                $VersionNumber = $SiteHref.href -replace "/", ""
                $ApplicationVersion.Add($VersionNumber) | Out-Null
            }
        }

        #get latest TortoiseGit installer version.
        $LatestApplicationVersion = $ApplicationVersion[0]

        #get OS architecture for TortoiseGit binary file name.
        if ($OSArchitecture[0] -eq $true)
        {
            #for 32-bit
            if ($OSArchitecture[1] -eq "32-bit")
            {
                #get latest TortoiseGit binary file name.
                $BinaryFileName = "TortoiseGit-$LatestApplicationVersion-32bit.msi"
            }

            #for 64-bit
            if ($OSArchitecture[1] -eq "64-bit")
            {
                #get latest TortoiseGit binary file name.
                $BinaryFileName = "TortoiseGit-$LatestApplicationVersion-64bit.msi"
            }
        }

        #if no available for OS Architecture, then use 32-bit TortoiseGit binary file name.
        if ($OSArchitecture[0] -eq $false)
        {
            #get latest TortoiseGit binary file name.
            $BinaryFileName = "TortoiseGit-$LatestApplicationVersion-32bit.msi"
        }

        #get full path of TortoiseGit binary source url.
        $BinarySourceUrl = "$InstallerSourceUrl/$LatestApplicationVersion/$BinaryFileName"

        #get TortoiseGit download destination directory for specific user.
        $InstallerDownloadDirectory = "$( $env:USERPROFILE )\Downloads\$BinaryFileName"

        #download latest TortoiseGit binary file from site.
        Invoke-WebRequest -Uri $BinarySourceUrl -OutFile $InstallerDownloadDirectory -Verbose -TimeoutSec 60

        #throw exception if no available for TortoiseGit installer.
        if (!$( Test-Path -Path $InstallerDownloadDirectory -PathType Leaf ))
        {
            Write-Error -Message "[$InstallerDownloadDirectory] does not exist." -Category ObjectNotFound -ErrorAction Stop
        }
    }
    End
    {
        if (!$( Test-Path -Path $InstallerDownloadDirectory -PathType Leaf ))
        {
            Write-Error -Message "[$InstallerDownloadDirectory] does not exist." -Category ObjectNotFound -ErrorAction Stop
        }

        #return full path for TortoiseGit installer binary file.
        return $InstallerDownloadDirectory
    }
}

<#
.Synopsis
   Short description
    This function will be used for installing silently the binary file.
.DESCRIPTION
   Long description
    2020-11-16 Sukri Created.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
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

Install-TortoiseGit