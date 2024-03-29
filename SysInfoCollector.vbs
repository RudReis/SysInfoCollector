'Licença SysInfoCollector - Anderson Reis - Prática TI e Hermogenes Marinho - Prática TI
'Este software é fornecido gratuitamente, e você pode usá-lo, copiá-lo, modificar, mesclá-lo, publicá-lo, distribuí-lo e/ou vendê-lo, sob as seguintes condições:
'O aviso de direitos autorais e esta permissão devem ser incluídos em todas as cópias ou partes substanciais do software.
'Em nenhuma circunstância, os autores ou detentores de direitos autorais serão responsáveis por qualquer reivindicação, danos ou outra responsabilidade.
'SysInfoCollector é um projeto de código aberto mantido por Anderson Reis - Prática TI.

Option Explicit ' Força a declaração explícita das variáveis

Dim objWMIService, colItems, objItem, ipAddress
Dim colBIOS, objBIOS, serialNumber
Dim colProcessors, objProcessor, cpu, gpuName

Dim objComputerSystem, objComputer, memoriaTotal, hostname, username, memoriaTotalFormatada
Dim objLogicalDisk, objDisk, hdTotal, hdLivre, objLogicalDisks, hdSize, hdFree
Dim objOperatingSystem, objOS, sistemaOperacional, colVideoControllers, objVideoController
Dim colSystemEnclosure, objEnclosure, tipoDispositivo, tipoDispositivoTexto
Dim colComputerSystemProduct, objProduct, modeloMaquina
Dim colMemory, objMemory, tipoMemoria
Dim objExcel, objWorkbook, objWorksheet, caminhoArquivo, mensagem, resposta

' Criando um objeto Excel para salvar as informações
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = False ' Para não exibir o Excel durante a execução

' Adicionando uma nova planilha
Set objWorkbook = objExcel.Workbooks.Add
Set objWorksheet = objWorkbook.Worksheets(1)

' Inicializando a variável de linha
Dim linha
linha = 1

' Função para escrever os rótulos e valores na planilha
Sub EscreverInformacao(rotulo, valor)
    objWorksheet.Cells(1, linha).Value = rotulo
    objWorksheet.Cells(2, linha).Value = valor
    linha = linha + 1
End Sub

' Obtendo informações do endereço IP
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration Where IPEnabled=True")

For Each objItem in colItems
    If Not IsNull(objItem.IPAddress) Then
        ipAddress = objItem.IPAddress(0)
        Exit For
    End If
Next

' Obtendo informações do número de série da BIOS
Set colBIOS = objWMIService.ExecQuery("Select * from Win32_BIOS")

For Each objBIOS in colBIOS
    serialNumber = objBIOS.SerialNumber
Next

' Obtendo informações da placa de vídeo (GPU)
Set colVideoControllers = objWMIService.ExecQuery("Select * from Win32_VideoController")

For Each objVideoController In colVideoControllers
    gpuName = objVideoController.Caption
Next

' Obtendo informações da CPU
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colProcessors = objWMIService.ExecQuery("Select * from Win32_Processor")

For Each objProcessor in colProcessors
    cpu = objProcessor.Name
Next

' Obtendo informações da Memória Total
Set objComputerSystem = objWMIService.ExecQuery("Select * from Win32_ComputerSystem")
For Each objComputer in objComputerSystem
    memoriaTotal = objComputer.TotalPhysicalMemory / 1024^3 ' Converter bytes para gigabytes
    memoriaTotalFormatada = FormatNumber(memoriaTotal, 2) ' Formatar o número com duas casas decimais    
    hostname = objComputer.Caption
    username = objComputer.UserName
Next

' Obtendo informações do HD Livre (unidade C:)
Set objLogicalDisk = objWMIService.ExecQuery("Select * from Win32_LogicalDisk Where DeviceID='C:'")

For Each objDisk in objLogicalDisk
    hdLivre = FormatNumber(objDisk.FreeSpace / (1024^3), 2)
