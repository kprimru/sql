USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_GET] 
	@ccid INT
AS

BEGIN
	SET NOCOUNT ON

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
				CO_ID, CO_NUM, CO_DATE, CO_BEG_DATE, 
				CO_END_DATE, CTT_NAME, CTT_ID, CO_ACTIVE, COP_ID, COP_NAME,
				CK_ID, CK_NAME, CO_IDENT, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL
		FROM 
			dbo.ContractTable co LEFT OUTER JOIN
			dbo.ContractTypeTable ctt ON ctt.CTT_ID = co.CO_ID_TYPE LEFT OUTER JOIN
			dbo.ContractPayTable ON COP_ID = CO_ID_PAY LEFT OUTER JOIN
			dbo.ContractKind ON CK_ID = CO_ID_KIND
		WHERE CO_ID = @ccid	

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
