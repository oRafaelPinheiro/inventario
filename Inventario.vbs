' Inventario.vbs
' Script para inventário de hardware e software
' Autor Tiago Leal - tiagoleal.ssa@gmail.com
' Modificação: Rafael Pinheiro - rafael10pinheiro@hotmail.com
' Versão Beta 3 - 24/01/2024
 
' O Script está em fase experimental. Aceito sugestões e melhorias.
' O script foi testado em: Windows 10 x64, Windows 7 x64.

'Find: ^' [a-zA-Z]*.*'
'Replace: ':::::::::::::::::::::::::::::::::::::\n':: ::\n':: $0 ::\n':: ::\n':::::::::::::::::::::::::::::::::::::\n'
On Error Resume Next
 
' AVALIA SENTENCA NA MESMA LINHA (TERNARY OPERATOR)
' DÁ ERRO SE RETORNAR OBJETO NULO (sTrue e sFalse) 
Function IIf(bClause, sTrue, sFalse)
    If CBool(bClause) Then
        IIf = sTrue
    Else 
        IIf = sFalse
    End If
End Function
 
' LOCAL ONDE SERÁ SALVO O RELATÓRIO (atentar para a barra no final)
Dim DIRPATH

DIRPATH = Wscript.Arguments.Item(0)

If IsEmpty(DIRPATH) Then

	DIRPATH = ".\"

End If

Set WshNetwork = WScript.CreateObject("WScript.Network") 
FilePath = LCase(DIRPATH & WshNetwork.ComputerName & ".html")
 
Err.Clear
Set fso = CreateObject("scripting.filesystemobject") 
Set oFile = fso.OpenTextFile(FilePath,2,True)
 
If Err.Number <> 0 Then
 
	Wscript.Echo "Erro criando arquivo " & FilePath & ": " & Err.Description & ". Abortando..."
	WScript.Quit
 
End If
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Constantes WMI ::
':: ::
':::::::::::::::::::::::::::::::::::::
Const NET = "Win32_NetworkAdapterConfiguration"
Const OS = "Win32_OperatingSystem"
Const PROC = "Win32_Processor"
Const MEM = "Win32_PhysicalMemory"
Const DISK = "Win32_DiskDrive"
Const PART = "Win32_LogicalDisk"
Const PRINT = "Win32_Printer"
Const DEV = "Win32_PnPEntity"
Const SO = "Win32_OperatingSystem"
Const MB = "Win32_BaseBoard"
Const PC = "Win32_ComputerSystem"
Const UPD = "Win32_QuickFixEngineering"
Const SVC = "Win32_Service"
Const PROCE = "Win32_Process"
Const HKLM = &H80000002
 
' Classes de dispositivos http://msdn.microsoft.com/en-us/library/ff553426%28v=vs.85%29.aspx
Const CNIC = "{4d36e972-e325-11ce-bfc1-08002be10318}" 'adaptadores de rede
Const CVGA = "{4d36e968-e325-11ce-bfc1-08002be10318}" 'adaptadores de vídeo
Const CMMD = "{4d36e96c-e325-11ce-bfc1-08002be10318}" 'som, vídeo e jogo
Const CIDE = "{4d36e96a-e325-11ce-bfc1-08002be10318}" 'controladora IDE
Const CSCSI = "{4d36e97b-e325-11ce-bfc1-08002be10318}" 'controladora SCSI
Const CUSB = "{36fc9e60-c465-11cf-8056-444553540000}" 'controladora USB
Const CMON = "{4d36e96e-e325-11ce-bfc1-08002be10318}" 'monitor
Const CMOUSE = "{4d36e96f-e325-11ce-bfc1-08002be10318}" 'mouse
Const CPORT = "{4d36e978-e325-11ce-bfc1-08002be10318}" 'portas COM e LPT
Const CPROC = "{50127dc3-0f36-415e-a6cc-4cb3be910b65}" 'processador
Const CKEY = "{4d36e96b-e325-11ce-bfc1-08002be10318}" 'teclado
Const CDISK = "{4d36e967-e325-11ce-bfc1-08002be10318}" 'disco
Const CDVD = "{4d36e965-e325-11ce-bfc1-08002be10318}" 'cdrom e dvd
Const CVOL = "{71a27cdd-812a-11d0-bec7-08002be2092f}" 'volumes
 
