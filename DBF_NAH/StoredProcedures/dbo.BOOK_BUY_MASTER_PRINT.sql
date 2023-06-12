USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[BOOK_BUY_MASTER_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[BOOK_BUY_MASTER_PRINT]  AS SELECT 1')
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[BOOK_BUY_MASTER_PRINT]
	@orgid SMALLINT
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
			ORG_SHORT_NAME, ORG_INN, ORG_KPP,
			(ORG_BUH_FAM + ' ' + LEFT(ORG_BUH_NAME, 1) + '.' + LEFT(ORG_BUH_OTCH, 1) + '.') AS ORG_BUH_SHORT
		FROM dbo.OrganizationTable
		WHERE ORG_ID = @orgid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END



GO
GRANT EXECUTE ON [dbo].[BOOK_BUY_MASTER_PRINT] TO rl_book_buy_p;
GO
