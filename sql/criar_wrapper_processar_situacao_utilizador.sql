-- Wrapper para processamento em lote do servico RNU-ProcessarSituacaoUtilizador
-- Cria os tipos de colecao/registo (T_UTENTES_ARR, T_RESULTADOS_ARR) e a funcao
-- processar_situacao_utilizador_lista no package inscr_api_ws_osb.
--
-- Executar com um user que tenha privilegios para criar objectos no schema RNU
-- (ex: sqlplus user/password@BD @criar_wrapper_processar_situacao_utilizador.sql).
-- Apos criacao, o JCA/OSB chamara inscr_api_ws_osb.processar_situacao_utilizador_lista.

PROMPT Criar tipo de registo de utente (RNU.T_UTENTE_REC)...

CREATE OR REPLACE TYPE RNU.T_UTENTE_REC AS OBJECT
(
  ICT_NNU              NUMBER,
  ICT_DATA_NASC        DATE,
  ICT_DATA_PROC_SDM    DATE,
  ICT_SITUACAO         VARCHAR2(100)
);
/

PROMPT Criar tipo tabela de utentes (RNU.T_UTENTES_ARR)...

CREATE OR REPLACE TYPE RNU.T_UTENTES_ARR AS TABLE OF RNU.T_UTENTE_REC;
/

PROMPT Criar tipo de registo de resultado (RNU.T_RESULTADO_REC)...

CREATE OR REPLACE TYPE RNU.T_RESULTADO_REC AS OBJECT
(
  ICT_NNU              NUMBER,
  CODIGO               VARCHAR2(25),
  MENSAGEM             VARCHAR2(512)
);
/

PROMPT Criar tipo tabela de resultados (RNU.T_RESULTADOS_ARR)...

CREATE OR REPLACE TYPE RNU.T_RESULTADOS_ARR AS TABLE OF RNU.T_RESULTADO_REC;
/

PROMPT Criar package inscr_api_ws_osb (especificacao)...

CREATE OR REPLACE PACKAGE RNU.inscr_api_ws_osb AS
  FUNCTION processar_situacao_utilizador_lista (
    UTENTES      IN RNU.T_UTENTES_ARR,
    ICT_ENTIDADE IN VARCHAR2
  ) RETURN RNU.T_RESULTADOS_ARR;
END inscr_api_ws_osb;
/

PROMPT Criar package inscr_api_ws_osb (corpo)...

CREATE OR REPLACE PACKAGE BODY RNU.inscr_api_ws_osb AS
  FUNCTION processar_situacao_utilizador_lista (
    UTENTES      IN RNU.T_UTENTES_ARR,
    ICT_ENTIDADE IN VARCHAR2
  ) RETURN RNU.T_RESULTADOS_ARR AS
    v_msg        igif.t_cod_msg_arr;
    v_resultados RNU.T_RESULTADOS_ARR := RNU.T_RESULTADOS_ARR();
  BEGIN
    IF UTENTES IS NOT NULL THEN
      FOR i IN 1 .. UTENTES.COUNT LOOP
        v_msg := RNU.inscr_api_ws.processar_situacao_utilizador(
          ict_nnu           => UTENTES(i).ICT_NNU,
          ict_data_nasc     => UTENTES(i).ICT_DATA_NASC,
          ict_data_proc_sdm => UTENTES(i).ICT_DATA_PROC_SDM,
          ict_situacao      => UTENTES(i).ICT_SITUACAO,
          ict_entidade      => ICT_ENTIDADE
        );

        IF v_msg IS NOT NULL THEN
          FOR j IN 1 .. v_msg.COUNT LOOP
            v_resultados.EXTEND;
            v_resultados(v_resultados.LAST) := RNU.T_RESULTADO_REC(
              UTENTES(i).ICT_NNU,
              v_msg(j).CODIGO,
              v_msg(j).MENSAGEM
            );
          END LOOP;
        END IF;
      END LOOP;
    END IF;

    RETURN v_resultados;
  END processar_situacao_utilizador_lista;
END inscr_api_ws_osb;
/

PROMPT Concluido.