' Objeto WMI
Set WMI = GetObject("winmgmts:{impersonationlevel=impersonate}!")

' Objeto de data
Set objDateTime = CreateObject("WbemScripting.SWbemDateTime")
 

':::::::::::::::::::::::::::::::::::::
':: ::
':: ' INÍCIO DA PÁGINA ::
':: ::
':::::::::::::::::::::::::::::::::::::
oFile.WriteLine("<HTML>")
oFile.WriteLine("<HEAD>")
oFile.WriteLine("<meta charset='UTF-8'>")
oFile.WriteLine("<TITLE>Inventário da máquina " & WshNetwork.ComputerName & "</TITLE>")
oFile.WriteLine("<style>")
oFile.WriteLine("body{background-color:#DEEDFF;}")
oFile.WriteLine("table,tr,th,td{border:1px solid;}")
oFile.WriteLine("table{width:1024px;}")
oFile.WriteLine("th{background-color:#A1ADBC;}")
oFile.WriteLine("h4{color:red;}")
oFile.WriteLine("</style>")
oFile.WriteLine("</HEAD>")
oFile.WriteLine("<BODY>")
oFile.WriteLine("<center><H1>Inventário da máquina " & WshNetwork.ComputerName & "</H1></center>")
oFile.WriteLine("<center><H4>Gerado em " & Date & " às " & Time & "</H4></center>")
oFile.WriteLine("<center>")
 
' INFORMAÇÕES GERAIS

Set objSO = WMI.ExecQuery("SELECT * FROM " & SO)
 
oFile.WriteLine("<Table border=1>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=2>Informações Gerais</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Hostname</th>")
oFile.WriteLine("<td>" & WshNetwork.ComputerName & "</td>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Usuário</th>")
oFile.WriteLine("<td>" & WshNetwork.UserName & "</td>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Domínio</th>")
oFile.WriteLine("<td>" & WshNetwork.UserDomain & "</td>")
oFile.WriteLine("</tr>")
 
WScript.DisconnectObject(WshNetwork)
 
For Each oSO In objSO
 
    If Not IsNull(oSO) Then

        objDateTime.Value = oSO.InstallDate
        dataInstalacao = objDateTime.GetVarDate

        objDateTime.Value = oSO.LastBootUpTime
        dataBoot = objDateTime.GetVarDate        
    
        oFile.WriteLine("<tr>")
        oFile.WriteLine("<th>SO</th>")
        oFile.WriteLine("<td>" & oSO.Caption & " Service Pack " & oSO.ServicePackMajorVersion & "</td>")
        oFile.WriteLine("</tr>")
        oFile.WriteLine("<tr>")
        oFile.WriteLine("<th>Versão do SO</th>")
        oFile.WriteLine("<td>" & oSO.Version & "</td>")
        oFile.WriteLine("</tr>")
        oFile.WriteLine("<tr>")
        oFile.WriteLine("<th>Data de Instalação</th>")
        oFile.WriteLine("<td>" & dataInstalacao & "</td>")
        oFile.WriteLine("</tr>")
        oFile.WriteLine("<tr>")
        oFile.WriteLine("<th>Uptime</th>")
        oFile.WriteLine("<td>" & DateDiff("d",dataBoot,Now()) & " dia(s)</td>")
        oFile.WriteLine("</tr>")
    
    End If
 
Next

WScript.DisconnectObject(objSO)

Set objPC = WMI.ExecQuery("SELECT * FROM " & PC)

For Each oPC In objPC
 
If Not IsNull(oPC) Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Fabricante</th>")
oFile.WriteLine("<td>" & IIf(IsNull(oPC.Manufacturer),"N/A",oPC.Manufacturer) & "</td>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Modelo</th>")
oFile.WriteLine("<td>" & IIf(IsNull(oPC.Model),"N/A",oPC.Model) & "</td>")
oFile.WriteLine("</tr>")
 
