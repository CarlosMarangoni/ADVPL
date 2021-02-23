User Function PCOCSUP(cPlanilha)
Local cEscopo
Local cCsup1
Local cCsup2
/*  Autor: Carlos Mendes
    Data: 13/11/2020
    Atualiza conta superior na tabela de custeio com base na amarração entre contra superior e escopo da tabela ZZ6
*/


if MsgYesNo("Deseja atualizar a conta superior do custeio da obra "+ cPlanilha + " conforme escopo no PMS?","Atualiza Conta Superior?")
    cEscopo := Posicione("AF8",1,xFilial("AF8")+cPlanilha,"AF8_PLANEG") // Pega o numero do escopo no PMS com base no numero da obra
    cDescEscopo :=  ALLTRIM(Posicione("SX5",1,xFilial("SX5")+"PV"+ cEscopo,"X5_DESCRI"))// Pega a descrição do escopo
    dbSelectArea("ZZA")
	dbSetOrder(1)
    if dbSeek(xFilial("ZZA")+cEscopo)
        cCsup1 := ZZA->ZZA_CC1// Armazena conta superior 1 cadastrada na tabela customizada ZZA
        cCsup2  := ZZA->ZZA_CC2 // Armazena conta superior 2 cadastrada na tabela customizada ZZA

        if MsgYesNo("Escopo: " + cEscopo + " - " + cDescEscopo +  CHR(13)+CHR(10) + "Conta superior 1: " + cCsup1 + CHR(13)+CHR(10) + "Conta superior 2: " + cCsup2,"Prosseguir?")
            dbSelectArea("AK1")
            DbSetOrder(1)
            dbGoTop()
            dbSeek(xFilial("AK1") + cPlanilha)
            Reclock("AK1",.F.)
            AK1->AK1_CC1 := cCsup1// Atualiza conta superior
            AK1->AK1_CC2 := cCsup2
             AK1->(MsUnlock())
        endif
    else
        alert("Escopo " + cEscopo + " não encontrado na tabela de amarracoes")    
    
    endif
endif

return
  
