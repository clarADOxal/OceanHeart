#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

Clear-Host
write-host -fore red "██████╗░███████╗░█████╗░██████╗░    ███╗░░░███╗░█████╗░███╗░░██╗    ░█████╗░██╗░░██╗███████╗░██████╗████████╗"
write-host -fore red "██╔══██╗██╔════╝██╔══██╗██╔══██╗    ████╗░████║██╔══██╗████╗░██║    ██╔══██╗██║░░██║██╔════╝██╔════╝╚══██╔══╝"
write-host -fore red "██║░░██║█████╗░░███████║██║░░██║    ██╔████╔██║███████║██╔██╗██║    ██║░░╚═╝███████║█████╗░░╚█████╗░░░██║░░░"
write-host -fore red "██║░░██║██╔══╝░░██╔══██║██║░░██║    ██║╚██╔╝██║██╔══██║██║╚████║    ██║░░██╗██╔══██║██╔══╝░░░╚═══██╗░░░██║░░░"
write-host -fore red "██████╔╝███████╗██║░░██║██████╔╝    ██║░╚═╝░██║██║░░██║██║░╚███║    ╚█████╔╝██║░░██║███████╗██████╔╝░░░██║░░░"
write-host -fore red "╚═════╝░╚══════╝╚═╝░░╚═╝╚═════╝     ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝    ░╚════╝░╚═╝░░╚═╝╚══════╝╚═════╝░░░░╚═╝░░░"
write-host "ThreatHunting : Find Information about IPs (file) on AbuseIpDb service"
write-host "Version : 0.4"
$Creation_Date = "12:50 04/10/2026"
Write-Host "Usage :" -ForegroundColor Yellow
Write-Host " .\PS_AbuseIpDb.ps1 -Path <iplist.txt>"
Write-Host " .\PS_AbuseIpDb.ps1 -Path <iplist.txt> -Verbose"
Write-Host ""

write-verbose $path


# Manage Out Folder
$OutputDir = ".\out"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Manage In Folder
if (-not (Test-Path $path)) {
    write-host -fore red "$path doen't Exist , try another path"
	sleep;
	exit;
}


# Sélectionne un fichier texte et récupère son chemin complet
$thefile = (Get-Item -Path $Path).FullName
write-verbose $thefile

# Affiche le chemin du fichier sélectionné
Write-Host -ForegroundColor Blue "Fichier sélectionné : $thefile"

############################# VVVVVVV ####################
#Créer un compte: 
#https://www.abuseipdb.com/account/api
#Documentation de l'API:
#https://docs.abuseipdb.com/#introduction

$apikey=''

############################# AAAAAAA ####################

# Définit un en-tête pour l'API AbuseIPDB
$headers = @{
    'Key' = $apikey
    'Accept' = 'application/json'
}

# Crée une liste pour stocker les résultats
$results = @()

# Lit chaque ligne du fichier et interroge l'API
Get-Content -Path $thefile | ForEach-Object {
    $ip = $_.Trim()
    
    if ($ip -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        Write-Host -ForegroundColor Green "Vérification de l'adresse IP : $ip"
        
        $uri = "https://api.abuseipdb.com/api/v2/check?ipAddress=$ip"
        
        try {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers
            $results += $response.data
			write-verbose $response.data
        }
        catch {
            Write-Host -ForegroundColor Red "Erreur lors de la requête pour l'IP $ip : $($_.Exception.Message)"
        }
    } else {
        Write-Host -ForegroundColor Yellow "Adresse IP non valide ignorée : $ip"
    }
}

# Affiche les résultats dans une grille interactive si des résultats sont présents
if ($results.Count -gt 0) {
    $results | Out-GridView -Title "Résultats des vérifications"
} else {
    Write-Host -ForegroundColor Red "Aucun résultat à afficher."
}

# Génère un nom de fichier unique basé sur la date et l'heure
$name_file = Get-Date -Format "yyyy.MM.dd_HH.mm.ss"
$path = ".\$name_file.csv"

# Exporte les résultats au format CSV
if ($results.Count -gt 0) {
    $results | Select-Object ipAddress, isPublic, ipVersion, isWhitelisted, abuseConfidenceScore, countryCode, usageType, isp, domain, @{Name='hostnames';Expression={$_.hostnames -join ','}}, isTor, totalReports, numDistinctUsers, lastReportedAt | Export-Csv -Path $path -Delimiter ';' -NoTypeInformation -Force
    Write-Host -ForegroundColor Cyan "Les résultats ont été sauvegardés dans le fichier : $path"
} else {
    Write-Host -ForegroundColor Red "Aucun résultat à sauvegarder."
}