End If
Next
 
oFile.WriteLine("</Table>")
 
WScript.DisconnectObject(objPC)


':::::::::::::::::::::::::::::::::::::
':: ::
':: ' PLACA MÃE ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objMB = WMI.ExecQuery("SELECT * FROM " & MB)
 
oFile.WriteLine("<br>")
 oFile.WriteLine("<Table border=1>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=2>Placa Mãe</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
 
For Each oMB In objMB
 
If Not IsNull(oMB) Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Fabricante</th>")
oFile.WriteLine("<td>" & IIf(IsNull(oMB.Manufacturer),"N/A",oMB.Manufacturer) & "</td>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Modelo</th>")
oFile.WriteLine("<td>" & IIf(IsNull(oMB.Model),"N/A",oMB.Model) & "</td>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Produto</th>")
oFile.WriteLine("<td>" & IIf(IsNull(oMB.Product),"N/A",oMB.Product) & "</td>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Serial</th>")
oFile.WriteLine("<td>" & IIf(IsNull(oMB.SerialNumber),"N/A",oMB.SerialNumber) & "</td>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>SKU</th>")
oFile.WriteLine("<td>" & IIf(IsNull(oMB.SKU),"N/A",oMB.SKU) & "</td>")
oFile.WriteLine("</tr>")
 
End If
Next
 
oFile.WriteLine("</Table>")
 
WScript.DisconnectObject(objMB)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' CONFIGURAÇÕES DE REDE ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objNet = WMI.ExecQuery("SELECT * FROM " & NET & " WHERE IPEnabled = True")

oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=5>Configurações de Rede</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>IP</th>")
oFile.WriteLine("<th>Máscara de Subrede</th>")
oFile.WriteLine("<th>Gateway</th>")
oFile.WriteLine("<th>DNS</th>")
oFile.WriteLine("<th>MAC</th>")
oFile.WriteLine("</tr>")
 
For Each oNet In objNet
 
If Not IsNull(oNet) Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oNet.IPAddress(0) & "</td>")
oFile.WriteLine("<td>" & oNet.IPSubnet(0) & "</td>")
 
If IsArray(oNet.DefaultIPGateway) Then
 
oFile.WriteLine("<td>" & oNet.DefaultIPGateway(0) & "</td>")
 
Else
 
oFile.WriteLine("<td>N/A</td>")
 
End If
 
If IsArray(oNet.DNSServerSearchOrder) Then
 
oFile.WriteLine("<td>")
 
For i=0 To UBound(oNet.DNSServerSearchOrder) Step 1
 
oFile.WriteLine(oNet.DNSServerSearchOrder(i) & "<br>")
 
Next
 
oFile.WriteLine("</td>")
 
Else
 
oFile.WriteLine("<td>N/A</td>")
 
End If
 
oFile.WriteLine("<td>" & oNet.MACAddress & "</td>")
oFile.WriteLine("</tr>")
 
End If
Next
 
oFile.WriteLine("</table>")
 
WScript.DisconnectObject(objNet)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' MEMÓRIA ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objMem = WMI.ExecQuery("SELECT DeviceLocator,Capacity FROM " & MEM)
 
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=2>Memória</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Local</th>")
oFile.WriteLine("<th>Quantidade (MB)</th>")
oFile.WriteLine("</tr>")
 
Dim totalMemory
 
For Each oMem In objMem
 
If Not IsNull(oMem) Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oMem.DeviceLocator & "</td>")
oFile.WriteLine("<td>" & oMem.Capacity/1024/1024 & "</td>")
oFile.WriteLine("</tr>")
 
totalMemory = totalMemory + oMem.Capacity/1024/1024
 
End If
Next
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=2>Total: " & totalMemory &"</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("</table>")
 
