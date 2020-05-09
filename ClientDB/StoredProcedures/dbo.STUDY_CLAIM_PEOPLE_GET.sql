USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_CLAIM_PEOPLE_GET]
	@ID		UNIQUEIDENTIFIER
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
			SURNAME, NAME, PATRON, POSITION, PHONE, GR_COUNT, NOTE,
			ISNULL(SURNAME + ' ', '') + ISNULL(NAME + ' ', '') + ISNULL(PATRON, '') AS FIO
		FROM dbo.ClientStudyClaimPeople
		WHERE ID_CLAIM = @ID
		ORDER BY SURNAME, NAME, PATRON, POSITION

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_PEOPLE_GET] TO rl_client_study_claim_r;
GO