USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GET_REG_COMPLECT]
	@COMPLECT_NAME VARCHAR(max),
	@RESULT INT = NULL OUTPUT
WITH EXECUTE AS OWNER
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
		-- ToDo...
		SELECT
			R.*, S.*
		FROM [dbo].[RegNodeTable] R
			LEFT JOIN [dbo].SystemTable S ON S.[SystemBaseName] = R.[SystemName]
		WHERE R.[Complect] in ( @COMPLECT_NAME )
		ORDER BY S.SystemOrder

		SELECT @RESULT = @@ERROR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