WScript.DisconnectObject(objMem)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' PROCESSADOR ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objProc = WMI.ExecQuery("SELECT Name,MaxClockSpeed,NumberOfCores,L2CacheSize FROM " & PROC)
 
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=5>Processador</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Nome</th>")
oFile.WriteLine("<th>Clock (Mhz)</th>")
oFile.WriteLine("<th>Núcleo</th>")
oFile.WriteLine("<th>Cache L2 (KB)</th>")
oFile.WriteLine("</tr>")
 
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!//./root/default:StdRegProv")
 
objReg.GetStringValue HKLM,"HARDWARE\DESCRIPTION\System\CentralProcessor\0","ProcessorNameString",strProcName
 
For Each oProc In objProc
 
If Not IsNull(oProc) Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & strProcName & "</td>")
oFile.WriteLine("<td>" & oProc.MaxClockSpeed & "</td>")
oFile.WriteLine("<td>" & oProc.NumberOfCores & "</td>")
oFile.WriteLine("<td>" & oProc.L2CacheSize & "</td>")
oFile.WriteLine("</tr>")
 
End If
Next
 
oFile.WriteLine("</table>")
 
WScript.DisconnectObject(objProc)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' DISCO e PARTIÇÕES ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDisk = WMI.ExecQuery("SELECT * FROM " & DISK & " Where InterfaceType <> 'USB'")
 
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=4>Disco</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Modelo</th>")
oFile.WriteLine("<th>Capacidade (GB)</th>")
oFile.WriteLine("<th colspan=4>Partições</th>")
oFile.WriteLine("</tr>")
 
For Each oDisk In objDisk
 
If Not IsNull(oDisk) Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDisk.Model & "</td>")
oFile.WriteLine("<td>" & Round(oDisk.Size/(1024^3)) & "</td>")
oFile.WriteLine("<td colspan=4>" & oDisk.Partitions & "</td>")
oFile.WriteLine("</tr>")
 
End If
Next
 
WScript.DisconnectObject(objDisk)
 
Set objPart = WMI.ExecQuery("SELECT * FROM " & PART & " WHERE DriveType=3")
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=4>Partições</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Unidade</th>")
oFile.WriteLine("<th>Tamanho (GB)</th>")
oFile.WriteLine("<th>Espaço Livre (GB)</th>")
oFile.WriteLine("<th>Tipo</th>")
oFile.WriteLine("</tr>")
 
For Each oPart In objPart
 
If Not IsNull(oPart) Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oPart.Name & "</td>")
oFile.WriteLine("<td>" & Round(oPart.Size/(1024^3)) & "</td>")
oFile.WriteLine("<td>" & Round(oPart.FreeSpace/(1024^3)) & "</td>")
oFile.WriteLine("<td>" & oPart.FileSystem & "</td>")
oFile.WriteLine("</tr>")
 
End If
Next
 
oFile.WriteLine("</table>")
 
WScript.DisconnectObject(objPart)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' DISPOSITIVOS ::
':: ::
':::::::::::::::::::::::::::::::::::::
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=4>Dispositos</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Tipo</th>")
oFile.WriteLine("<th>Nome</th>")
oFile.WriteLine("<th>Fabricante</th>")
oFile.WriteLine("<th>Descrição</th>")
oFile.WriteLine("</tr>")
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Placas de Rede ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CNIC & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Rede</th>")
oFile.WriteLine("</tr>")
 
