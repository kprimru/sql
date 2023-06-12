USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REPORT_TYPE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REPORT_TYPE_GET]  AS SELECT 1')
GO

/*
Автор:		  коллектив авторов
Описание:
*/

ALTER PROCEDURE [dbo].[REPORT_TYPE_GET]
  @rtid int = NULL
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

		SELECT RTY_ID, RTY_NAME
		FROM dbo.ReportTypeTable
		WHERE RTY_ID = @rtid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REPORT_TYPE_GET] TO rl_report_type_r;
GO
