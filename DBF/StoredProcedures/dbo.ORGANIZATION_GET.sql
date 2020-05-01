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

ALTER PROCEDURE [dbo].[ORGANIZATION_GET] 
	@id SMALLINT = NULL
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
			ORG_ID, ORG_PSEDO, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INDEX, 
			a.ST_ID, a.ST_NAME, 
			ORG_HOME, ORG_S_INDEX, b.ST_ID AS ST_S_ID, b.ST_NAME AS ST_S_NAME, 
			ORG_S_HOME, ORG_PHONE, BA_ID, BA_NAME, ORG_ACCOUNT, ORG_LORO, ORG_BIK, 
			ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO, 
			ORG_BUH_FAM, ORG_BUH_NAME, ORG_BUH_OTCH, ORG_DIR_FAM, ORG_DIR_NAME,
			ORG_DIR_OTCH, ORG_ACTIVE, ORG_1C
		FROM 
			dbo.OrganizationTable LEFT OUTER JOIN
			dbo.BankTable ON BA_ID = ORG_ID_BANK LEFT OUTER JOIN
			dbo.StreetTable a ON a.ST_ID = ORG_ID_STREET LEFT OUTER JOIN
			dbo.StreetTable b ON b.ST_ID = ORG_S_ID_STREET
		WHERE ORG_ID = @id 

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ORGANIZATION_GET] TO rl_organization_r;
GO