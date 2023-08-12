USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_CLAIM_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_CLAIM_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[STUDY_CLAIM_SELECT]
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

		IF OBJECT_ID('tempdb..#claim') IS NOT NULL
			DROP TABLE #claim

		CREATE TABLE #claim
			(
				ID			UNIQUEIDENTIFIER,
				MST			UNIQUEIDENTIFIER,
				ID_CLAIM	UNIQUEIDENTIFIER,
				DATE		SMALLDATETIME,
				STUDY_DATE	SMALLDATETIME,
				CALL_DATE	SMALLDATETIME,
				NOTE		NVARCHAR(MAX),
				TEACH_NOTE	NVARCHAR(MAX),
				UPD_DATA	NVARCHAR(256),
				MET_DATE	DATETIME,
				MET_NOTE	NVARCHAR(MAX),
				P_FIO		NVARCHAR(512),
				P_POS		NVARCHAR(256),
				P_PHONE		NVARCHAR(256),
				P_NOTE		NVARCHAR(MAX),
				STATUS		TINYINT
			)

		INSERT INTO #claim(ID, ID_CLAIM, DATE, STUDY_DATE, CALL_DATE, NOTE, TEACH_NOTE, MET_DATE, MET_NOTE, UPD_DATA, P_FIO, STATUS)
			SELECT
				NEWID(), ID, DATE, STUDY_DATE, CALL_DATE, NOTE, TEACHER_NOTE, MEETING_DATE, MEETING_NOTE,
				UPD_USER + ' ' + CONVERT(NVARCHAR(32), UPD_DATE, 104) + ' ' + CONVERT(NVARCHAR(32), UPD_DATE, 108),
				ISNULL(TeacherName + ' ', '') + (
					SELECT 'Всего: ' +
						CONVERT(NVARCHAR(16),
							(
								SELECT COUNT(*)
								FROM dbo.ClientStudyClaimPeople b
								WHERE b.ID_CLAIM = a.ID
							))
				), STATUS
			FROM
				dbo.ClientStudyClaim a
				LEFT OUTER JOIN dbo.TeacherTable ON TeacherID = ID_TEACHER
			WHERE ID_CLIENT = @CLIENT AND STATUS IN (1, 4, 5)
			ORDER BY DATE DESC, ID DESC

		INSERT INTO #claim(ID, ID_CLAIM, MST, P_FIO, P_POS, P_PHONE, P_NOTE, NOTE, TEACH_NOTE)
			SELECT
				NEWID(), b.ID_CLAIM, b.ID, ISNULL(SURNAME + ' ', '') + ISNULL(NAME + ' ', '') + ISNULL(PATRON, ''),
				POSITION, PHONE, a.NOTE, b.NOTE, b.TEACH_NOTE
			FROM
				dbo.ClientStudyClaimPeople a
				INNER JOIN #claim b ON a.ID_CLAIM = b.ID_CLAIM
			ORDER BY 3

		SELECT
			ID, MST, ID_CLAIM, DATE, STUDY_DATE, CALL_DATE, NOTE, TEACH_NOTE, MET_DATE, MET_NOTE, UPD_DATA, P_FIO, P_POS, P_PHONE, P_NOTE,
			CASE STATUS
				WHEN 1 THEN 'Активна'
				WHEN 4 THEN 'Отменена'
				WHEN 5 THEN 'Выполнена'
				WHEN 9 THEN 'Длительная'
			END AS STATUS_STR,
			STATUS
		FROM #claim
		ORDER BY DATE DESC, P_FIO

		IF OBJECT_ID('tempdb..#claim') IS NOT NULL
			DROP TABLE #claim

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_SELECT] TO rl_client_study_claim_r;
GO
