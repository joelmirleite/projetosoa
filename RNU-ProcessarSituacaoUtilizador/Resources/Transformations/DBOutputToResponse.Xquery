<?xml version="1.0" encoding="UTF-8"?>
<con:xqueryEntry xmlns:con="http://www.bea.com/wli/sb/resources/config">
    <con:xquery><![CDATA[xquery version "1.0" encoding "UTF-8";

declare namespace tns = "http://igif.min-saude.pt/rnu/processarsituacaoutilizador";
declare namespace db = "http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador";
declare namespace xf = "http://tempuri.org/RNU-ProcessarSituacaoUtilizador/Resources/Transformations/DBOutputToResponse/";

declare function xf:DBOutputToResponse($outputParameters as element(db:OutputParameters)) as element(tns:ClassificarUtentesResponse) {
    let $msg := $outputParameters/db:PROCESSAR_SITUACAO_UTILIZADOR/db:PROCESSAR_SITUACAO_UTILIZADOR_ITEM[1]
    return
    <tns:ClassificarUtentesResponse>
        {
            if ($msg/db:CODIGO) then
                (<tns:CodigoResposta>{fn:data($msg/db:CODIGO)}</tns:CodigoResposta>,
                 <tns:MensagemResposta>{fn:data($msg/db:MENSAGEM)}</tns:MensagemResposta>)
            else ()
        }
    </tns:ClassificarUtentesResponse>
};

declare variable $outputParameters as element(db:OutputParameters) external;

xf:DBOutputToResponse($outputParameters)]]></con:xquery>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/PartnerLinks/ProcessarSituacaoUtilizador/ProcessarSituacaoUtilizador_sp" namespace="http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador"/>
    </con:dependency>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/Resources/Schemas/ProcessarSituacaoUtilizador" namespace="http://igif.min-saude.pt/rnu/processarsituacaoutilizador"/>
    </con:dependency>
</con:xqueryEntry>
