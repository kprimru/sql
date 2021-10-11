USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[TENDER_GET]
	@ID	UNIQUEIDENTIFIER
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
			ID_LAW, CLIENT, CONTRACT_START, CONTRACT_FINISH, ACT_START, ACT_FINISH, TENDER_START, TENDER_FINISH,
			SURNAME, NAME, PATRON, POSITION, PHONE, EMAIL, CALL_DATE, INFO_DATE, ID_STATUS, MANAGER, MANAGER_DATE, ID_MANAGER,
			MANAGER_NOTE, LET_DATE, LET_NUM
			INTO #tmp
		FROM Tender.Tender
		WHERE ID = @ID

		SELECT *
		FROM #tmp

		DROP TABLE #tmp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[TENDER_GET] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[TENDER_GET] TO rl_tender_u;
GO
