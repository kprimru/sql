USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_CLAIM_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_CLAIM_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_CLAIM_FILTER]
	@STATUS		TINYINT,
	@CLIENT		NVARCHAR(512),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	INT,
	@TEACHER	INT,
	@RC			INT = NULL OUTPUT
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
			ClientID, ClientFullName, DATE,
			CASE a.STATUS
				WHEN 1 THEN 'Не выполнена'
				WHEN 4 THEN 'Отменена'
				WHEN 5 THEN 'Выполнена'
				WHEN 9 THEN 'Длительная'
				ELSE 'Неизвестно'
			END AS STATUS, ManagerName, TeacherName, NOTE,
			CASE
				WHEN TEACHER_NOTE = '' THEN ''
				ELSE CONVERT(VARCHAR(20), UPD_DATE, 104) + ' ' + TEACHER_NOTE
			END AS TEACHER_NOTE, MEETING_DATE, MEETING_NOTE,
			(
				SELECT TOP 1 z.UPD_USER
				FROM dbo.ClientStudyClaim z
				WHERE z.ID = a.ID OR a.ID_MASTER = a.ID
				ORDER BY z.UPD_DATE
			) AS AUTHOR
		FROM
			dbo.ClientStudyClaim a
			INNER JOIN dbo.ClientView b ON a.ID_CLIENT = b.ClientID
			LEFT OUTER JOIN dbo.TeacherTable c ON c.TeacherID = a.ID_TEACHER
		WHERE REPEAT = 0
			AND (
				(STATUS IN (1, 4, 5) AND @STATUS IS NULL)
				OR
				(STATUS IN (1, 4, 5) AND @STATUS = 0)
				OR
				(STATUS = 1 AND @STATUS = 1)
				OR
				(STATUS = 4 AND @STATUS = 2)
				OR
				(STATUS = 5 AND @STATUS = 3)
			)
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE <= @END OR @END IS NULL)
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ID_TEACHER = @TEACHER OR @TEACHER IS NULL)
		ORDER BY DATE DESC, ManagerName, ClientFullName

		SELECT @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_FILTER] TO rl_client_study_claim_filter;
GO
