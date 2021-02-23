User Function CSVSC6()
    
    Local cDiret
    Local cLinha  := ""
    Local aCampos := {}
    Local aDados := {}
    Local nHandle
    Local lPrimlin := .T.
    Local i
    
    cDiret := cGetFile("Arquivo csv|*.csv","Selecione o Diretorio onde sera lido o arquivo a importar: ",0,"C:\",.F.,GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_LOCALHARD,.T.)
    If !file(cDiret)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return
    
    else
    
        FT_FUse(cDiret)
        if nHandle = -1
            return
        endif

        FT_FGOTOP()
        while !FT_FEOF()

        cLinha := FT_FReadLn()
            If lPrimlin
            aCampos := Separa(cLinha,";",.T.)      
            lPrimlin := .F.
            Else
                AADD(aDados,Separa(cLinha,";",.T.))//Adiciona os dados da planilha do array
            endif
        FT_FSkip()
        EndDo
    EndIF
    For i:=1 to (Len(aDados))//Percorre o array aDados atualizando os valores com base no csv.
        dbSelectArea("SC6")
        DbSetOrder(1)
        dbGoTop()
        IF dbSeek(xFilial("SC6")+aDados[i,1]+aDados[i,2])
            Reclock("SC6",.F.)
            if(aDados[i,3] <> "")
                SC6->C6_EVENTO := aDados[i,3]//EVENTO
            endif
            if(aDados[i,4] <> "")
                SC6->C6_PERCMS := VAL(StrTran(aDados[i,4],",","."))//%
            endif
            if(aDados[i,5] <> "")
                SC6->C6_PEP := aDados[i,5]  
            endif
            if(aDados[i,6] <> "")
                SC6->C6_RESPONS  := aDados[i,6]
            endif
            if(aDados[i,7] <> "")
                SC6->C6_ZSTATUS := aDados[i,7]
            endif
            if(aDados[i,8] <> "")
                SC6->C6_ENTREG := CtoD(aDados[i,8])
            endif
            if(aDados[i,9] <> "")
                SC6->C6_SEMPREV := aDados[i,9]
            endif
            if(aDados[i,10] <> "")
                SC6->C6_OBSMES := aDados[i,10]
            endif
            if(aDados[i,11] <> "")
               SC6->C6_ZOBS := aDados[i,11] //DETALHE CLIENTE
            endif

        endif
        AK1->(MsUnlock())
   next
    

Return
