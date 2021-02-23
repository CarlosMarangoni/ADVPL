User Function CSVAK1()
    
    Local cDiret
    Local cLinha  := ""
    Local aCampos := {}
    Local aDados := {}
    Local nHandle
    Local lPrimlin := .T.
    Local i
    
    cDiret := cGetFile("Arquivo csv|*.csv","Selecione o Diretorio onde sera lido o arquivo a importar: ",0,"C:\",.F.,GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_LOCALHARD,.T.)
    
    
    FT_FUse(cDiret)
    If !file(cDiret)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return
    
    else


        if nHandle = -1
            return
        endif

        FT_FGOTOP()
        while !FT_FEOF()

            cLinha := FT_FReadLn()
            If lPrimlin
                aCampos := Separa(cLinha,";",.T.)//Adiciona a linha 1 do CSV a um array
                lPrimlin := .F.
            Else
                AADD(aDados,Separa(cLinha,";",.T.))//Adiciona os dados da planilha do array
            endif
        
        FT_FSkip()
        EndDo
    EndIF

    For i:=1 to (Len(aDados))//Percorre o array aDados atualizando os valores com base no csv.
        dbSelectArea("AK1")
        DbSetOrder(1)
        dbGoTop()
        IF dbSeek(xFilial("AK1")+aDados[i,1])// Procura na AK1 registro Filial + número da OS
            Reclock("AK1",.F.)
            if(aDados[i,2] <> "")
            AK1->AK1_VENMAT :=   VAL(StrTran(aDados[i,2],",","."))//Substitui vírgula por ponto e adiciona no campo da AK1 
            endif
            if(aDados[i,3] <> "")
            AK1->AK1_VENSER := VAL(StrTran(aDados[i,3],",","."))
            endif
            if(aDados[i,4] <> "")
            AK1->AK1_IMPVEN := VAL(StrTran(aDados[i,4],",","."))
            endif
            if(aDados[i,5] <> "")
            AK1->AK1_PMARGE  := VAL(StrTran(aDados[i,5],",","."))
            endif
            if(aDados[i,6] <> "")
            AK1->AK1_CC1 := aDados[i,6]
            endif
            if(aDados[i,7] <> "")
            AK1->AK1_CC2 := aDados[i,7]
            endif
        endif
        AK1->(MsUnlock())
   next
    

Return
