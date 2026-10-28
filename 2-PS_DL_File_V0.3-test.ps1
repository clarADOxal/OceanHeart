#/////////////////////////////////////////////////////////////////////////////////////////////
$Name="DL_File"
f$version="0.3 test"
$Todo=""
$Todo+="voir les caractères interdit dans une URL ou fichier système et en faire un separateur titre/url"
$Todo+="Si l'URL comporte la chaine %2F soit "/" , n'utiliser que ce qui est après pour le filename"

clear
write-host "##########################"
write-host "####    $Name       #####"
write-host "#### Version $version     #####"
write-host "##########################"
write-host ""

#/////////////////////////////////////////////////////////////////////////////////////////////

#Select a source file
$proj = Read-Host -Prompt 'Glissez ici, le listing d ip à importer :'
write-host "======================================"
$listingurl=$proj -replace '"', ""

###############################################################################
#a desactiver à la fin de création du script
$listingurl = get-content ./url.txt
###############################################################################

#$listingurl = get-content ./url.txt

#Count file to download
$cpt=0

#Create out folder with date
$name_folder=Get-Date -Format "yyyy.MM.dd_HH.mm.ss"
If(!(test-path $name_folder)){New-Item -Path $name_folder -ItemType Directory | Out-Null}

#Reset filename to null
	$filename=""

#For each line into source file
Foreach($url in $listingurl) 
{
#New Line
#write-host -fore green "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


#Increment count
		$cpt++
#write-host -fore green $cpt

#Show Line
#write-host -fore green "Line : " $url

#Reset filename to null
#	$filename=""

#Don't work with empty line
	if($url -ne "")
		{
#write-host -fore green "UnEmpty Line"

#If line don't contain http, take line as filename
		if($url -notlike "http*")
			{
#write-host -fore green "Perhaps a FileName : "
			#write-host -fore red "Not an URL. Take as FileName"
			#$url="http://"+$url
			$filename=$url
#write-host -fore green "FileName : " $filename
			}

		else
			{

#	Nom du fichier
#	$filename= Split-Path $url -leaf
#	OR

#If filename already undefined (with missing http) Use the URL's filename.
			if($filename -eq "")
				{
				$filename = $url.Substring($url.LastIndexOf("/") + 1)
				}
#write filename (last value of url or line define into source file
			#write-host -fore blue $filename

$extension = $url.Substring($url.LastIndexOf(".") + 1)
#write-host -fore green "extension : " $extension

#remove argument into URL with forbidden caracters
			$filename = $filename.split('?')[0]


#download file with defined filename
$newname=""
#$newname = $cpt+"_"+$filename+"."+$extension

			Invoke-WebRequest -Uri $url -OutFile $name_folder\$cpt"_"$filename"."$extension
write-host -fore blue "========================================================="
write-host -fore blue "Download : " $url
write-host -fore blue "As : " $name_folder"\"$cpt"_"$filename"."$extension 
echo $url + ";" + $name_folder + "\" + $cpt + "_" + $filename + "." + $extension >> $name_folder\logs.txt

write-host -fore blue "========================================================="


#save log of download into output folder
			$name_folder + " " + $url >> $name_folder.log

#reset filename for next file to download
			$filename=""
		}
	}
	else {
		#write-host -fore red "Empty Line"
		$filename=$url
	}
}