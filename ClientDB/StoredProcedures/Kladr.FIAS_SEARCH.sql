USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Kladr].[FIAS_SEARCH]
	@SEARCH	NVARCHAR(512),
	@LEVEL	NVARCHAR(MAX),
	@CHILD	BIT,
	@REGION	NVARCHAR(3)
WITH EXECUTE AS OWNER
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

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'EXEC [PC275-SQL\SIGMA].Ric.Fias.SEARCH @SEARCH, @LEVEL, @CHILD, @REGION'
		
		EXEC sp_executesql @SQL, N'@SEARCH NVARCHAR(512), @LEVEL NVARCHAR(MAX), @CHILD BIT, @REGION NVARCHAR(3)', @SEARCH, @LEVEL, @CHILD, @REGION
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
