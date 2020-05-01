USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STUDY_DETAIL_REPORT]
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@START2		SMALLDATETIME,
	@FINISH2	SMALLDATETIME,
	@TEACHER	NVARCHAR(MAX),
	@LAST_NOTE	BIT
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

		IF @START IS NULL
			SET @START = DATEADD(YEAR, -1, dbo.DateOf(GETDATE()))

		SELECT
			ClientID, ClientFullName, ManagerName, ServiceName, c.DATE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + ' (' + DistrTypeName + ')' + ', '
					FROM dbo.ClientDistrView WITH(NOEXPAND)
					WHERE ID_CLIENT = ClientID
						AND DS_REG = 0
						AND HostShort = 'К+'
					ORDER BY SystemOrder, DISTR FOR XML PATH('')
				)
			), 1, 2, '')) AS DISTR,
			REVERSE(STUFF(REVERSE(
				(
					SELECT SURNAME + ' ' + NAME + ' ' + PATRON + ISNULL(' (' + POSITION + ')', '') + CHAR(10)
					FROM dbo.ClientStudyPeople z
					WHERE z.ID_STUDY = c.ID
					ORDER BY SURNAME, NAME, PATRON, POSITION FOR XML PATH('')
				)), 1, 1, '')) AS PERSONAL,
			CASE WHEN EXISTS
				(
					SELECT *
					FROM dbo.ClientStudyPeople z
					WHERE z.ID_STUDY = c.ID
						AND z.ID_SERT_TYPE IS NOT NULL
				) THEN 'Есть'
				ELSE 'Нет'
			END AS SERTIFICAT,
			CASE
				WHEN @LAST_NOTE = 1 AND c.DATE = a.LAST_DATE THEN c.NOTE
				WHEN ISNULL(@LAST_NOTE, 0) = 0 THEN c.NOTE
				ELSE
					''
			END AS NOTE,
			CASE
				WHEN c.DATE = a.LAST_DATE THEN
					(
						SELECT MAX(z.DATE)
						FROM dbo.ClientStudyClaim z
						WHERE z.ID_CLIENT = a.ID_CLIENT
							AND z.STATUS IN (1, 9)
							AND z.DATE >= c.DATE
					)
				ELSE NULL
			END STUDY_CLAIM,
			TeacherName
		FROM
			(
				SELECT ID_CLIENT, MAX(DATE) AS LAST_DATE
				FROM dbo.ClientStudy
				WHERE STATUS = 1
					AND ID_PLACE IN (1, 2, 7)
					AND (DATE >= @START OR @START IS NULL)
					AND (DATE <= @FINISH OR @FINISH IS NULL)
					AND (ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
				GROUP BY ID_CLIENT
			) AS a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
			INNER JOIN dbo.ClientStudy c ON c.ID_CLIENT = b.ClientID
			INNER JOIN dbo.TeacherTable d ON d.TeacherID = c.ID_TEACHER
		WHERE c.STATUS = 1
			AND c.ID_PLACE IN (1, 2, 7)
			AND (DATE >= @START2 OR @START2 IS NULL)
			AND (DATE <= @FINISH2 OR @FINISH2 IS NULL)
		ORDER BY LAST_DATE DESC, ClientFullName, DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_STUDY_DETAIL_REPORT] TO rl_study_detail_report;
GO