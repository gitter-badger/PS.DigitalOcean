﻿function Remove-DODroplet
{
<#
.Synopsis
   The Remove-DODomain cmdlet deletes domain information from the Digital Ocean cloud.
.DESCRIPTION
   The Remove-DODomain cmdlet deletes domain information from the Digital Ocean cloud.

   An API key is required to use this cmdlet.
.EXAMPLE
   Remove-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com

   The above command will remove the example.com domain from the bearer account. No object is returned.

.EXAMPLE
   PS C:\>Remove-DODomain -APIKey b7d03a6947b217efb6f3ec3bd3504582 -DomainName example.com, example.org

   The above command will remove the example.com and example.org domains from the bearer account. No object is returned.

.INPUTS
   System.String
        
       This cmdlet requires the API key and domain names to be passed as strings.
.OUTPUTS
   None
.ROLE
   PS.DigitalOcean
.FUNCTIONALITY
   PS.DigitalOcean
#>
    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='High',
                   PositionalBinding=$true)]
    [Alias('rdovm')]
    [OutputType()]
    Param
    (
        # Used to specify the name of the domain name to delete.
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('ID')]
        [UInt64[]]$DropletID,
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
        # API key to access account.
        [Parameter(Mandatory=$false, 
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key','Token')]
        [String]$APIKey = $script:SavedDOAPIKey
    )

    Begin
    {
        if(-not $APIKey)
        {
            throw 'Use Connect-DOCloud to specifiy the API key.'
        }
        [Hashtable]$sessionHeaders = @{'Authorization'="Bearer $APIKey";'Content-Type'='application/json'}
        [Uri]$doApiUri = 'https://api.digitalocean.com/v2/droplets/'
    }
    Process
    {
        foreach($droplet in $DropletID)
        {
            if($Force -or $PSCmdlet.ShouldProcess("Deleting: $droplet."))
            {
                try
                {
                    $doApiUriWithDroplet = '{0}{1}' -f $doApiUri,$droplet
                    Invoke-RestMethod -Method DELETE -Uri $doApiUriWithDroplet -Headers $sessionHeaders -ErrorAction Stop | Out-Null
                }
                catch
                {
                    $errorDetail = $_.Exception.Message
                    Write-Warning "Unable to delete the droplet ID $droplet.`n`r$errorDetail"
                }
            }
        }
    }
}