Next

' Obtendo informações do HD Total (unidade C:)
Set objLogicalDisk = objWMIService.ExecQuery("Select * from Win32_LogicalDisk Where DeviceID='C:'")

For Each objDisk in objLogicalDisk
    hdTotal = FormatNumber(objDisk.Size / (1024^3), 2) ' Converter bytes para gigabytes
Next

' Obtendo informações do tipo de dispositivo
Set colSystemEnclosure = objWMIService.ExecQuery("Select * from Win32_SystemEnclosure")

For Each objEnclosure in colSystemEnclosure
    tipoDispositivo = objEnclosure.ChassisTypes(0)
Next

' Mapeando o tipo de dispositivo
Select Case tipoDispositivo
    Case 1
        tipoDispositivoTexto = "Other"
    Case 2
        tipoDispositivoTexto = "Unknown"
    Case 3
        tipoDispositivoTexto = "Desktop"
    Case 4
        tipoDispositivoTexto = "Low Profile Desktop"
    Case 5
        tipoDispositivoTexto = "Pizza Box"
    Case 6
        tipoDispositivoTexto = "Mini Tower"
    Case 7
        tipoDispositivoTexto = "Tower"
    Case 8
        tipoDispositivoTexto = "Portable"
    Case 9
        tipoDispositivoTexto = "Laptop"
    Case 10
        tipoDispositivoTexto = "Notebook"
    Case 11
        tipoDispositivoTexto = "Handheld"
    Case 12
        tipoDispositivoTexto = "Docking Station"
    Case 13
        tipoDispositivoTexto = "All-in-One"
    Case 14
        tipoDispositivoTexto = "Sub Notebook"
    Case 15
        tipoDispositivoTexto = "Space-Saving"
    Case 16
        tipoDispositivoTexto = "Lunch Box"
    Case 17
        tipoDispositivoTexto = "Main System Chassis"
    Case 18
        tipoDispositivoTexto = "Expansion Chassis"
    Case 19
        tipoDispositivoTexto = "Sub Chassis"
    Case 20
        tipoDispositivoTexto = "Bus Expansion Chassis"
    Case 21
        tipoDispositivoTexto = "Peripheral Chassis"
    Case 22
        tipoDispositivoTexto = "Storage Chassis"
    Case 23
        tipoDispositivoTexto = "Rack Mount Chassis"
    Case 24
        tipoDispositivoTexto = "Sealed-Case PC"
    Case Else
        tipoDispositivoTexto = "Desconhecido"
End Select

' Obtendo informações do modelo da máquina
Set colComputerSystemProduct = objWMIService.ExecQuery("Select * from Win32_ComputerSystemProduct")

For Each objProduct in colComputerSystemProduct
    modeloMaquina = objProduct.Name
Next

' Obtendo informações da Memória RAM Livre
Set objOperatingSystem = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")

For Each objOS in objOperatingSystem
    sistemaOperacional = objOS.Caption & " " & objOS.Version
Next

' Obtendo informações de todos os discos rígidos
Set objLogicalDisks = objWMIService.ExecQuery("Select * from Win32_LogicalDisk")

' Inicializando a mensagem com as informações dos discos rígidos
Dim mensagemHD
mensagemHD = ""

For Each objDisk in objLogicalDisks
    ' Pular discos que não são fixos (removíveis, CD-ROM, etc.)
    If objDisk.DriveType = 3 Then
        hdSize = FormatNumber(objDisk.Size / (1024^3), 2)
        hdFree = FormatNumber(objDisk.FreeSpace / (1024^3), 2)

        ' Adicionando informações do HD à mensagem
        mensagemHD = mensagemHD & "" & objDisk.DeviceID & " Total: " & hdSize & " GB" & vbCrLf
    End If
Next

