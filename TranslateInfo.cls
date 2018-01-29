global class TranslateInfo {

    
    public static string GetTranslatedInfo(string TipoObr, string CodValor, String Data){
       	Map<string, String>    auxTpObr = new Map<String,String>();
        string OutMsg;
        Map<string, String>    auxCodValor = new Map<String,String>();
        
   		auxTpObr.put('03','de IRC');
    	auxTpObr.put('04','à Segurança Social');

        auxCodValor.put('A01','até 10.000Eur');
        auxCodValor.put('A02','entre 10.001Eur e 50.000Eur');
        auxCodValor.put('A03','entre 50.001Eur e 100.000Eur');
        auxCodValor.put('A04','entre 100.001Eur e 500.000Eur');
        auxCodValor.put('A05','entre 500.001Eur e 1.000.000Eur');
        auxCodValor.put('A06','entre 1.000.001Eur e 5.000.000Eur');
        auxCodValor.put('A07','mais de 5.000.000Eur');
        auxCodValor.put('A08','entre 50.000Eur e 250.000Eur');
        auxCodValor.put('A09','entre 250.001Eur e 500.000Eur');
        auxCodValor.put('A00','0Eur');
        auxCodValor.put('A10','entre 100.001Eur e 250.000Eur');
        auxCodValor.put('A11','entre 7.500Eur e 25.000Eur');
        auxCodValor.put('A12','entre 25.001Eur a 50.000Eur');
        auxCodValor.put('A14','mais de 1.000.000Eur');
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        auxCodValor.put('A13','entre 250.001Eur e 1.000.000Eur');
        auxCodValor.put('CONADM_008','Sup. Secretário Conselho Administrativo');
        auxCodValor.put('CONADM_007','Vogal Sup. do Conselho Administrativo');
        auxCodValor.put('CONCON_001','Presidente do Conselho Consultivo');
        auxCodValor.put('CONCON_002','Vice-Presidente do Conselho Consultivo');
        auxCodValor.put('DIROPER','Diretor Operações / Produção');
        auxCodValor.put('DIRCOM','Diretor Comercial');
        auxCodValor.put('DIRRH','Diretor de Recursos Humanos');
        auxCodValor.put('DIRCOMPR','Diretor de Compras');
        auxCodValor.put('DIRMARK','Diretor de Marketing');
        auxCodValor.put('DIRTEC','Diretor Sistemas Informação');
        auxCodValor.put('DIRCIMAG','Diretor de Comunicação e Imagem');
        auxCodValor.put('DIRQUAL','Diretor de Qualidade');
        auxCodValor.put('DIRCONTA','Diretor de Contabilidade');
        auxCodValor.put('DIRTECN','Diretor Técnico');
        auxCodValor.put('DIRLOGIS','Diretor de Logistica');
        auxCodValor.put('DIRPROJ','Diretor de Projetos');
        auxCodValor.put('DIRCLIN','Diretor Clinico');
        auxCodValor.put('DIRJURID','Diretor Juridico');
        auxCodValor.put('DIRINOV','Diretor de Inovação e Desenvolvimento');
        auxCodValor.put('DIRCRED','Diretor de Crédito');
        auxCodValor.put('DIRCRIAT','Diretor Criativo');
        auxCodValor.put('DIRAUDIT','Diretor de Auditoria');
        auxCodValor.put('DIRPRODT','Diretor de Produto');
        auxCodValor.put('DIRRELPU','Diretor de Relações Publicas');
        auxCodValor.put('DIRPUBL','Diretor de Publicidade');
        auxCodValor.put('DIR','Diretor');
        auxCodValor.put('CONTROL','Controller');
        auxCodValor.put('ACC','Acionista');
        auxCodValor.put('SOC','Sócio');
        auxCodValor.put('TOC','Técnico Oficial de Contas');
        auxCodValor.put('COMVEN_004','Vogal da Comissão de Vencimentos');
        auxCodValor.put('COMVEN_010','Sup. Secretário da Comissão de Vencimentos');
        auxCodValor.put('COMVEN_009','Vogal Sup. da Comissão de Vencimentos');
        auxCodValor.put('CONDIS_001','Presidente do Conselho Disciplinar');
        auxCodValor.put('CONDIS_002','Vice-Presidente do Conselho Disciplinar');
        auxCodValor.put('CONDIS_004','Secretário do Conselho Disciplinar');
        auxCodValor.put('CONDIS_005','Vogal do Conselho Disciplinar');
        auxCodValor.put('CONDIS_006','Sup. do Vogal do Conselho Disciplinar');
        auxCodValor.put('CONJUR_001','Presidente do Conselho Juridiscional');
        auxCodValor.put('CONJUR_002','Vice-Presidente Conselho Juridiscional');
        auxCodValor.put('CONJUR_005','Secretário do Conselho Juridiscional');
        auxCodValor.put('CONJUR_004','Vogal do Conselho Juridiscional');
        auxCodValor.put('CONJUR_008','Sup. Secretário Conselho Juridiscional');
        auxCodValor.put('CONJUR_007','Vogal Sup. do Conselho Juridiscional');
        auxCodValor.put('CONTEC_001','Presidente do Conselho Técnico');
        auxCodValor.put('CONTEC_002','Vice-Presidente do Conselho Técnico');
        auxCodValor.put('CONTEC_005','Secretário do Conselho Técnico');
        auxCodValor.put('CONTEC_004','Vogal do Conselho Técnico');
        auxCodValor.put('CONTEC_010','Sup. do Secretário do Conselho Técnico');
        auxCodValor.put('CONTEC_009','Vogal Sup. do Conselho Técnico');
        auxCodValor.put('DIRGER','Diretor Geral');
        auxCodValor.put('DIRGRADJ','Diretor Geral Adjunto');
        auxCodValor.put('DIRFIN','Diretor Financeiro');
        auxCodValor.put('DIRADMFI','Diretor Administrativo Financeiro');
        auxCodValor.put('CONFIS_004','Presidente do Conselho Fiscal');
        auxCodValor.put('CONFIS_005','Vice-Presidente do Conselho Fiscal');
        auxCodValor.put('CONFIS_011','Secretário do Conselho Fiscal');
        auxCodValor.put('CONFIS_006','Vogal do Conselho Fiscal');
        auxCodValor.put('CONFIS_019','Relator do Conselho Fiscal');
        auxCodValor.put('CONFIS_014','Revisor Oficial de Contas');
        auxCodValor.put('CONFIS_002','Fiscal Unico - Sup.');
        auxCodValor.put('CONFIS_017','Sup. do Secretário do Conselho Fiscal');
        auxCodValor.put('CONFIS_016','Vogal Sup. do Conselho Fiscal');
        auxCodValor.put('CONFIS_018','Sup. do Revisor Oficial de Contas');
        auxCodValor.put('ASSGER_001','Presidente da Assembleia Geral');
        auxCodValor.put('ASSGER_002','Vice-Presidente da Assembleia Geral');
        auxCodValor.put('ASSGER_004','Secretário da Assembleia Geral');
        auxCodValor.put('ASSGER_005','Vogal da Assembleia Geral');
        auxCodValor.put('ASSGER_010','Sup. do Secretário da Assembleia Geral');
        auxCodValor.put('ASSGER_009','Vogal Sup. da Assembleia Geral');
        auxCodValor.put('SEC_SOC','Secretário da Sociedade');
        auxCodValor.put('ASSMUN_001','Presidente da Assembleia Municipal');
        auxCodValor.put('ASSMUN_002','Vice-Presidente da Assembleia Municipal');
        auxCodValor.put('ASSMUN_004','Secretário da Assembleia Municipal');
        auxCodValor.put('ASSMUN_003','Vogal Assembleia Municipal');
        auxCodValor.put('ASSMUN_008','Sup. Secretário da Assembleia Municipal');
        auxCodValor.put('ASSMUN_007','Vogal Sup. Assembleia Municipal');
        auxCodValor.put('ASSFRE_001','Presidente da Assembleia de Freguesia');
        auxCodValor.put('ASSFRE_002','Vice-Presidente da Assembleia de Freguesia');
        auxCodValor.put('ASSFRE_004','Secretário da Assembleia de Freguesia');
        auxCodValor.put('MESCON_001','Presidente da Mesa do Congresso');
        auxCodValor.put('MESCON_002','Vice-Presidente da Mesa do Congresso');
        auxCodValor.put('MESCON_004','Secretário da Mesa do Congresso');
        auxCodValor.put('MESCON_003','Vogal da Mesa do Congresso');
        auxCodValor.put('MESCON_009','Vogal Sup. da Mesa do Congresso');
        auxCodValor.put('RRELMERC','Responsável de Relações com o Mercado');
        auxCodValor.put('CONCIE_001','Presidente do Conselho Científico');
        auxCodValor.put('CONCIE_002','Vice-Presidente do Conselho Científico');
        auxCodValor.put('JUNFRE_005','Secretário da Junta de Freguesia');
        auxCodValor.put('JUNFRE_006','Vogal da Junta de Freguesia');
        auxCodValor.put('JUNFRE_010','Sup. do Secretário da Junta de Freguesia');
        auxCodValor.put('JUNFRE_009','Sup. do Vogal da Junta de Freguesia');
        auxCodValor.put('CONGES_001','Presidente do Conselho de Gestão');
        auxCodValor.put('CONGES_002','Vice-Presidente do Conselho de Gestão');
        auxCodValor.put('CONGES_005','Secretário do Conselho de Gestão');
        auxCodValor.put('CONGES_004','Vogal do Conselho de Gestão');
        auxCodValor.put('CONGES_008','Sup. do Secretário do Conselho de Gestão');
        auxCodValor.put('CONGES_007','Vogal Sup. do Conselho de Gestão');
        auxCodValor.put('CONDVO_001','Presidente do Conselho Diretivo');
        auxCodValor.put('CONCIE_008','Sup. Secretário do Conselho Científico');
        auxCodValor.put('CONCIE_005','Secretário do Conselho Científico');
        auxCodValor.put('CONCIE_007','Vogal Sup. do Conselho Científico');
        auxCodValor.put('CONPED_001','Presidente do Conselho Pedagógico');
        auxCodValor.put('CONCIE_004','Vogal do Conselho Científico');
        auxCodValor.put('CONPED_002','Vice-Presidente do Conselho Pedagógico');
        auxCodValor.put('CONPED_005','Secretário do Conselho Pedagógico');
        auxCodValor.put('CONPED_004','Vogal do Conselho Pedagógico');
        auxCodValor.put('CONPED_008','Sup. Secretário do Conselho Pedagógico');
        auxCodValor.put('CONPED_007','Vogal Sup. do Conselho Pedagógico');
        auxCodValor.put('ADMMFAL','Administrador da Insolvência');
        auxCodValor.put('LIQ','Liquidatário Judicial');
        auxCodValor.put('FUNDAC_001','Presidente da Fundação');
        auxCodValor.put('FUNDAC_002','Vice-Presidente da Fundação');
        auxCodValor.put('FUNDAC_004','Conselheiro da Fundação');
        auxCodValor.put('FUNDAC_003','Vogal da Fundação');
        auxCodValor.put('CONSUL_001','Cônsul');
        auxCodValor.put('CONSUL_002','Vice-Cônsul');
        auxCodValor.put('CONSUL_003','');
        auxCodValor.put('ASSFRE_003','Vogal da Assembleia de Freguesia');
        auxCodValor.put('ASSFRE_008','Sup. Secretário da Assembleia de Freguesia');
        auxCodValor.put('ASSFRE_007','Vogal Sup. da Assembleia de Freguesia');
        auxCodValor.put('CONGRL_001','Presidente do Conselho Geral');
        auxCodValor.put('CONGRL_002','Vice-Presidente do Conselho Geral');
        auxCodValor.put('CONGRL_005','Secretário do Conselho Geral');
        auxCodValor.put('CONGRL_004','Vogal do Conselho Geral');
        auxCodValor.put('CONADM_001','Presidente do Conselho Administrativo');
        auxCodValor.put('CONADM_002','Vice-Presidente Conselho Administrativo');
        auxCodValor.put('CONADM_005','Secretário do Conselho Administrativo');
        auxCodValor.put('CONADM_004','Vogal do Conselho Administrativo');
        auxCodValor.put('CONGRL_008','Sup. do Secretário do Conselho Geral');
        auxCodValor.put('CONGRL_007','Vogal Sup. do Conselho Geral');
        auxCodValor.put('CONCUR_001','Presidente do Conselho de Curadores');
        auxCodValor.put('CONCUR_002','Vice-Presidente do Conselho de Curadores');
        auxCodValor.put('CONCUR_005','Secretário do Conselho de Curadores');
        auxCodValor.put('CONCUR_004','Vogal do Conselho de Curadores');
        auxCodValor.put('CONCUR_008','Sup. Secretário do Conselho de Curadores');
        auxCodValor.put('CONCUR_007','Vogal Sup. do Conselho de Curadores');
        auxCodValor.put('CONSUP_001','Presidente do Conselho Superior');
        auxCodValor.put('CONSUP_002','Vice-Presidente do Conselho Superior');
        auxCodValor.put('CONSUP_005','Secretário do Conselho Superior');
        auxCodValor.put('CONSUP_004','Vogal do Conselho Superior');
        auxCodValor.put('CONSUP_008','Sup. do Secretário do Conselho Superior');
        auxCodValor.put('CONSUP_007','Vogal Sup. do Conselho Superior');
        auxCodValor.put('FUNDAC_005','Presidente do Conselho Fundador');
        auxCodValor.put('FUNDAC_006','Vice-Presidente do Conselho Fundador');
        auxCodValor.put('FUNDAC_009','Secretário do Conselho Fundador');
        auxCodValor.put('FUNDAC_008','Vogal do Conselho Fundador');
        auxCodValor.put('FUNDAC_012','Sup. do Secretário do Conselho Fundador');
        auxCodValor.put('FUNDAC_011','Vogal Sup. do Conselho Fundador');
        auxCodValor.put('ASSREP_001','Presidente Assembleia de Representante');
        auxCodValor.put('ASSREP_002','Vice-Presidente Assembleia de Representante');
        auxCodValor.put('ASSREP_004','Secretário Assembleia de Representante');
        auxCodValor.put('CONDVO_002','Vice-Presidente do Conselho Diretivo');
        auxCodValor.put('CONDVO_005','Secretário do Conselho Diretivo');
        auxCodValor.put('CONDVO_004','Vogal do Conselho Diretivo');
        auxCodValor.put('CONDVO_008','Sup. do Secretário do Conselho Diretivo');
        auxCodValor.put('CONDVO_007','Vogal Sup. do Conselho Diretivo');
        auxCodValor.put('DIRECC_001','Presidente da Direção');
        auxCodValor.put('DIRECC_002','Vice-Presidente da Direção');
        auxCodValor.put('DIRECC_004','Tesoureiro da Direção');
        auxCodValor.put('DIRECC_010','Secretário da Direção');
        auxCodValor.put('DIRECC_005','Vogal da Direção');
        auxCodValor.put('DIRECC_016','Sup. do Secretário da Direção');
        auxCodValor.put('DIRECC_015','Vogal Sup. da Direção');
        auxCodValor.put('CONEXE_001','Presidente do Conselho Executivo');
        auxCodValor.put('CONEXE_002','Vice-Presidente do Conselho Executivo');
        auxCodValor.put('CONEXE_005','Secretário do Conselho Executivo');
        auxCodValor.put('CONEXE_004','Vogal do Conselho Executivo');
        auxCodValor.put('CONEXE_008','Sup. do Secretário do Conselho Executivo');
        auxCodValor.put('CONEXE_007','Vogal Sup. do Conselho Executivo');
        auxCodValor.put('COMEXE_001','Presidente da Comissão Executiva');
        auxCodValor.put('COMEXE_002','Vice-Presidente da Comissão Executiva');
        auxCodValor.put('COMEXE_004','Secretário da Comissão Executiva');
        auxCodValor.put('COMEXE_005','Vogal da Comissão Executiva');
        auxCodValor.put('COMEXE_010','Sup. do Secretário da Comissão Executiva');
        auxCodValor.put('COMEXE_009','Vogal Sup. da Comissão Executiva');
        auxCodValor.put('CONDIR_001','Presidente do Conselho da Direção');
        auxCodValor.put('CONDIR_002','Vice-Presidente do Conselho da Direção');
        auxCodValor.put('CONDIR_005','Secretário do Conselho da Direção');
        auxCodValor.put('CONDIR_004','Vogal do Conselho da Direção');
        auxCodValor.put('CONDIR_008','Sup. do Secretário do Conselho da Direção');
        auxCodValor.put('CONDIR_007','Vogal Sup. do Conselho da Direção');
        auxCodValor.put('COMGES_001','Presidente da Comissão de Gestão');
        auxCodValor.put('COMGES_002','Vice-Presidente da Comissão de Gestão');
        auxCodValor.put('COMGES_004','Secretário da Comissão de Gestão');
        auxCodValor.put('COMGES_003','Vogal da Comissão de Gestão');
        auxCodValor.put('COMGES_009','Sup. do Secretário da Comissão de Gestão');
        auxCodValor.put('ASSREP_003','Vogal Assembleia de Representante');
        auxCodValor.put('ASSREP_010','Sup. Sec. Assembleia de Representante');
        auxCodValor.put('ASSREP_009','Vogal Sup. Assembleia Representante');
        auxCodValor.put('COMFAB_001','Presidente da Comissão Fabriqueira');
        auxCodValor.put('COMFAB_002','Vice-Presidente da Comissão Fabriqueira');
        auxCodValor.put('COMFAB_004','Secretário da Comissão Fabriqueira');
        auxCodValor.put('COMFAB_003','Vogal da Comissão Fabriqueira');
        auxCodValor.put('COMFAB_009','Vogal Sup. da Comissão Fabriqueira');
        auxCodValor.put('COMGES_008','Vogal Sup. da Comissão de Gestão');
        auxCodValor.put('COMADM_001','Presidente da Comissão Administrativa');
        auxCodValor.put('COMADM_002','Vice-Presidente Comissão Administrativa');
        auxCodValor.put('COMADM_004','Secretário da Comissão Administrativa');
        auxCodValor.put('COMADM_005','Vogal da Comissão Administrativa');
        auxCodValor.put('COMADM_012','Sup. do Secretário Comissão Administrativa');
        auxCodValor.put('COMADM_011','Vogal Sup. Comissão Administrativa');
        auxCodValor.put('CONARB_001','Presidente do Conselho de Arbitragem');
        auxCodValor.put('CONARB_002','Vice-Presidente do Conselho de Arbitragem');
        auxCodValor.put('CONARB_005','Secretário do Conselho de Arbitragem');
        auxCodValor.put('CONARB_004','Vogal do Conselho de Arbitragem');
        auxCodValor.put('CONARB_008','Sup. do Secretário do Conselho de Arbitragem');
        auxCodValor.put('CONARB_007','Vogal Sup. do Conselho de Arbitragem');
        auxCodValor.put('DIRREL_001','Presidente da Direção Regional');
        auxCodValor.put('DIRREL_002','Vice-Presidente da Direção Regional');
        auxCodValor.put('DIRREL_004','Secretário da Direção Regional');
        auxCodValor.put('DIRREL_003','Vogal da Direção Regional');
        auxCodValor.put('DIRREL_007','Sup. do Secretário da Direção Regional');
        auxCodValor.put('DIRREL_006','Vogal Sup. Direção Regional');
        auxCodValor.put('COMINS_001','Presidente da Comissão Instaladora');
        auxCodValor.put('COMINS_002','Vice-Presidente da Comissão Instaladora');
        auxCodValor.put('COMINS_004','Secretário da Comissão Instaladora');
        auxCodValor.put('COMINS_003','Vogal da Comissão Instaladora');
        auxCodValor.put('COMINS_010','Sup. do Secretário da Comissão Instaladora');
        auxCodValor.put('COMINS_009','Vogal Sup. da Comissão Instaladora');
        auxCodValor.put('COMLIQ_001','Presidente da Comissão Liquidatária');
        auxCodValor.put('COMLIQ_002','Vice-Presidente da Comissão Liquidatária');
        auxCodValor.put('COMLIQ_005','Secretário da Comissão Liquidatária');
        auxCodValor.put('COMLIQ_004','Vogal da Comissão Liquidatária');
        auxCodValor.put('COMLIQ_010','Sup. do Secretário da Comissão Liquidatária');
        auxCodValor.put('COMLIQ_009','Vogal Sup. Comissão Liquidatária');
        auxCodValor.put('GER','Gerente');
        auxCodValor.put('PROC','Procurador');
        auxCodValor.put('REPR','Representante');
        auxCodValor.put('CONFIS_001','Fiscal Unico');
        auxCodValor.put('BAST','Bastonário');
        auxCodValor.put('EMBAIX_001','Embaixador');
        auxCodValor.put('EMBAIX_002','Conselheiro da Embaixada');
        auxCodValor.put('CHEFEST_MAI','Chefe de Estado Maior');
        auxCodValor.put('COMCORP','Comandante da Corporação');
        auxCodValor.put('BANCOP_001','Governador');
        auxCodValor.put('BANCOP_002','Vice-Governador');
        auxCodValor.put('UNIVERS_001','Reitor');
        auxCodValor.put('UNIVERS_002','Vice-Reitor');
        auxCodValor.put('UNIVERS_003','Pró-Reitor');
        auxCodValor.put('MESADM_001','Provedor');
        auxCodValor.put('MESADM_002','Vice-Provedor');
        auxCodValor.put('MINIST','Ministro');
        auxCodValor.put('SECGERAL','Secretário-Geral');
        auxCodValor.put('PROP','Proprietário');
        auxCodValor.put('SOCGER','Sócio-Gerente');
        auxCodValor.put('ADMUNICO','Administrador Único');
        auxCodValor.put('CNADMI_001','Presidente do Conselho de Administração');
        auxCodValor.put('CNADMI_002','Vice-Presidente do Conselho de Administração');
        auxCodValor.put('ADMDEL','Administrador-Delegado');
        auxCodValor.put('ADMEXEC','Administrador-Executivo');
        auxCodValor.put('CNADMI_006','Secretário do Conselho de Administração');
        auxCodValor.put('CNADMI_004','Vogal do Conselho de Administração');
        auxCodValor.put('CNADMI_010','Sup Secretário Conselho de Administração');
        auxCodValor.put('CNADMI_009','Vogal Sup. do Conselho de Administração');
        auxCodValor.put('CONGER_001','Presidente do Conselho de Gerência');
        auxCodValor.put('CONGER_002','Vice-Presidente do Conselho de Gerência');
        auxCodValor.put('CONGER_005','Secretário do Conselho de Gerência');
        auxCodValor.put('CONGER_004','Vogal do Conselho de Gerência');
        auxCodValor.put('CONGER_008','Sup. do Secretário do Conselho de Gerência');
        auxCodValor.put('CONGER_007','Vogal Sup. do Conselho de Gerência');
        auxCodValor.put('CAMMUN_001','Presidente da Câmara Municipal');
        auxCodValor.put('CAMMUN_002','Vice-Presidente da Câmara Municipal');
        auxCodValor.put('CAMMUN_003','Adjunto do Presidente da Câmara Municipal');
        auxCodValor.put('CAMMUN_004','Vereador da Câmara Municipal');
        auxCodValor.put('JUNFRE_001','Presidente da Junta de Freguesia');
        auxCodValor.put('JUNFRE_002','Vice-Presidente da Junta de Freguesia');
        auxCodValor.put('JUNFRE_004','Tesoureiro da Junta de Freguesia');
        auxCodValor.put('CONCON_005','Secretário do Conselho Consultivo');
        auxCodValor.put('CONCON_004','Vogal do Conselho Consultivo');
        auxCodValor.put('CONCON_007','Vogal Sup. do Conselho Consultivo');
        auxCodValor.put('PRCOMAUD','Presidente da Comissão de Auditoria');
        auxCodValor.put('CONCON_008','Sup. Secretário do Conselho Consultivo');
        auxCodValor.put('MBRCOMAUD','Vogal da Comissão de Auditoria');
        auxCodValor.put('COMVEN_001','Presidente da Comissão de Vencimentos');
        auxCodValor.put('COMVEN_002','Vice-Presidente da Comissão de Vencimentos');
        auxCodValor.put('COMVEN_005','Secretário da Comissão de Vencimentos');
        auxCodValor.put('C21','Cancelamento da Falência');
        auxCodValor.put('D10','Falecido');
        auxCodValor.put('D20','Reforma');
        auxCodValor.put('E30','Temporariamente Inativo');
        auxCodValor.put('E31','Cancelamento de Inatividade');
        auxCodValor.put('A00','Ativa');
        auxCodValor.put('B10','Dissolução');
        auxCodValor.put('B11','Cancelamento da Dissolução');
        auxCodValor.put('B20','Liquidação');
        auxCodValor.put('B21','Cancelamento da Liquidação');
        auxCodValor.put('B30','Extinção');
        auxCodValor.put('B31','Cancelamento da Extinção');
        auxCodValor.put('B40','Aquisição');
        auxCodValor.put('B41','Cancelamento da Aquisição');
        auxCodValor.put('B50','Encerramento Legal');
        auxCodValor.put('B51','Encerramento Legal Anulado');
        auxCodValor.put('C10','Insolvência/Trâmites de Composição');
        auxCodValor.put('C11','Cancelamento Anulado');
        auxCodValor.put('C20','Falência');

		
        if(TipoObr!=''){
           OutMsg='À data '+ Data + ' a empresa tinha dívidas ' + auxTpObr.get(TipoObr) + 'num valor' + auxCodValor.get(CodValor); 
        } else {
           OutMsg=auxCodValor.get(CodValor) ;
        }
        
        
        return OutMsg;
    }

    public static decimal GetFormaObrigarVal(string FormaObrigar){
        try{
            
            decimal FormaobrigarVal=0;
            map <string, decimal> FormaobrigarTrans=new map<string, decimal> ();
            string Find11='UMA ';
            string Find12='UM ';
            string Find13='1 ';
            string Find14='COM ASSINATURA D';
            string Find15='PELA ASSINATURA D';
            string Find16='ÚNICO ';
            String Find17='ÚNICA ';
            string Find18='UNICO ';
            String Find19='UNICA ';
            string Find21='DUAS ';
            string Find22='DOIS ';
            string Find23='2 ';
            string Find31='TRÊS ';
            string Find32='3 ';
            String Find41='4 ';
            String Find42='QUATRO ';
            String Find51='5 ';
            String Find52='CINCO ';
            String Find='';
            decimal valfind=0;
            FormaobrigarTrans.put('UMA',1);
            FormaobrigarTrans.put('UM',1);
            FormaobrigarTrans.put('1',1);
            FormaobrigarTrans.put('COMASSINATURAD',1);
            FormaobrigarTrans.put('PELAASSINATURAD',1);
            FormaobrigarTrans.put('ÚNICO',1);
            FormaobrigarTrans.put('ÚNICA',1);
            FormaobrigarTrans.put('UNICO',1);
            FormaobrigarTrans.put('UNICA',1);
            FormaobrigarTrans.put('DOIS',2);
            FormaobrigarTrans.put('DUAS',2);
            FormaobrigarTrans.put('2',2);
            FormaobrigarTrans.put('TRÊS',3);
            FormaobrigarTrans.put('3',3);
            FormaobrigarTrans.put('QUATRO',4);
            FormaobrigarTrans.put('4',4);
            FormaobrigarTrans.put('CINCO',5);
            FormaobrigarTrans.put('5',5);
            FormaObrigar=FormaObrigar.toUpperCase();

            if (FormaObrigar.indexOf(Find11)!=-1){
                Find=  Find11;
                valfind=  FormaObrigar.indexOf(Find11);
            } 
            If (FormaObrigar.indexOf(Find12)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find12)) ){
                Find=  Find12;
                valfind=  FormaObrigar.indexOf(Find12);
            }
            If (FormaObrigar.indexOf(Find13)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find13))){
                Find=  Find13;
                valfind=  FormaObrigar.indexOf(Find13);
            }
            If (FormaObrigar.indexOf(Find14)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find14))){
                Find=  Find14;
                valfind=  FormaObrigar.indexOf(Find14);
            }
            If (FormaObrigar.indexOf(Find15)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find15))){
                Find=  Find15;
                valfind=  FormaObrigar.indexOf(Find15);
            }
            If (FormaObrigar.indexOf(Find16)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find16))){
                Find=  Find16;
                valfind=  FormaObrigar.indexOf(Find16);
            }
            If (FormaObrigar.indexOf(Find17)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find17))){
                Find=  Find17;
                valfind=  FormaObrigar.indexOf(Find17);
            }
            If (FormaObrigar.indexOf(Find18)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find18))){
                Find=  Find18;
                valfind=  FormaObrigar.indexOf(Find18);
            }
            If (FormaObrigar.indexOf(Find19)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find19))){
                Find=  Find19;
                valfind=  FormaObrigar.indexOf(Find19);
            }
            If (FormaObrigar.indexOf(Find21)!=-1 && ( valfind==0 ||  valfind > FormaObrigar.indexOf(Find21))){
                Find=  Find21;
                valfind=  FormaObrigar.indexOf(Find21);
            }
            If (FormaObrigar.indexOf(Find22)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find22))){
                Find=  Find22;
                valfind=  FormaObrigar.indexOf(Find22);
            } 
            If (FormaObrigar.indexOf(Find23)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find23))){
                Find=  Find23;
                valfind=  FormaObrigar.indexOf(Find23);
            }
            If (FormaObrigar.indexOf(Find31)!=-1 && ( valfind==0 ||  valfind > FormaObrigar.indexOf(Find31))){
                Find=  Find31;
                valfind=  FormaObrigar.indexOf(Find31);
            } 
            If (FormaObrigar.indexOf(Find32)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find32))){
                Find=  Find32;
                valfind=  FormaObrigar.indexOf(Find32);
            } 
            If (FormaObrigar.indexOf(Find41)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find41))){
                Find=  Find41;
                valfind=  FormaObrigar.indexOf(Find41);
            } 
            If (FormaObrigar.indexOf(Find42)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find42))){
                Find=  Find42;
                valfind=  FormaObrigar.indexOf(Find42);
            }
            If (FormaObrigar.indexOf(Find51)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find51))){
                Find=  Find51;
                valfind=  FormaObrigar.indexOf(Find51);
            } 
            If (FormaObrigar.indexOf(Find52)!=-1 && ( valfind==0 || valfind > FormaObrigar.indexOf(Find52))){
                Find=  Find52;
                valfind=  FormaObrigar.indexOf(Find52);
            } 
            return FormaobrigarTrans.get(Find.deleteWhitespace());
        } 
        catch(Exception e){
            return 0;
        }    
    }
    
    
}