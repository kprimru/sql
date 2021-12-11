USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GLOBAL_SETTING_LOAD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[GLOBAL_SETTING_LOAD]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[GLOBAL_SETTING_LOAD]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SELECT
            Maintenance.GlobalUSRJournal() AS USR_JOURNAL,
            Maintenance.GlobalEventProtocol()	AS EVENT_PROTOCOL,
            Maintenance.GlobalControlLogin() AS CONTROL_LOGIN,
            Maintenance.GlobalBcp() AS BCP,
            Maintenance.GlobalBcpEx() AS BCP_EX,
            Maintenance.GlobalUinfPath() AS UINF_PATH,
            Maintenance.GlobalKladrPath() AS KLADR_PATH,
            Maintenance.GlobalClientPhisicalDelete() AS CLIENT_DEL,
            Maintenance.GlobalProcedureLog() AS PROC_LOG,

            Maintenance.GlobalOrgName() AS ORG_NAME,
            Maintenance.GlobalUinf() AS UINF,
            Maintenance.GlobalTenderPath() AS TENDER_PATH,

            Maintenance.GlobalSttPath() AS STT_PATH,
            Maintenance.GlobalServiceReportPath() AS SERV_REPORT,
            Maintenance.GlobalUSRPath() AS USR_PATH,
            Maintenance.GlobalUSRIPPath() AS USR_IP_PATH,
            Maintenance.GlobalUSRControlPath() AS USR_CONTROL_PATH,
            Maintenance.GlobalSubhostName() AS SUBHOST_NAME,
            Maintenance.GlobalClaimPath() AS CLAIM_PATH,
            Maintenance.GlobalJurName() AS JUR_NAME,
            Maintenance.GlobalJurEmail() AS JUR_EMAIL,
            Maintenance.GlobalRicAddress() AS RIC_ADDRESS,
            Maintenance.GlobalRicLogin() AS RIC_LOGIN,
            Maintenance.GlobalRicPassword() AS RIC_PASSWORD,
            Maintenance.GlobalClientAutoClaim() AS CLIENT_AUTO_CLAIM,

            Maintenance.GlobalContractYear() AS CONTRACT_YEAR,

            Maintenance.GlobalContractOld() AS CONTRACT_OLD,

            Maintenance.GlobalControlDocumentURL() AS CONTROL_DOCUMENT_URL,
            Maintenance.GlobalControlDocumentUser() AS CONTROL_DOCUMENT_USER,
            Maintenance.GlobalControlDocumentPass() AS CONTROL_DOCUMENT_PASS,

            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'SEMINAR_MAIL_HOST') AS SEMINAR_MAIL_HOST,
            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'SEMINAR_MAIL_ADDRESS') AS SEMINAR_MAIL_ADDRESS,
            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'SEMINAR_MAIL_PASS') AS SEMINAR_MAIL_PASS,

            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'ONLINE_SERVICES_MAIL_HOST') AS ONLINE_SERVICES_MAIL_HOST,
            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'ONLINE_SERVICES_MAIL_ADDRESS') AS ONLINE_SERVICES_MAIL_ADDRESS,
            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'ONLINE_SERVICES_MAIL_PASS') AS ONLINE_SERVICES_MAIL_PASS,

            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'ONLINE_PASSWORD_PATH') AS ONLINE_PASSWORD_PATH,
            (SELECT TOP (1) GS_VALUE FROM Maintenance.GlobalSettings WHERE GS_NAME = 'ONLINE_PASSWORD_PASS') AS ONLINE_PASSWORD_PASS

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[GLOBAL_SETTING_LOAD] TO public;
GRANT EXECUTE ON [Maintenance].[GLOBAL_SETTING_LOAD] TO rl_settings;
GO
