function Remove-ADUserGroups {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)][Microsoft.ActiveDirectory.Management.ADAccount] $User,
        [ValidateSet("Distribution", "Security")][String] $GroupCategory ,
        [ValidateSet("DomainLocal", "Global", "Universal")][String] $GroupScope,
        [string[]] $Groups,
        [switch] $All
    )
    $Object = @()
    $ADgroups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object {$_.Name -ne "Domain Users"}
    if ($ADgroups) {
        if ($All) {
            #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups ', ($ADgroups.Name -join ', '), ' from user ', $User.DisplayName -Color White, Yellow, Green, White, Yellow
            foreach ($Group in $ADgroups) {
                try {
                    Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $Group -Confirm:$false
                    $Object += @{ Status = $true; Output = $Group.Name }
                } catch {
                    $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                    $Object += @{ Status = $false; Output = $Group.Name; Error = $ErrorMessage }
                }
            }
        }
        if ($GroupCategory) {
            $ADGroupsByCategory = $ADgroups | Where { $_.GroupCategory -eq $GroupCategory }
            if ($ADGroupsByCategory) {
                #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups (by category - ', $GroupCategory, ") ", ($ADGroupsByCategory.Name -join ', '), ' from user ', $User.DisplayName -Colo White, Yellow, Green, White, Yellow, White, Blue
                foreach ($Group in $ADGroupsByCategory) {
                    try {
                        Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $Group -Confirm:$false
                        $Object += @{ Status = $true; Output = $Group.Name }
                    } catch {
                        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                        $Object += @{ Status = $false; Output = $Group.Name; Error = $ErrorMessage }
                    }
                }
            }
        }
        if ($GroupScope) {
            $ADGroupsByScope = $ADgroups | Where { $_.GroupScope -eq $GroupScope }
            if ($ADGroupsByScope) {
                #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups (by scope ', " - $GroupScope) ", ($ADGroupsByScope.Name -join ', '), ' from user ', $User.DisplayName -Color White, Yellow, Green, White, Yellow, White, Blue
                foreach ($Group in $ADGroupsByScope) {
                    try {
                        Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $Group -Confirm:$false
                        $Object += @{ Status = $true; Output = $Group.Name }
                    } catch {
                        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                        $Object += @{ Status = $false; Output = $Group.Name; Error = $ErrorMessage }
                    }
                }
            }
        }
        if ($Groups) {
            foreach ($Group in $Groups) {
                $ADGroupsByName = $ADgroups | Where { $_.Name -like $Group }
                if ($ADGroupsByName) {
                    #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups (by name) ', ($ADGroupsByName.Name -join ', '), ' from user ', $User.DisplayName -Color White, Yellow, Green, White, Yellow, White, Yellow
                    try {
                        Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $ADGroupsByName -Confirm:$false
                        $Object += @{ Status = $true; Output = $Group.Name }
                    } catch {
                        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                        $Object += @{ Status = $false; Output = $Group.Name; Error = $ErrorMessage }
                    }
                } else {
                    $Object += @{ Status = $false; Output = $Group.Name; Error = 'Not available on user.' }
                }
            }
        }
    }
    return $Object
}