For Each nic In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & nic.Name & "</td>")
oFile.WriteLine("<td>" & nic.Manufacturer & "</td>")
oFile.WriteLine("<td>" & nic.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Placas de Vídeo ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CVGA & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Vídeo</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Multimídia (som, vídeo e jogo) ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CMMD & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Som, vídeo e jogo</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Controladora IDE/ATAPI ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CIDE & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Controladora IDE</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Conroladora SCSI/RAID ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CSCSI & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Controladora SCSI/RAID</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Controladora USB ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CUSB & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Controladora USB</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Monitor ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CMON & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Monitor</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Mouse e teclado ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CMOUSE & "' Or ClassGuid = '" & CKEY & "'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Mouse e teclado</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Portas serial e paralela ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CPORT & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Portas COM e LPT</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Processador ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CPROC & "'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Processador</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Disco ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CDISK & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Disco</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Cdrom e DVDrom ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CDVD & "' And Manufacturer <> 'Microsoft'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">DVD/CDROM</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Volumes ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objDev = WMI.ExecQuery("SELECT ClassGuid,Caption,Description,Manufacturer,Name FROM " & DEV & " WHERE ClassGuid = '" & CVOL & "'")
 
If Not IsNull(objDev) And objDev.Count > 0 Then
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<th rowspan=" & objDev.Count + 1 & ">Volumes</th>")
oFile.WriteLine("</tr>")
 
For Each oDev In objDev
 
oFile.WriteLine("<tr>")
oFile.WriteLine("<td>" & oDev.Name & "</td>")
oFile.WriteLine("<td>" & oDev.Manufacturer & "</td>")
oFile.WriteLine("<td>" & oDev.Description & "</td>")
oFile.WriteLine("</tr>")
 
Next
End If
 
WScript.DisconnectObject(objDev)
 
oFile.WriteLine("</table>")


':::::::::::::::::::::::::::::::::::::
':: ::
':: DIRETÓRIOS COMPARTILHADOS
':: ::
':::::::::::::::::::::::::::::::::::::
Set objShares = WMI.ExecQuery("SELECT * FROM Win32_Share")
If Not IsNull(objDev) And objDev.Count > 0 Then

oFile.Write("<br>")
oFile.Write("<table border=1 style=text-align:center>")
oFile.Write("<tr>")
oFile.Write("<th colspan=2>Diretórios Compartilhados</th>")
oFile.Write("</tr>")
oFile.Write("<tr>")
oFile.Write("<th>Nome</th>")
oFile.Write("<th>Caminho</th>")
oFile.Write("</tr>")

For Each objShare In objShares
    oFile.Write("<tr>")
    oFile.Write("<td>" & objShare.Name & "</td>")
    oFile.Write("<td>" & objShare.Path & "</td>")
    oFile.Write("</tr>")
Next
End If

WScript.DisconnectObject(objDev)
oFile.WriteLine("</table>")

':::::::::::::::::::::::::::::::::::::
':: ::
':: Listagem de drivers mapeados
':: ::
':::::::::::::::::::::::::::::::::::::
oFile.WriteLine("<H2>Drivers Mapeados</H2>")
oFile.WriteLine("<table>")
oFile.WriteLine("<tr><th>Letra</th><th>Nome do Driver</th></tr>")

' Criação do objeto de rede
Set objNetwork = CreateObject("WScript.Network")

' Obtém a coleção de drivers mapeados
Set colDrives = objNetwork.EnumNetworkDrives

' Itera sobre os drivers mapeados e os adiciona à tabela HTML
For i = 0 to colDrives.Count - 1 Step 2
    oFile.WriteLine("<tr>")
    oFile.WriteLine("<td>" & colDrives(i) & "</td>")
    oFile.WriteLine("<td>" & colDrives(i + 1) & "</td>")
    oFile.WriteLine("</tr>")
Next
WScript.DisconnectObject(objDev)
oFile.WriteLine("</table>")


':::::::::::::::::::::::::::::::::::::
':: ::
':: ' Listagem de tarefas agendadas ::
':: ::
':::::::::::::::::::::::::::::::::::::
oFile.WriteLine("<H2>Tarefas Agendadas</H2>")
oFile.WriteLine("<table>")
oFile.WriteLine("<tr><th>Nome</th><th>Estado</th><th>Ação</th></tr>")

' Criação do objeto de serviço de Agendador de Tarefas
Set objSchedule = CreateObject("Schedule.Service")

' Conexão ao serviço de Agendador de Tarefas local no computador
objSchedule.Connect

' Criação do objeto de root folder
Set rootFolder = objSchedule.GetFolder("\")

' Obtém a coleção de tarefas agendadas
Set tasks = rootFolder.GetTasks(0)

' Criação do objeto Shell para executar comandos PowerShell
Set objShell = CreateObject("WScript.Shell")

' Itera sobre as tarefas e as adiciona à tabela HTML
For Each task In tasks
    oFile.WriteLine("<tr>")
    oFile.WriteLine("<td>" & task.Name & "</td>")
    oFile.WriteLine("<td>" & task.State & "</td>")
    
    ' Executa comando PowerShell para obter informações da ação da tarefa
    strCommand = "powershell -Command ""& { (Get-ScheduledTask -TaskName '" & task.Name & "').Actions.Execute }"""
    Set objExec = objShell.Exec(strCommand)
    strActionInfo = objExec.StdOut.ReadAll
    
    If Trim(strActionInfo) <> "" Then
        oFile.WriteLine("<td>" & Replace(strActionInfo, vbCrLf, "<br>") & "</td>")
    Else
        oFile.WriteLine("<td>N/A</td>")
    End If
    
    oFile.WriteLine("</tr>")
Next

WScript.DisconnectObject(objDev)
oFile.WriteLine("</table>")

 
':::::::::::::::::::::::::::::::::::::
':: ::
':: ' PROGRAMAS ::
':: ::
':::::::::::::::::::::::::::::::::::::
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=4>Programas Instalados</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Nome</th>")
oFile.WriteLine("<th>Versão</th>")
oFile.WriteLine("<th>Tamanho</th>")
oFile.WriteLine("<th>Fabricante</th>")
oFile.WriteLine("</tr>")
 
strComputer = "."
strKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
strDisplayName = "DisplayName"
strQDisplayName = "QuietDisplayName"
strVersionMajor = "VersionMajor"
strVersionMinor = "VersionMinor"
strEstimatedSize = "EstimatedSize"
strPublisher = "Publisher"
 
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!//" & strComputer & "/root/default:StdRegProv")
 
objReg.EnumKey HKLM,strKey,arrSubKeys
 
For i=0 To UBound(arrSubKeys) Step 1
 
intRet1 = objReg.GetStringValue(HKLM, strKey & arrSubKeys(i), strDisplayName, strNome)
 
If intRet1 = 0 Then
 
' Nome
oFile.WriteLine("<tr>")
 
If strNome <> "" Then
 
oFile.WriteLine("<td>" & strNome & "</td>")
 
Else
 
oFile.WriteLine("<td>N/A</td>")
 
End If
 
' Versão
objReg.GetDWORDValue HKLM,strKey & arrSubKeys(i), strVersionMajor, intVersao
objReg.GetDWORDValue HKLM,strKey & arrSubKeys(i), strVersionMinor, intVersaoMenor
 
If intVersao <> "" Then
 
oFile.WriteLine("<td>" & intVersao & "." & intVersaoMenor & "</td>")
 
Else
 
oFile.WriteLine("<td>N/A</td>")
 
End If
 
' Tamanho
objReg.GetDWORDValue HKLM,strKey & arrSubKeys(i), strEstimatedSize, intTamanho
 
If intTamanho <> "" Then
 
oFile.WriteLine("<td>" & Round(intTamanho/1024,2) &"MB</td>")
 
Else
 
oFile.WriteLine("<td>N/A</td>")
 
End If
 
' Fabricante
objReg.GetStringValue HKLM,strKey & arrSubKeys(i), strPublisher, strFabricante
 
If strFabricante <> "" Then
 
oFile.WriteLine("<td>" & strFabricante &"</td>")
 
Else
 
oFile.WriteLine("<td>N/A</td>")
 
End If
 
oFile.WriteLine("</tr>")
 
End If
Next
 
WScript.DisconnectObject(objReg)
 
oFile.WriteLine("</table>")

':::::::::::::::::::::::::::::::::::::
':: ::
':: ' UPDATES e HOTFIX ::
':: ::
'::::::::::::::::::::::::::::::::::::: 
Set objUPD = WMI.ExecQuery("SELECT Description,HotFixID,InstalledOn FROM " & UPD)
 
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=5>Updates</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Tipo</th>")
oFile.WriteLine("<th>ID</th>")
oFile.WriteLine("<th>Data Instalação</th>")
oFile.WriteLine("</tr>")
 
For Each oUPD In objUPD
 
    If Not IsNull(oUPD) Then
    
        oFile.WriteLine("<tr>")        
        oFile.WriteLine("<td>" & IIf(IsNull(oUPD.Description),"N/A",oUPD.Description) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(oUPD.HotFixID),"N/A",oUPD.HotFixID) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(oUPD.InstalledOn),"N/A",oUPD.InstalledOn) & "</td>")
        oFile.WriteLine("</tr>")
    
    End If
 
