USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_CLAIM_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_CLAIM_WARNING]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_CLAIM_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @IDs Table
	(
		Id			UniqueIdentifier,
		Client_Id 	Int,
		PersNote 	VarChar(Max),
		PRIMARY KEY CLUSTERED (Id)
	);

	DECLARE @ZVE Table
	(
		Client_Id	Int,
		Distrs		VarChar(Max),
		PRIMARY KEY CLUSTERED (Client_Id)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		INSERT INTO @IDs
		SELECT A.ID, a.ID_CLIENT, PERS_NOTE
		FROM dbo.ClientStudyClaim a
		CROSS APPLY
		(
			SELECT PERS_NOTE =
				REVERSE(STUFF(REVERSE(
					(
						SELECT z.NOTE + ', '
						FROM dbo.ClientStudyClaimPeople z
						WHERE z.ID_CLAIM = a.ID
							AND z.NOTE <> ''
						FOR XML PATH('')
					)
				), 1, 2, ''))
		) P
		WHERE a.STATUS IN (1, 9);

		SELECT
			A.ID, ID_CLIENT AS ClientID, DATE, STUDY_DATE, MEETING_DATE, b.ClientFullName + ISNULL(' (' + t.ClientTypeName + ')', '') AS ClientFullName, a.STATUS,
			NOTE = Cast(NOTE AS VarChar(4000)), REPEAT, TeacherName, ServiceName + ' (' + ManagerName + ')' AS ServiceName, CALL_DATE, TEACHER_NOTE,
			I.PersNote AS PERS_NOTE,
			L.UPD_USER AS AUTHOR_FILTER,
			L.UPD_USER + ' ' + ServiceName + ' (' + ManagerName + ')' AS AUTHOR,
			CASE a.STATUS
				WHEN 1 THEN 'Активна'
				WHEN 4 THEN 'Отменена'
				WHEN 5 THEN 'Выполнена'
				WHEN 9 THEN 'Длительная'
			END AS STATUS_STR,
			NULL AS ZVE_DISTR
		FROM @IDs I
		INNER JOIN dbo.ClientStudyClaim a ON I.ID = A.ID
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON b.ClientID = ID_CLIENT
		LEFT JOIN dbo.ClientTypeTable t ON t.ClientTypeID = b.CLientTypeID
		LEFT JOIN dbo.TeacherTable c ON c.TeacherID = a.ID_TEACHER
		OUTER APPLY
		(
			SELECT TOP 1 z.UPD_USER
			FROM dbo.ClientStudyClaim z
			WHERE z.ID_MASTER = a.ID
			ORDER BY z.UPD_DATE
		) LD
		OUTER APPLY
		(
			SELECT  UPD_USER = IsNull(LD.UPD_USER, A.UPD_USER)
		) L
		ORDER BY DATE DESC
		OPTION(RECOMPILE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_WARNING] TO rl_client_study_claim_warning;
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_WARNING] TO rl_study_warning;
GRANT EXECUTE ON [dbo].[STUDY_CLAIM_WARNING] TO rl_study_warning_manager;
GO
