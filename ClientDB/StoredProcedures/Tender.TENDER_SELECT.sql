USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[TENDER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[TENDER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[TENDER_SELECT]
	@CLIENT	INT
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

		SELECT a.ID, INFO_DATE, CALL_DATE,
			b.NAME AS LAW_NAME,
			c.NAME AS STAT_NAME
		FROM
			Tender.Tender a
			INNER JOIN Tender.Status c ON a.ID_STATUS = c.ID
			LEFT OUTER JOIN Tender.Law b ON a.ID_LAW = b.ID
		WHERE ID_CLIENT = @CLIENT AND STATUS = 1
		ORDER BY INFO_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[TENDER_SELECT] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[TENDER_SELECT] TO rl_tender_u;
GO
