USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[STUDY_CLAIM_CALL_EMPTY_NOTE]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @LastDate       SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @LastDate = DateAdd(MONTH, -3, GETDATE())

        SELECT
            [Клиент]        = C.[ClientFullName],
            [Дата заявки]   = SC.[DATE],
            [Дата звонка]   = W.[DATE],
            [Преподаватель] = W.TEACHER
        FROM dbo.ClientStudyClaim AS SC
        INNER JOIN dbo.ClientStudyClaimWork AS W ON SC.[ID] = W.ID_CLAIM
        INNER JOIN dbo.ClientView AS C WITH(NOEXPAND) ON C.ClientID = SC.ID_CLIENT
        WHERE W.TP = 0 AND IsNull(W.NOTE, '') = ''
            AND W.STATUS = 1
            AND SC.STATUS IN (1, 4, 5, 9)
            AND W.[DATE] >= @LastDate
        ORDER BY W.[DATE] DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[STUDY_CLAIM_CALL_EMPTY_NOTE] TO rl_report;
GO
