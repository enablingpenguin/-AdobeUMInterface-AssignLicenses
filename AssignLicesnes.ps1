$SignatureCert = Import-AdobeUMCert -CertThumbprint "‎%%REPLACE%%" -CertStore "LocalMachine"
$ClientInformation = New-ClientInformation -APIKey "%%REPLACE%%" -OrganizationID "%%REPLACE%%@AdobeOrg" -ClientSecret "%%REPLACE%%" -TechnicalAccountID "%%REPLACE%%@techacct.adobe.com" -TechnicalAccountEmail "%%REPLACE%%@techacct.adobe.com"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
Get-AdobeAuthToken -ClientInformation $ClientInformation -SignatureCert $SignatureCert


$users = Get-AdobeUsers -ClientInformation $ClientInformation
$groups = Get-AdobeGroups -ClientInformation $ClientInformation
$studentGroup = "Students"
$staffGroup = "Staff"

$Request = [System.Collections.Generic.List[PSObject]]::New()
$users | ForEach-Object {
    if($_.domain -eq "staffemail.com") {
        if($_.groups -notcontains $staffGroup) {
             $Request.Add($(New-AddToGroupRequest -User $_.username.ToLower() -Groups $staffGroup))
        }
    }elseif($_.domain -eq "studentemail.com") {
        if($_.groups -notcontains $studentGroup) {
            $Request.Add($(New-AddToGroupRequest -User $_.username.ToLower() -Groups $studentGroup))
        }
    }
}
Send-UserManagementRequest -ClientInformation $ClientInformation -Requests $Request
