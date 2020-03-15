USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[GLOBAL_SETTING_LOAD]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

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
			
			Maintenance.GlobalControlDocumentURL() AS CONTROL_DOCUMENT_URL,
			Maintenance.GlobalControlDocumentUser() AS CONTROL_DOCUMENT_USER,
			Maintenance.GlobalControlDocumentPass() AS CONTROL_DOCUMENT_PASS
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END