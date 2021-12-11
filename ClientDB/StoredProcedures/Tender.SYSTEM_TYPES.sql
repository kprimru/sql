USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[SYSTEM_TYPES]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[SYSTEM_TYPES]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[SYSTEM_TYPES]
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
		FROM Tender.SystemType

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[SYSTEM_TYPES] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[SYSTEM_TYPES] TO rl_tender_u;
GO
