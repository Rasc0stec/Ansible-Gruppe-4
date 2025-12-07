<#
.SYNOPSIS
    PowerShell Script to configure a new Windows 11 client VM for the CloudFlix project.
.DESCRIPTION
    This script performs the following actions:
    1. Prompts for a new computer name and the department it belongs to.
    2. Securely prompts for domain administrator credentials.
    3. Sets the primary DNS suffix.
    4. Renames the computer.
    5. Joins the computer to the 'cloudflix.local' domain in the correct OU.
    6. Restarts the computer to apply all changes.
.NOTES
    Author: Gemini for Gruppe 4
    Date: 2025-12-04
    Version: 1.0
.PREREQUISITES
    - Run this script as an Administrator on the Windows 11 client machine.
    - The machine must have network connectivity to a Domain Controller.
    - The Active Directory structure from 'AD_Setup_Aarhus.ps1' must exist.
#>

#================================================================================
# DEL 1: Indsamling af Information
#================================================================================

# Stop scriptet hvis en fejl opstår
$ErrorActionPreference = "Stop"

Write-Host "--- Klargøring af Windows 11 Klient ---" -ForegroundColor Green

# Spørg om computernavn
$newComputerName = Read-Host -Prompt "Indtast det nye computernavn (f.eks. AARH-KLIENT01)"

# Spørg om afdeling for at bygge OU-sti
$department = Read-Host -Prompt "Indtast navnet på afdelingen (f.eks. IT-afdeling, Salgsafdeling)"
$validDepartments = @("Ledelse", "Salgsafdeling", "Indkobsafdeling", "Personaleafdeling", "Administrationsafd", "Okonomiafdeling", "IT-afdeling")

if (-not ($validDepartments -contains $department)) {
    Write-Error "Ugyldig afdeling. Vælg venligst en af følgende: $($validDepartments -join ', ')"
    exit
}

# Spørg sikkert om domæne-admin credentials
$credential = Get-Credential -UserName "$env:USERDOMAIN\Administrator" -Message "Indtast adgangskode for en domæneadministrator"

#================================================================================
# DEL 2: Konfiguration og Domæne-join
#================================================================================

Write-Host "Starter konfiguration..." -ForegroundColor Yellow

# Definer stien til den OU, computeren skal placeres i
# Stien er baseret på den struktur, vi har defineret i AD_Setup_Aarhus.ps1
$domainName = "cloudflix.local"
$siteOU = "Aarhus_C"
$ouPath = "OU=Computere,OU=$department,OU=$siteOU,DC=$($domainName.Split('.')[0]),DC=$($domainName.Split('.')[1])"

Write-Host "  - Mål-OU er: $ouPath"

# Sæt primær DNS Suffix. Dette kan hjælpe med domæne-join.
try {
    Set-DnsClientGlobalSetting -SuffixSearchList "$domainName"
    Write-Host "  - Primær DNS suffix er sat til '$domainName'."
}
catch {
    Write-Warning "  - Kunne ikke sætte DNS suffix. Fortsætter alligevel."
}


# Tjek om computeren allerede er i domænet
$isJoined = (Get-ComputerInfo).Domain -ne $null
if ($isJoined) {
    Write-Warning "Computeren er allerede medlem af et domæne. Scriptet kan ikke fortsætte sikkert."
    exit
}


# Udfør omdøbning og domæne-join i én kommando for at undgå mellemliggende genstart.
Write-Host "  - Omdøber computer til '$newComputerName' og joiner '$domainName'..."
try {
    Add-Computer -NewName $newComputerName -DomainName $domainName -OUPath $ouPath -Credential $credential -Restart -Force
    
    Write-Host "=== SUCCESS ===" -ForegroundColor Green
    Write-Host "Computeren er blevet tilføjet til domænet og genstarter nu."
}
catch {
    Write-Error "Der opstod en fejl under domæne-join. Fejlmeddelelse: $_"
    exit
}

# Scriptet vil stoppe her, da -Restart parameteren tvinger en genstart.
