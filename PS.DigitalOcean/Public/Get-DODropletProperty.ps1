﻿function Get-DODropletProperty
{
<#
.Synopsis
   The Get-DODropletProperty cmdlet pulls droplet property information from the Digital Ocean cloud.
.DESCRIPTION
   The Get-DODropletProperty cmdlet pulls droplet property information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Get-DODroplet -APIKey b7d03a6947b217efb6f3ec3bd3504582

   id           : 3164444
   name         : example.com
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : False
   status       : active
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : 2014-11-14T16:29:21Z
   features     : {backups, ipv6, virtio}
   backup_ids   : {7938002}
   snapshot_ids : {}
   image        : @{id=6918990; name=14.04 x64; distribution=Ubuntu; slug=ubuntu-14-04-x64; public=True; 
                  regions=System.Object[]; created_at=2014-10-17T20:24:33Z; type=snapshot; min_disk_size=20}
   size         : 
   size_slug    : 512mb
   networks     : @{v4=System.Object[]; v6=System.Object[]}
   region       : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=}

   The example above returns the information for all droplets available to the current API bearer.

.EXAMPLE
   PS C:\>Get-DODroplet -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DropletID 3164444, 3164445

   id           : 3164444
   name         : example.com
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : False
   status       : active
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : 2014-11-14T16:29:21Z
   features     : {backups, ipv6, virtio}
   backup_ids   : {7938002}
   snapshot_ids : {}
   image        : @{id=6918990; name=14.04 x64; distribution=Ubuntu; slug=ubuntu-14-04-x64; public=True; 
                  regions=System.Object[]; created_at=2014-10-17T20:24:33Z; type=snapshot; min_disk_size=20}
   size         : 
   size_slug    : 512mb
   networks     : @{v4=System.Object[]; v6=System.Object[]}
   region       : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=}

   id           : 3164445
   name         : example.org
   memory       : 512
   vcpus        : 1
   disk         : 20
   locked       : False
   status       : active
   kernel       : @{id=2233; name=Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic; version=3.13.0-37-generic}
   created_at   : 2014-11-14T16:42:36Z
   features     : {backups, ipv6, virtio}
   backup_ids   : {7938003}
   snapshot_ids : {}
   image        : @{id=6918990; name=14.04 x64; distribution=Ubuntu; slug=ubuntu-14-04-x64; public=True; 
                  regions=System.Object[]; created_at=2014-10-17T20:24:33Z; type=snapshot; min_disk_size=20}
   size         : 
   size_slug    : 512mb
   networks     : @{v4=System.Object[]; v6=System.Object[]}
   region       : @{name=New York 3; slug=nyc3; sizes=System.Object[]; features=System.Object[]; available=}

   The example above returns the information for all the specified droplet IDs available to the current API bearer.

.INPUTS
   System.String
        
       This cmdlet requires the API key to be passed as a string.

   System.UInt64
        
       This cmdlet requires the droplet ID to be passed as a 64-bit, unsiged integer.
.OUTPUTS
   System.Management.Automation.PSCustomObject

       A custome PSObject holding the account info is returned.
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                  PositionalBinding=$true)]
    [Alias('gdovmp')]
    [OutputType([PSCustomObject])]
    Param
    (
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey,
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64]$DropletID
    )

    Begin
    {
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [PSObject]$doReturnInfo = @()
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = "https://api.digitalocean.com/v2/droplets/$DropletID/"
        [Uri]$doApiUriWithKernel = '{0}{1}' -f $doApiUri,'kernels'
        [Uri]$doApiUriWithAction = '{0}{1}' -f $doApiUri,'actions'
        [Uri]$doApiUriWithBackup = '{0}{1}' -f $doApiUri,'backups'
        [Uri]$doApiUriWithSnapshot = '{0}{1}' -f $doApiUri,'snapshots'
    }
    Process
    {
        try
        {
            $doKernelInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithKernel -Headers $sessionHeaders -ErrorAction Stop
            $doActionInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithAction -Headers $sessionHeaders -ErrorAction Stop
            $doBackupInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithBackup -Headers $sessionHeaders -ErrorAction Stop
            $doSnapshotInfo = Invoke-RestMethod -Method GET -Uri $doApiUriWithSnapshot -Headers $sessionHeaders -ErrorAction Stop
        }
        catch
        {
            $errorDetail = $_.Exception.Message
            Write-Warning "Could not pull droplet property information.`n`r$errorDetail"
        }

        $doReturnInfo = @(
            $doKernelInfo.kernels,
            $doActionInfo.actions,
            $doBackupInfo.backups,
            $doSnapshotInfo.snapshots
        )
        #$doReturnInfo = New-Object -TypeName PSObject -Property $doInfo
    }
    End
    {
        Write-Output $doReturnInfo
    }
}