USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REF_VALUE_COLUMN_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REF_VALUE_COLUMN_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[REF_VALUE_COLUMN_GET]
	@REF_NAME	NVARCHAR(128)
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

		SELECT ValueColumn
		FROM dbo.RefColumnMeta
		WHERE RefName = @REF_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
