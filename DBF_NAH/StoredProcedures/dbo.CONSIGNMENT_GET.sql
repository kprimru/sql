USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONSIGNMENT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONSIGNMENT_GET]  AS SELECT 1')
GO

/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_GET]
	@csgid INT
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
			CSG_CONSIGN_NAME, CSG_CONSIGN_ADDRESS, CSG_CONSIGN_INN, CSG_CONSIGN_KPP,
			CSG_CONSIGN_OKPO, CSG_CLIENT_NAME, CSG_CLIENT_ADDRESS,
			CSG_CLIENT_PHONE, CSG_CLIENT_BANK, CSG_FOUND, CSG_NUM, CSG_DATE,
			ORG_ID, ORG_SHORT_NAME
		FROM
			dbo.ConsignmentTable LEFT OUTER JOIN
			dbo.OrganizationTable ON ORG_ID = CSG_ID_ORG
		WHERE CSG_ID = @csgid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_GET] TO rl_consignment_r;
GO
