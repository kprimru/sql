USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[TENDER_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[TENDER_WARNING]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Tender].[TENDER_WARNING]
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

		SELECT
			ClientID,
			ClientFullName,
			CALL_DATE
		FROM
			Tender.Tender a
			INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.ClientID
		WHERE a.STATUS = 1
			AND dbo.DateOf(CALL_DATE) = dbo.Dateof(GETDATE())
		ORDER BY CALL_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[TENDER_WARNING] TO rl_tender_warning;
GO
