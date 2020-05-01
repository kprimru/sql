USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_PEOPLE_GET]
	@ID		UNIQUEIDENTIFIER,
	@CLAIM	UNIQUEIDENTIFIER
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

		IF @CLAIM IS NULL
			SELECT 
				SURNAME, a.NAME, PATRON, POSITION, NUM, GR_COUNT, ID_SERT_TYPE, b.NAME AS SERT_NAME, SERT_COUNT, NOTE,
				ISNULL(SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(PATRON, '') +
					CASE WHEN GR_COUNT IS NULL THEN '' ELSE ' (' + CONVERT(NVARCHAR(32), GR_COUNT) + ')' END AS FIO,
				ID_RDD_POS, c.NAME AS RDD_POS_NAME
			FROM
				dbo.ClientStudyPeople a
				LEFT OUTER JOIN dbo.SertificatType b ON a.ID_SERT_TYPE = b.ID
				LEFT OUTER JOIN dbo.RDDPosition c ON c.ID = a.ID_RDD_POS
			WHERE a.ID_STUDY = @ID
		ELSE
			SELECT 
				SURNAME, a.NAME, PATRON, POSITION, NUM, GR_COUNT, ID_SERT_TYPE, b.NAME AS SERT_NAME, SERT_COUNT, NOTE,
				ISNULL(SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(PATRON, '') +
					CASE WHEN GR_COUNT IS NULL THEN '' ELSE ' (' + CONVERT(NVARCHAR(32), GR_COUNT) + ')' END AS FIO,
				ID_RDD_POS, c.NAME AS RDD_POS_NAME
			FROM
				dbo.ClientStudyPeople a
				LEFT OUTER JOIN dbo.SertificatType b ON a.ID_SERT_TYPE = b.ID
				LEFT OUTER JOIN dbo.RDDPosition c ON c.ID = a.ID_RDD_POS
			WHERE a.ID_STUDY = @ID

			UNION ALL

			SELECT
				SURNAME, NAME, PATRON, POSITION, CASE REPEAT WHEN 1 THEN 2 ELSE 1 END, NULL, NULL, NULL, NULL, NULL,
				ISNULL(SURNAME + ' ', '') + ISNULL(NAME + ' ', '') + ISNULL(PATRON, '') AS FIO,
				NULL, NULL
			FROM
				dbo.ClientStudyClaimPeople a
				INNER JOIN dbo.ClientStudyClaim b ON a.ID_CLAIM = b.ID
			WHERE ID_CLAIM = @CLAIM

			ORDER BY SURNAME, NAME, PATRON, POSITION

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[STUDY_PEOPLE_GET] TO rl_client_study_r;
GO