USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[OWNERSHIP_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[OWNERSHIP_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[OWNERSHIP_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT OwnershipID, OwnershipName
		FROM dbo.OwnershipTable
		WHERE @FILTER IS NULL
			OR OwnershipName LIKE @FILTER
		ORDER BY OwnershipName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[OWNERSHIP_SELECT] TO rl_ownership_r;
GO
