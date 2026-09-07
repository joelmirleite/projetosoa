<?xml version="1.0" encoding="UTF-8"?>
<con:xqueryEntry xmlns:con="http://www.bea.com/wli/sb/resources/config">
    <con:xquery><![CDATA[xquery version "1.0" encoding "UTF-8";

declare namespace tns = "http://igif.min-saude.pt/rnu/processarsituacaoutilizador";
declare namespace db = "http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador";
declare namespace xf = "http://tempuri.org/RNU-ProcessarSituacaoUtilizador/Resources/Transformations/RequestToDBInput/";

declare function xf:RequestToDBInput($classificarUtentesRequest as element(tns:ClassificarUtentesRequest), $entidade as xs:string) as element(db:InputParameters) {
    let $utente := $classificarUtentesRequest/tns:Utentes/tns:Utente
    return
    <db:InputParameters>
        <db:ICT_NNU>{fn:data($utente/tns:NNU)}</db:ICT_NNU>
        <db:ICT_DATA_NASC>{fn:data($utente/tns:dataNascimento)}</db:ICT_DATA_NASC>
        <db:ICT_DATA_PROC_SDM>{fn:data($utente/tns:dataProcessamentoSDM)}</db:ICT_DATA_PROC_SDM>
        <db:ICT_SITUACAO>{fn:data($utente/tns:situacaoUtilizador)}</db:ICT_SITUACAO>
        <db:ICT_ENTIDADE>{fn:data($entidade)}</db:ICT_ENTIDADE>
    </db:InputParameters>
};

declare variable $classificarUtentesRequest as element(tns:ClassificarUtentesRequest) external;
declare variable $entidade as xs:string external;

xf:RequestToDBInput($classificarUtentesRequest, $entidade)]]></con:xquery>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/Resources/Schemas/ProcessarSituacaoUtilizador" namespace="http://igif.min-saude.pt/rnu/processarsituacaoutilizador"/>
    </con:dependency>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/PartnerLinks/ProcessarSituacaoUtilizador/ProcessarSituacaoUtilizador_sp" namespace="http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador"/>
    </con:dependency>
</con:xqueryEntry>
