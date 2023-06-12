USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[CALL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[CALL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[CALL_SELECT]
	@TENDER	UNIQUEIDENTIFIER
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

		SELECT ID, DATE, SUBJECT, SURNAME + ' ' + NAME + ' ' + PATRON + ' ' + PHONE AS FIO, NOTE
		FROM Tender.Call
		WHERE ID_TENDER = @TENDER AND STATUS = 1
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[CALL_SELECT] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[CALL_SELECT] TO rl_tender_u;
GO
