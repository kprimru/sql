USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[CALC_DIRECTION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[CALC_DIRECTION_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Tender].[CALC_DIRECTION_SELECT]
	@FILTER	NVARCHAR(128) = NULL
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

		SELECT ID, NAME
		FROM Tender.CalcDirection
		ORDER BY NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[CALC_DIRECTION_SELECT] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[CALC_DIRECTION_SELECT] TO rl_tender_u;
GO
