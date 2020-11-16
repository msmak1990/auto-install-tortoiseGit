# auto-install-tortoiseGit
* 2020-11-16 Sukri Created.
* 2020-11-16 Sukri Added on what script does.
* 2020-11-16 Sukri Added on how to run the script.
* 2020-11-16 Sukri Added its function descriptions.

---

### Description:
> * PowerShell script to install silently TortoiseGit binary (Windows 10 + PS ver5.1.x) with getting latest version from its site. All done by automated way.

---

### Below are steps on what script does:

1. Identify OS architecture for target system (Windows platform that you want to install with TortoiseGit) i.e.: 32-bit or 64-bit.
2. Identify TortoiseGit either installed or not for target system. If not yet installed, then proceed to download at step #3
3. Download TortoiseGit binary file from its site and temporarily locate into C:\Users\\[userprofile]\Downloads
4. Install TortoiseGit binary to target system silently.

---  

### How to run this script.

1. Go to the cloned directory which contain both Install-TortoiseGit.cmd and Install-TortoiseGit.ps1 files.
2. Right-click on Install-TortoiseGit.cmd file and run as administrator.

Note: both of files need to locate the same directory or folder.

---

### There are four functions involved:

1. Get-OSArchitecture
> * This function used for identifying OS architecture for the target system (Windows platform) i.e.: 32-bit or 64-bit

2. Get-TortoiseGit
> * This function used for validating the existing of installed TortoiseGit from target system.

3. Get-TortoiseGitBinary
> *  This function used for downloading the latest version of TortoiseGit from its site.

4. Install-TortoiseGit

> * This function used for installing silently the TortoiseGit binary from temporary download directory. i.e.: C:\Users\\[UserProfile]\Downloads
