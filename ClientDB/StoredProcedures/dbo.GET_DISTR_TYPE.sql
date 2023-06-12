USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_DISTR_TYPE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_DISTR_TYPE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[GET_DISTR_TYPE]
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

		SELECT DistrTypeID, DistrTypeName, DistrTypeName AS DistrTypeShortName
		FROM dbo.DistrTypeTable
		ORDER BY DistrTypeOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_DISTR_TYPE] TO public;
GO
