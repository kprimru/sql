USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_CLAIM_SELECT_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_CLAIM_SELECT_NEW]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[STUDY_CLAIM_SELECT_NEW]
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

		SELECT
			ID, NULL AS ID_MASTER,
			ID AS ID_CLAIM, NULL AS ID_CLAIM_WORK,
			DATE, STUDY_DATE, CALL_DATE, NOTE, NULL AS TP,
			TeacherName, TEACHER_NOTE, MEETING_DATE, MEETING_NOTE, STATUS,
			CASE STATUS
				WHEN 1 THEN 'Активна'
				WHEN 4 THEN 'Отменена'
				WHEN 5 THEN 'Выполнена'
				WHEN 9 THEN 'Длительная'
			END AS STATUS_STR,
			(
				SELECT ISNULL(SURNAME + ' ', '') + ISNULL(NAME + ' ', '') + ISNULL(PATRON, '') + CHAR(10) + POSITION + CHAR(10) + PHONE + CHAR(10) + a.NOTE + CHAR(10)
				FROM dbo.ClientStudyClaimPeople z
				WHERE z.ID_CLAIM = a.ID
				ORDER BY z.ID FOR XML PATH('')
			) AS STUDENTS,
			(
				SELECT TOP 1 UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID_MASTER = a.ID OR z.ID = a.ID
				ORDER BY UPD_DATE
			) AS CREATE_USER
		FROM
			dbo.ClientStudyClaim a
			LEFT OUTER JOIN dbo.TeacherTable b ON a.ID_TEACHER = TeacherID
		WHERE ID_CLIENT = @CLIENT
			AND STATUS IN (1, 4, 5, 9)

		UNION

		SELECT
			a.ID, a.ID_CLAIM,
			a.ID_CLAIM, a.ID,
			a.DATE, NULL, NULL AS CALL_DATE, NULL, CASE TP WHEN 0 THEN 'Звонок' WHEN 1 THEN 'Визит' ELSE 'o_O' END AS TP,
			TEACHER, a.NOTE, MEETING_DATE, MEETING_NOTE, NULL, NULL, NULL, '' AS CREATE_USER
		FROM
			dbo.ClientStudyClaimWork a
			INNER JOIN dbo.ClientStudyClaim b ON a.ID_CLAIM = b.ID
		WHERE b.ID_CLIENT = @CLIENT AND a.STATUS = 1

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
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_SELECT_NEW] TO rl_client_study_claim_r;
GO
