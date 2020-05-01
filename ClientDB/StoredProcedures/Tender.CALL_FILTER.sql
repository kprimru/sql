USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[CALL_FILTER]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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

		SELECT a.ID, ClientID, DATE, SUBJECT, a.SURNAME + ' ' + a.NAME + ' ' + a.PATRON AS FIO, NOTE
		FROM
			Tender.Call a
			INNER JOIN Tender.Tender b ON a.ID_TENDER = b.ID
			INNER JOIN dbo.ClientTable c ON c.ClientID = b.ID_CLIENT
		WHERE a.STATUS = 1
			AND (a.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.DATE <= @END OR @END IS NULL)
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Tender].[CALL_FILTER] TO rl_tender_call_filter;
GRANT EXECUTE ON [Tender].[CALL_FILTER] TO rl_tender_u;
GO