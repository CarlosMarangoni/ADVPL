#Include 'Protheus.ch'
 
User Function CTBA020()
 
Local aParam     := PARAMIXB
Local oObj       := aParam[1]
Local cIdPonto   := aParam[2]
Local cIdModel   := aParam[3]
 
If aParam <> NIL
 
nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO
 
    If cIdPonto == "MODELCOMMITNTTS"   
        If nOpc == 3 .AND. Substring(CT1->CT1_CONTA,1,1) $ "1/2"
            AmarraCC() // Chama amarracao de C.C e conta contabil
        EndIf        
    EndIf

    If cIdPonto == "MODELPOS"
        If nOpc == 3
            If (Substring(M->CT1_CONTA,1,1) <> "2" .AND. POSICIONE("SY1",3,XFILIAL("SY1")+RETCODUSR(),"Y1_GRUPCOM") == '000001')//Se o usuário for do grupo Compras
                MsgInfo("Sem permissão para cadastrar contas de início " + Substring(M->CT1_CONTA,1,1),"ERRO")
                Return .F.
            EndIf
        EndIf
    EndIf
EndIf
Return .T.
                            
Static Function AmarraCC()
 
    Local cQuery:=''
    Local nTotal
    Local cAliasCTA:= GetNextAlias()
    Local aAreaAnt := GETAREA() // GUARDA A AREA DA CT1
 
    cQuery:= "SELECT CONVERT(varchar,Max (CONVERT(bigint,(RTRIM(CTA_ITREGR))))) AS NUM "
    cQuery+= "FROM "+RETSQLNAME("CTA") // PEGA O ULTIMO REGISTRO DA REGRA
    cQuery+=" WHERE D_E_L_E_T_!='*' AND CTA_REGRA='000002'"
    cQuery := ChangeQuery(cQuery) 
    dbUseArea(.T., "TOPCONN", TCGenQry(, , cQuery), cAliasCTA, .F., .T.) 
    //
    (cAliasCTA)->(DbGoTop())
    nTotal:=(Val((cAliasCTA)->NUM)+1)
    
    //FAZ AMARRAÇÃO COM A CONTA 32.2 NO CTA010
    RecLock("CTA",.T.) // Incluir
 
        
    CTA->CTA_FILIAL := xFilial("CTA")
    CTA->CTA_ITREGRA := StrZero(nTotal,4)
    CTA->CTA_REGRA := "000002"
    CTA->CTA_DESC := "AMARRACAO CONTAS X C.C."
    CTA->CTA_NIVEL:="1"
    CTA->CTA_CONTA := CT1->CT1_CONTA
    CTA->CTA_CUSTO   := "32.2"
        
 
    MsUnlock()
        
    RecLock("CTA",.T.) // Incluir
 
        
    CTA->CTA_FILIAL := xFilial("CTA")
    CTA->CTA_ITREGRA := StrZero(nTotal+1,4)
    CTA->CTA_REGRA := "000002"
    CTA->CTA_DESC := "AMARRACAO CONTAS X C.C."
    CTA->CTA_NIVEL:="1"
    CTA->CTA_CONTA := CT1->CT1_CONTA
    CTA->CTA_CUSTO   := "32.3"
        
 
    MsUnlock()
    
 
    
    RESTAREA(aAreaAnt)  // RETORNA A AREA DO CT1
 
Return 
