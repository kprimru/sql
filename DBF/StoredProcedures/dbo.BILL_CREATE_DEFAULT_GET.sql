USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[BILL_CREATE_DEFAULT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[BILL_CREATE_DEFAULT_GET]  AS SELECT 1')
GO

/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[BILL_CREATE_DEFAULT_GET]
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

		SELECT SO_ID, SO_NAME
		FROM dbo.SaleObjectTable
		WHERE SO_ID = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[BILL_CREATE_DEFAULT_GET] TO rl_bill_w;
GO
