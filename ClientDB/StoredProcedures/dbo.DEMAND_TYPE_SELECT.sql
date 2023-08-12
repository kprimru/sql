USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DEMAND_TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DEMAND_TYPE_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[DEMAND_TYPE_SELECT]
	@FILTER	VARCHAR(200) = NULL OUTPUT
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

		SELECT  [Id],
				[Name],
				[Code],
				[SortIndex]
		FROM [dbo].[Demand->Type]
		WHERE @FILTER IS NULL
			OR [Name] LIKE @FILTER
		ORDER BY [SortIndex]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
