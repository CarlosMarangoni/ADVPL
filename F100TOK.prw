User Function F100TOK()

Local lRet := .T.
if Alltrim(cEmpAnt)=='01' //Se empresa for Everest
    //Verifica amarração entre centro de custo e conta contábil
    dbSelectArea("CTA")
    CTA->(DbOrderNickName("CTACC")) //CTA_FILIAL + CTA_CONTA + CTA_CUSTA
    if(cRecPag == "P")
        If !CTA->(MsSeek(xFilial("SE5")+PADR(M->E5_DEBITO,TAMSX3("CTA_CONTA") [1])+ PADR(M->E5_CC,TAMSX3("CTA_CUSTO")[1])))
            lRet := .F.
            alert("Não existe amarração entre o Centro de Custo e a Conta Contabil Débito. Verifique com a Controladoria.")
        EndIf
    EndIf
    if(cRecPag == "R")
        If !CTA->(MsSeek(xFilial("SE5")+PADR(M->E5_CREDITO,TAMSX3("CTA_CONTA") [1])+ PADR(M->E5_CC,TAMSX3("CTA_CUSTO")[1])))
            lRet := .F.
            alert("Não existe amarração entre o Centro de Custo e a Conta Contabil Crédito. Verifique com a Controladoria.")
        EndIf
    EndIf
    dbCloseArea()
    If !AllTrim(M->E5_OBRA)=="1"
            aArea:= GetArea()
            dbSelectArea("AK1")
            dbSetOrder(1)
            If MsSeek(xFilial("AK1")+PADR(AllTrim(M->E5_OBRA),TAMSX3("AK1_CODIGO")[1]))
                dbSelectArea("AK2")
                dbSetOrder(1)
                If !MsSeek(xFilial("AK2")+AK1->AK1_CODIGO+AK1->AK1_VERSAO+PADR(Alltrim(M->E5_CO),TAMSX3("AK2_CO")[1]))
                    alert("Conta orcamentaria nao existente neste custeio.")
                    lRet := .F.
                EndIf     
                
            Else                        
                alert("Custeio nao encontrado")
                lRet := .F.          
            EndIf
            RestArea(aArea)
    
    Else
        if Alltrim(M->E5_CO) <> "99001"
            alert("Em obra 1, favor utilizar Conta Orcamentaria 99001.")
            lRet := .F.
        endif
    endif
endif
return lRet
