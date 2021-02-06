<#
.Synopsis
   Short description
    This script will be used for downloading the latest TortoiseGit version from its official site.
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