Next
 
oFile.WriteLine("</Table>")
 
WScript.DisconnectObject(objUPD)

':::::::::::::::::::::::::::::::::::::
':: ::
':: ' SERVIÇOS ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objSVC = WMI.ExecQuery("SELECT Name,StartMode,State,Status FROM " & SVC)
 
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=5>Serviços do Windows</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Nome</th>")
oFile.WriteLine("<th>Modo de Inic.</th>")
oFile.WriteLine("<th>Estado</th>")
oFile.WriteLine("<th>Status</th>")
oFile.WriteLine("</tr>")
 
For Each oSVC In objSVC
 
    If Not IsNull(oSVC) Then
    
        oFile.WriteLine("<tr>")        
        oFile.WriteLine("<td>" & IIf(IsNull(oSVC.Name),"N/A",oSVC.Name) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(oSVC.StartMode),"N/A",oSVC.StartMode) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(oSVC.State),"N/A",oSVC.State) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(oSVC.Status),"N/A",oSVC.Status) & "</td>")
        oFile.WriteLine("</tr>")
    
    End If
 
Next
 
oFile.WriteLine("</Table>")
 
WScript.DisconnectObject(objSVC)

':::::::::::::::::::::::::::::::::::::
':: ::
':: ' PROCESSO ::
':: ::
':::::::::::::::::::::::::::::::::::::
Set objPROCE = WMI.ExecQuery("SELECT Caption,CommandLine,ExecutablePath,CreationDate,ProcessID FROM " & PROCE)
 
