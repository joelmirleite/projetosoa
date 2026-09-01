<?xml version="1.0" encoding="UTF-8"?>
<con:xqueryEntry xmlns:con="http://www.bea.com/wli/sb/resources/config">
    <con:xquery><![CDATA[xquery version "1.0" encoding "UTF-8";

declare namespace tns = "http://igif.min-saude.pt/rnu/processarsituacaoutilizador";
declare namespace db = "http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador";
declare namespace xf = "http://tempuri.org/RNU-ProcessarSituacaoUtilizador/Resources/Transformations/DBOutputToResponse/";

declare function xf:DBOutputToResponse($outputParameters as element(db:OutputParameters), $erros as element(tns:Resultados)*) as element(tns:ClassificarUtentesResponse) {
    <tns:ClassificarUtentesResponse>
        <tns:Resultados>
            {
                for $res in $outputParameters/db:RESULTADOS/db:RESULTADOS_ITEM
                let $codigo := fn:data($res/db:CODIGO)
                return
                    if (fn:starts-with($codigo, 'E')) then
                        <tns:Resultado>
                            <tns:NNU>{fn:data($res/db:ICT_NNU)}</tns:NNU>
                            <tns:codigoErro>{fn:data($res/db:CODIGO)}</tns:codigoErro>
                            <tns:mensagemErro>{fn:data($res/db:MENSAGEM)}</tns:mensagemErro>
                        </tns:Resultado>
                    else
                        <tns:Resultado>
                            <tns:NNU>{fn:data($res/db:ICT_NNU)}</tns:NNU>
                            <tns:codigoResposta>{fn:data($res/db:CODIGO)}</tns:codigoResposta>
                            <tns:mensagemResposta>{fn:data($res/db:MENSAGEM)}</tns:mensagemResposta>
                        </tns:Resultado>,
                $erros/tns:Resultado
            }
        </tns:Resultados>
    </tns:ClassificarUtentesResponse>
};

declare variable $outputParameters as element(db:OutputParameters) external;
declare variable $erros as element(tns:Resultados)* external;

xf:DBOutputToResponse($outputParameters, $erros)]]></con:xquery>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/PartnerLinks/ProcessarSituacaoUtilizador/ProcessarSituacaoUtilizador_sp" namespace="http://xmlns.oracle.com/pcbpel/adapter/db/sp/ProcessarSituacaoUtilizador"/>
    </con:dependency>
    <con:dependency type="schema">
        <con:resource ref="RNU-ProcessarSituacaoUtilizador/Resources/Schemas/ProcessarSituacaoUtilizador" namespace="http://igif.min-saude.pt/rnu/processarsituacaoutilizador"/>
    </con:dependency>
</con:xqueryEntry>
