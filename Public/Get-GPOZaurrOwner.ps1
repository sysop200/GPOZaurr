﻿function Get-GPOZaurrOwner {
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'GPOName')][string] $GPOName,
        [Parameter(ParameterSetName = 'GPOGUID')][alias('GUID', 'GPOID')][string] $GPOGuid,

        [switch] $IncludeSysvol,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [System.Collections.IDictionary] $ADAdministrativeGroups
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        if (-not $ADAdministrativeGroups) {
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
    }
    Process {
        $getGPOZaurrADSplat = @{
            Forest                    = $Forest
            IncludeDomains            = $IncludeDomains
            ExcludeDomains            = $ExcludeDomains
            ExtendedForestInformation = $ForestInformation
        }
        if ($GPOName) {
            $getGPOZaurrADSplat['GPOName']                   = $GPOName
        } elseif ($GPOGuid) {
            $getGPOZaurrADSplat['GPOGUID']                    = $GPOGuid
        }
        Get-GPOZaurrAD @getGPOZaurrADSplat | ForEach-Object -Process {
            Write-Verbose "Get-GPOZaurrOwner - Processing GPO: $($_.DisplayName) from domain: $($_.DomainName)"
            $ACL = Get-ADACLOwner -ADObject $_.GPODistinguishedName -Resolve -ADAdministrativeGroups $ADAdministrativeGroups
            $Object = [ordered] @{
                DisplayName       = $_.DisplayName
                DomainName        = $_.DomainName
                GUID              = $_.GUID
                DistinguishedName = $_.GPODistinguishedName
                Owner             = $ACL.OwnerName
                OwnerSid          = $ACL.OwnerSid
                OwnerType         = $ACL.OwnerType
            }
            if ($IncludeSysvol) {
                $FileOwner = Get-FileOwner -JustPath -Path $_.Path -Resolve
                $Object['SysvolOwner'] = $FileOwner.OwnerName
                $Object['SysvolSid'] = $FileOwner.OwnerSid
                $Object['SysvolType'] = $FileOwner.OwnerType
            }
            [PSCUstomObject] $Object
        }
    }
    End {

    }
}