oFile.WriteLine("<br>")
oFile.WriteLine("<table border=1 style=text-align:center;table-layout:fixed>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th colspan=6>Processos em Execução</th>")
oFile.WriteLine("</tr>")
oFile.WriteLine("<tr>")
oFile.WriteLine("<th>Nome</th>")
oFile.WriteLine("<th>Local</th>")
oFile.WriteLine("<th>Comando</th>")
oFile.WriteLine("<th>Início Exec.</th>")
oFile.WriteLine("<th>PID</th>")
oFile.WriteLine("<th>Usuário</th>")
oFile.WriteLine("</tr>")
 
For Each oPROCE In objPROCE
 
    If Not IsNull(oPROCE) Then

        objDateTime.Value = oPROCE.CreationDate
        dataInicio = objDateTime.GetVarDate

        oPROCE.GetOwner strUser, strDomain
    
        oFile.WriteLine("<tr>")        
        oFile.WriteLine("<td>" & IIf(IsNull(oPROCE.Caption),"N/A",oPROCE.Caption) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(oPROCE.ExecutablePath),"N/A",oPROCE.ExecutablePath) & "</td>")
        oFile.WriteLine("<td style=word-wrap:break-word;>" & IIf(IsNull(oPROCE.CommandLine),"N/A",oPROCE.CommandLine) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(dataInicio),"N/A",dataInicio) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(oPROCE.ProcessID),"N/A",oPROCE.ProcessID) & "</td>")
        oFile.WriteLine("<td>" & IIf(IsNull(strUser),"N/A",strDomain & "\" & strUser) & "</td>")
        oFile.WriteLine("</tr>")
    
    End If
 
Next
 
oFile.WriteLine("</Table>")
 
WScript.DisconnectObject(objPROCE)

oFile.WriteLine("</center>")
oFile.WriteLine("</BODY>")
oFile.WriteLine("</HTML>")
 
WScript.DisconnectObject(WMI)
 
oFile.Close()
 
WScript.DisconnectObject(oFile)
WScript.DisconnectObject(fso)

Wscript.Echo "Inventario salvo em " & FilePath