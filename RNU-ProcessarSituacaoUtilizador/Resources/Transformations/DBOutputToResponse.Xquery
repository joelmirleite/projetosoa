<?xml version="1.0" encoding="UTF-8"?>
<con:xqueryEntry xmlns:con="http://www.bea.com/wli/sb/resources/config">
    <con:xquery><![CDATA[xquery version "1.0" encoding "UTF-8";

declare namespace tns = "http://igif.min-saude.pt/rnu/processarsituacaoutilizador";
declare namespace db = "http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador";
declare namespace xf = "http://tempuri.org/RNU-ProcessarSituacaoUtilizador/Resources/Transformations/DBOutputToResponse/";

declare function xf:DBOutputToResponse($outputParameters as element(db:OutputParameters), $classificarUtentesRequest as element(tns:ClassificarUtentesRequest), $erros as element(tns:Resultados)*) as element(tns:ClassificarUtentesResponse) {
    let $nnu := fn:data($classificarUtentesRequest/tns:Utentes/tns:Utente/tns:NNU)
    return
    <tns:ClassificarUtentesResponse>
        <tns:Resultados>
            {
                for $msg in $outputParameters/db:PROCESSAR_SITUACAO_UTILIZADOR/db:PROCESSAR_SITUACAO_UTILIZADOR_ITEM
                let $codigo := fn:data($msg/db:CODIGO)
                return
                    if (fn:starts-with($codigo, 'E')) then
                        <tns:Resultado>
                            <tns:NNU>{$nnu}</tns:NNU>
                            <tns:codigoErro>{fn:data($msg/db:CODIGO)}</tns:codigoErro>
                            <tns:mensagemErro>{fn:data($msg/db:MENSAGEM)}</tns:mensagemErro>
                        </tns:Resultado>
                    else
                        <tns:Resultado>
                            <tns:NNU>{$nnu}</tns:NNU>
                            <tns:codigoResposta>{fn:data($msg/db:CODIGO)}</tns:codigoResposta>
                            <tns:mensagemResposta>{fn:data($msg/db:MENSAGEM)}</tns:mensagemResposta>
                        </tns:Resultado>,
                $erros/tns:Resultado
            }
        </tns:Resultados>
    </tns:ClassificarUtentesResponse>
};

declare variable $outputParameters as element(db:OutputParameters) external;
declare variable $classificarUtentesRequest as element(tns:ClassificarUtentesRequest) external;
declare variable $erros as element(tns:Resultados)* external;

xf:DBOutputToResponse($outputParameters, $classificarUtentesRequest, $erros)]]></con:xquery>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/PartnerLinks/ProcessarSituacaoUtilizador/ProcessarSituacaoUtilizador_sp" namespace="http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador"/>
    </con:dependency>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/Resources/Schemas/ProcessarSituacaoUtilizador" namespace="http://igif.min-saude.pt/rnu/processarsituacaoutilizador"/>
    </con:dependency>
</con:xqueryEntry>
