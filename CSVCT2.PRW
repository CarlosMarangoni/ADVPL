#include 'rwmake.ch'
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

User Function CSVCT2()

	Local cLinha := "" 
    Local aCampos := {}
	Local aItens := {}
	Local aDados := {}
	Local nTamLinha := 0
	Local nTamArq:= 0
	Local cTitulo1		:= "Selecione o arquivo"
	Local cExtens     	:= "Arquivo CSV | *.csv"
    Local lPrimlin := .T.
	Local nLinhaMax := SUPERGETMV("MV_NUMLIN",.F.,99)
	Local cData
	Local nLinha :=1
	Local nQtdeLinha := 1
	Private nLote
	
	ExParam() //Chama a tela de perguntas para receber nº do loteu_csvct2


	cArqImpor := cGetFile(cExtens,cTitulo1,,"C:\",.T.)

	//Valida arquivo
	If !file(cArqImpor)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return
	Else     
		//+---------------------------------------------------------------------+
		//| Abertura do arquivo texto                                           |
		//+---------------------------------------------------------------------+
		nHdl := fOpen(cArqImpor)

		If nHdl == -1 
			IF FERROR()== 516 
				ALERT("Feche a planilha que gerou o arquivo.")
			EndIF
		EndIf

		//+---------------------------------------------------------------------+
		//| Verifica se foi possível abrir o arquivo                            |
		//+---------------------------------------------------------------------+
		If nHdl == -1
			cMsg := "O arquivo de nome "+cArqImpor+" nao pode ser aberto! Verifique os parametros."
			MsgAlert(cMsg,"Atencao!")
			Return
		Endif

		//+---------------------------------------------------------------------+
		//| Posiciona no Inicio do Arquivo                                      |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)

		//+---------------------------------------------------------------------+
		//| Traz o Tamanho do Arquivo TXT                                       |
		//+---------------------------------------------------------------------+
		nTamArq:=FSEEK(nHdl,0,2)

		//+---------------------------------------------------------------------+
		//| Posicona novamemte no Inicio                                        |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)

		//+---------------------------------------------------------------------+
		//| Fecha o Arquivo                                                     |
		//+---------------------------------------------------------------------+
		fClose(nHdl)
		FT_FUse(cArqImpor)  //abre o arquivo 
		FT_FGOTOP()         //posiciona na primeira linha do arquivo      
		nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
		FT_FGOTOP()

		//+---------------------------------------------------------------------+
		//| Verifica quantas linhas tem o arquivo                               |
		//+---------------------------------------------------------------------+
		nLinhas := nTamArq/nTamLinha

		ProcRegua(nLinhas)

		aDados:={}  
        while !FT_FEOF()
            IncProc('Importando Linha: ')
            cLinha := FT_FReadLn()
            If lPrimlin
                aCampos := Separa(cLinha,";",.T.)//Adiciona a linha 1 do CSV a um array
                lPrimlin := .F.
            Else
                AADD(aDados,Separa(cLinha,";",.T.))//Adiciona os dados da planilha do array
            endif
    
        FT_FSkip()
        EndDo    

		FT_FUse()
		fClose(nHdl)

	EndIf

	ProcRegua(len(aDados))
	if(len(aDados) == 1)
		nLoop := 1
	else
		nLoop :=  CEILING((len(aDados)-1)/nLinhaMax)
	EndIf//Variavel para saber quantas vezes fazer 
	//a leitura do arquivo com base nas linhas máximas permitidas por lançamento
	

	For j := 1 to nLoop

		For i := nQtdeLinha to MIN(len(aDados),nLinhaMax)//Percorre arquivo

			If Len(Alltrim(aDados[i,2])) = 0 .and. Len(Alltrim(aDados[i,1])) > 0
				cTipo := '1'
			EndIf

			If Len(Alltrim(aDados[i,2])) > 0 .and. Len(Alltrim(aDados[i,1])) = 0
				cTipo := '2'
			EndIf

			If Len(Alltrim(aDados[i,2])) > 0 .and. Len(Alltrim(aDados[i,1]))> 0
				cTipo := '3'
			EndIf

			cData := dDataBase //Data do sistema
			
			AADD(aItens,{ {'CT2_FILIAL' ,cFilAnt,NIL},; //Adiciona os itens para mandar p/ o execauto
			{'CT2_LINHA' ,StrZero(nLinha,3,0),NIL},;
			{'CT2_MOEDLC' ,'01',NIL},;
			{'CT2_DC' ,cTipo,NIL},;
			{'CT2_DEBITO' ,Alltrim(aDados[i,1]),NIL},;
			{'CT2_CREDIT' ,Alltrim(aDados[i,2]),NIL},;
			{'CT2_CCD' ,Alltrim(aDados[i,5]),NIL},;
			{'CT2_CCC', Alltrim(aDados[i,6]),NIL},;
			{'CT2_VALOR' ,VAL(StrTran(aDados[i,3],",",".")),NIL},;
			{'CT2_ITEMC' ,Alltrim(aDados[i,8]),NIL},;
			{'CT2_ITEMD' ,Alltrim(aDados[i,7]),NIL},;
			{'CT2_ORIGEM' ,'MSEXECAUT',NIL},;
			{'CT2_HP' ,'',NIL},;
			{'CT2_CONVER','15555',NIL},;
			{'CT2_HIST' ,aDados[i,4],NIL}})
			
			nLinha +=1
			
			nQtdeLinha += 1
						
		Next i

     	Processa({|| IncluiCT2(cData, aItens)}, "Aguarde", "Importando lancamento  " , .T.) //Chama função do ExecAuto
		i += nQtdeLinha
		nLinha := 1
		nLinhaMax += 99
		aItens := {}
	Next j


	Aviso("Atenção","Importação com exito!",{"Ok"},1)

Return

Static Function IncluiCT2(cData,aItens)

	PRIVATE lMsErroAuto := .F.
	

	aCab := { {'DDATALANC' , cData ,NIL},;
	{'CLOTE' ,nLote ,NIL},;
	{'CSUBLOTE' ,'001' ,NIL},;
	{'CDOC' ,CTBPRXDOC(cData,nLote,'001') ,NIL},;
	{'CPADRAO' ,'' ,NIL},;
	{'NTOTINF' ,0 ,NIL},;
	{'NTOTINFLOT' ,0 ,NIL} }	

	MSExecAuto({|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

	If lMsErroAuto
		MostraErro()
	Endif

Return

STATIC FUNCTION CTBPRXDOC(DataLote, Lote, SubLote)//Verifica o último documento com base na data do sistema, caso
//já exista um documento daquela data, adiciona 1 ao número de documento(CT2_DOC)
	Local aArea    := GetArea()
	Local cProxDoc := "000001"
	Local dDataLanc:= DataLote
	Local cLote    := Lote
	Local cSubLote := SubLote
	Local cQuery   := ""

	cQuery := "SELECT Max(CTF_DOC) MAXDOC "
	cQuery += "FROM "+RetSqlName("CTF")+" CTF WHERE "
	cQuery += "CTF_FILIAL = '"+xFilial("CTF")+"' AND "
	cQuery += "CTF_DATA = '"+DTOS(dDataLanc)+"'  AND "
	cQuery += "CTF_LOTE = '"+cLote+"' AND "
	cQuery += "CTF_SBLOTE = '"+cSubLote+"' AND "
	cQuery += "D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPPRXDOC")

	cProxDoc := STRZERO(VAL(("TMPPRXDOC")->MAXDOC),6)

	dbSelectArea("TMPPRXDOC")

	("TMPPRXDOC")->(dbCloseArea())

	cProxDoc := SOMA1(cProxDoc)

	RestArea(aArea)

RETURN cProxDoc

Static Function ExParam()
    Local aParamBox   := {}
	Local aRet := {}
	
	aAdd(aParamBox,{1,"Lote",Space(15),"","",,"",0,.T.})

	If ParamBox(aParamBox,"Selecione o lote...",@aRet)
		nLote := aRet[1]
	EndIF

Return