mensagem = "Hostname: " & hostname & vbCrLf & _
           "Endereço IP: " & ipAddress & vbCrLf & _
           "Serial Number (BIOS): " & serialNumber & vbCrLf & _
           "Tipo de Dispositivo: " & tipoDispositivoTexto & vbCrLf & _
           "Usuário Logado: " & username & vbCrLf & _
           "Sistema Operacional: " & sistemaOperacional & vbCrLf & _
           "CPU: " & cpu & vbCrLf & _
           "Memória Total: " & memoriaTotalFormatada & " GB" & vbCrLf & _
           "Modelo da Máquina: " & modeloMaquina & vbCrLf & _
           "Nome da GPU: " & gpuName & vbCrLf & _
           "Informações dos Discos Rígidos:" & vbCrLf & mensagemHD & vbCrLf & _
           "Data e hora da Coleta:" & vbCrLf & Now
' Exibindo a caixa de mensagem com botões de salvar e fechar
resposta = MsgBox(mensagem & vbCrLf & vbCrLf & "Script criado por Anderson Reis - Prática TI" & vbCrLf & vbCrLf & "Deseja salvar essas informações em um arquivo Excel?", vbInformation + vbYesNoCancel, "Informações do Sistema")

' Verificando a resposta do usuário
Select Case resposta
    Case vbYes ' Usuário escolheu "Salvar"
        ' Escrever os rótulos na primeira linha da planilha
        EscreverInformacao "Hostname", hostname
        EscreverInformacao "Usuário Logado", username
        EscreverInformacao "Modelo da Máquina", modeloMaquina
        EscreverInformacao "CPU", cpu
        EscreverInformacao "Memória Ram", memoriaTotalFormatada & "GB"
        ' Iterando sobre os discos rígidos
        For Each objDisk in objLogicalDisks
            ' Pular discos que não são fixos (removíveis, CD-ROM, etc.)
            If objDisk.DriveType = 3 Then
                hdSize = FormatNumber(objDisk.Size / (1024^3), 2)
                hdFree = FormatNumber(objDisk.FreeSpace / (1024^3), 2)

                ' Chamando a função para cada informação do HD
                EscreverInformacao "" & objDisk.DeviceID & " Total:", hdSize & " GB"
            End If
        Next
        EscreverInformacao "Sistema Operacional", sistemaOperacional
        EscreverInformacao "Serial Number (BIOS)", serialNumber
        EscreverInformacao "Nome da GPU", gpuName
        EscreverInformacao "Tipo de Dispositivo", tipoDispositivoTexto
        EscreverInformacao "Endereço IP", ipAddress
        EscreverInformacao "Data e Hora da Coleta", Now



        ' Alinhando ao centro todas as células da primeira linha
        objWorksheet.Rows("1:1").HorizontalAlignment = -4108 ' xlCenter
        objWorksheet.Rows("1:1").VerticalAlignment = -4160 ' xlTop

        ' Ajustando a altura da linha
        objWorksheet.Rows("1:1").RowHeight = 15

        ' Salvando com a data e hora no nome do arquivo
        Dim dataFormatada
        dataFormatada = Replace(Replace(Replace(FormatDateTime(Now, vbShortDate), "/", "-"), ":", "-"), " ", "") _
                        & "_" & Replace(Replace(FormatDateTime(Now, vbLongTime), ":", "-"), " ", "")
        caminhoArquivo = Left(WScript.ScriptFullName, Len(WScript.ScriptFullName) - Len(WScript.ScriptName)) & "" & hostname & "_" & dataFormatada & ".xlsx"
        objWorkbook.SaveAs caminhoArquivo

        ' Fechar o Excel
        objExcel.Quit

        MsgBox "Informações salvas no diretório: '" & caminhoArquivo & "'.", vbInformation, "Script Concluído"

    Case vbNo ' Usuário escolheu "Fechar"
        MsgBox "Operação cancelada pelo usuário.", vbInformation, "Script Concluído"

    Case vbCancel ' Usuário escolheu "Cancelar"
        MsgBox "Script finalizado pelo usuário.", vbInformation, "Script Concluído"
End Select

' Finalizando o script
WScript.Quit
