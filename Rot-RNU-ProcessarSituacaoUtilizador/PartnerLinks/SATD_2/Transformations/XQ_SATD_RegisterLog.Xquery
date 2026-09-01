<?xml version="1.0" encoding="UTF-8"?>
<con:xqueryEntry xmlns:con="http://www.bea.com/wli/sb/resources/config">
    <con:xquery><![CDATA[xquery version "2004-draft";
(:: pragma  parameter="$RequestPayload" type="anyType" ::)
(:: pragma  parameter="$ResponsePayload" type="anyType" ::)
(:: pragma bea:global-element-return element="ns1:RegistoDadosLogProcessRequest" location="../Schemas/RequestStructure.xsd" ::)

declare namespace ns2 = "http://xmlns.dmm.spms.pt/201207/Integration";
declare namespace ns1 = "http://xmlns.dmm.spms.pt/201310/RegistoDadosLog";
declare namespace ns0 = "http://xmlns.dmm.spms.pt/201310/RequestStructure";
declare namespace xf = "http://tempuri.org/Rot-RNU-ProcessarSituacaoUtilizador/XQ/XQ_SATD_RegisterLog/";

declare function xf:XQ_SATD_RegisterLog($Username as xs:string,
    $ServiceURI as xs:string,
    $ServiceOperation as xs:string,
    $ChavePedido as xs:string,
    $ChavePedidoRelacionado as xs:string,
    $RequestPayload as element(*),
    $ResponsePayload as element(*))
    as element(ns1:RegistoDadosLogProcessRequest) {
        <ns1:RegistoDadosLogProcessRequest>
            <ns1:MessageHeader>
                <ns2:De>
                    <ns2:Chave>
                        <ns2:Id>{ $Username }</ns2:Id>
                        <ns2:Cifra>
                            <ns2:Codigo>1</ns2:Codigo>
                        </ns2:Cifra>
                    </ns2:Chave>
                </ns2:De>
                <ns2:EnviadoEm>{ fn:current-dateTime() }</ns2:EnviadoEm>
                <ns2:ActivadoEm>{ fn:current-dateTime() }</ns2:ActivadoEm>
                <ns2:ChavePedido>{ $ChavePedido }</ns2:ChavePedido>
            </ns1:MessageHeader>
            <ns1:MessageBody>
                <ns1:RequestBody>
                    <ns0:Service>
                        <ns0:ServiceURI>{ $ServiceURI }</ns0:ServiceURI>
                         <ns0:ServiceOperation>{ fn:concat($ServiceOperation,string('_12c'))}</ns0:ServiceOperation>
                    </ns0:Service>
                    <ns0:RequestPayload>{ $RequestPayload/@* , $RequestPayload/node() }</ns0:RequestPayload>
                    <ns0:ResponsePayload>{ $ResponsePayload/@* , $ResponsePayload/node() }</ns0:ResponsePayload>
                </ns1:RequestBody>
            </ns1:MessageBody>
        </ns1:RegistoDadosLogProcessRequest>
};

declare variable $Username as xs:string external;
declare variable $ServiceURI as xs:string external;
declare variable $ServiceOperation as xs:string external;
declare variable $ChavePedido as xs:string external;
declare variable $ChavePedidoRelacionado as xs:string external;
declare variable $RequestPayload as element(*) external;
declare variable $ResponsePayload as element(*) external;

xf:XQ_SATD_RegisterLog($Username,
    $ServiceURI,
    $ServiceOperation,
    $ChavePedido,
    $ChavePedidoRelacionado,
    $RequestPayload,
    $ResponsePayload)]]></con:xquery>
</con:xqueryEntry>
