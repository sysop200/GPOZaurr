﻿Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This Example shows how to deal with GPOs that have owner that doesn't exists anymore (deleted userr or diff domain) - EmptyOrUnknown
# And also can fix at the same time NotAdministrative - this basically looks for users/groups that are not Domain Admins or Enterprise Admins
# regardless if current user is still Domain Admin or not

$GPOs = Get-GPOZaurrOwner -IncludeSysvol #-GPOName
$GPOs | Format-Table DisplayName, Owner, OwnerSID, OwnerType, SysvolOwner, SysvolSID, SysvolType

Set-GPOZaurrOwner -Type NotAdministrative -Verbose -WhatIf #-LimitProcessing 12

#Set-GPOZaurrOwner -GPOName 'New Group Policy Object' -Verbose -Principal 'przemyslaw.klys' -IncludeSysVol

#$GPOs = Get-GPOZaurrOwner -IncludeSysvol #-GPOName 'New Group Policy Object'
#$GPOs | Format-Table DisplayName, Owner, OwnerSID