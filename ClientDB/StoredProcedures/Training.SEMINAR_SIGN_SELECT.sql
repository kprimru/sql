USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Training].[SEMINAR_SIGN_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Training].[SEMINAR_SIGN_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Training].[SEMINAR_SIGN_SELECT]
	@SCH_ID		UNIQUEIDENTIFIER,
	@CLIENT		VARCHAR(100)		=	NULL,
	@PERSONAL	VARCHAR(100)		=	NULL,
	@SERVICE	INT					=	NULL
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

		DECLARE @SUBJ	UNIQUEIDENTIFIER

		SELECT @SUBJ = TSC_ID_TS
		FROM Training.TrainingSchedule
		WHERE TSC_ID = @SCH_ID

		SELECT
			0 AS RESERVE, SSP_ID, SP_ID, ClientID, ServiceStatusIndex,
			ROW_NUMBER() OVER (ORDER BY ManagerName, ClientFullName, SSP_SURNAME, SSP_NAME, SSP_PATRON) AS RN,
			CLIENT_RN,
			ClientFullName, ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') AS SSP_FIO,
			SSP_POS, SSP_PHONE, ServiceName, ManagerName,
			SSP_NOTE, CASE ISNULL(SSP_NOTE, '') WHEN '' THEN 0 ELSE 1 END AS SSP_NOTE_EXISTS,
			SSP_CREATE_USER + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 104) + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 108) AS SSP_CREATE
		FROM
			(
				SELECT
					ClientID, ServiceStatusIndex, ManagerName, ServiceName, ClientFullName,
					ROW_NUMBER() OVER (ORDER BY ManagerName, ClientFullName) AS CLIENT_RN
				FROM
					(
						SELECT DISTINCT ClientID, ServiceStatusIndex, ManagerName, ServiceName, ClientFullName
						FROM
							dbo.ClientView WITH(NOEXPAND)
							INNER JOIN Training.SeminarSign ON SP_ID_CLIENT = ClientID
							INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
						WHERE SP_ID_SEMINAR = @SCH_ID AND SSP_CANCEL = 0
							AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
							AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
							AND (ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') + ISNULL(SSP_POS + ' ', '') LIKE @PERSONAL OR @PERSONAL IS NULL)
					) AS o_O
			) AS cl
			INNER JOIN Training.SeminarSign ON SP_ID_CLIENT = ClientID
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		WHERE SP_ID_SEMINAR = @SCH_ID AND SSP_CANCEL = 0
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') + ISNULL(SSP_POS + ' ', '') LIKE @PERSONAL OR @PERSONAL IS NULL)

		UNION ALL

		SELECT
			1 AS RESERVE, SR_ID, NULL, ClientID, ServiceStatusIndex,
			ROW_NUMBER() OVER (ORDER BY ManagerName, ClientFullName, SR_SURNAME, SR_NAME, SR_PATRON) AS RN,
			CLIENT_RN,
			ClientFullName, ISNULL(SR_SURNAME + ' ', '') + ISNULL(SR_NAME + ' ', '') + ISNULL(SR_PATRON, '') AS SSP_FIO,
			SR_POS, SR_PHONE, ServiceName, ManagerName,
			SR_NOTE, CASE ISNULL(SR_NOTE, '') WHEN '' THEN 0 ELSE 1 END AS SSP_NOTE_EXISTS,
			SR_CREATE_USER + ' ' + CONVERT(NVARCHAR(128), SR_CREATE_DATE, 104) + ' ' + CONVERT(NVARCHAR(128), SR_CREATE_DATE, 108) AS SSP_CREATE
		FROM
			(
				SELECT
					ClientID, ServiceStatusIndex, ManagerName, ServiceName, ClientFullName,
					ROW_NUMBER() OVER (ORDER BY ManagerName, ClientFullName) AS CLIENT_RN
				FROM
					(
						SELECT DISTINCT ClientID, ServiceStatusIndex, ManagerName, ServiceName, ClientFullName
						FROM
							dbo.ClientView WITH(NOEXPAND)
							INNER JOIN Training.SeminarReserve ON SR_ID_CLIENT = ClientID
						WHERE SR_ID_SUBJECT = @SUBJ
							AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
							AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
							AND (ISNULL(SR_SURNAME + ' ', '') + ISNULL(SR_NAME + ' ', '') + ISNULL(SR_PATRON, '') LIKE @PERSONAL OR @PERSONAL IS NULL)
					) AS o_O
			) AS cl
			INNER JOIN Training.SeminarReserve ON SR_ID_CLIENT = ClientID
		WHERE SR_ID_SUBJECT = @SUBJ
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ISNULL(SR_SURNAME + ' ', '') + ISNULL(SR_NAME + ' ', '') + ISNULL(SR_PATRON, '') + ISNULL(SR_POS + ' ', '') LIKE @PERSONAL OR @PERSONAL IS NULL)

		UNION ALL

		SELECT
			2 AS RESERVE, SSP_ID, SP_ID, ClientID, ServiceStatusIndex,
			NULL AS RN,
			NULL AS CLIENT_RN,
			ClientFullName, ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') AS SSP_FIO,
			SSP_POS, SSP_PHONE, ServiceName, ManagerName,
			SSP_NOTE, CASE ISNULL(SSP_NOTE, '') WHEN '' THEN 0 ELSE 1 END AS SSP_NOTE_EXISTS,
			SSP_CREATE_USER + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 104) + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 108) AS SSP_CREATE
		FROM
			dbo.ClientView WITH(NOEXPAND)
			INNER JOIN Training.SeminarSign ON SP_ID_CLIENT = ClientID
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		WHERE SP_ID_SEMINAR = @SCH_ID AND SSP_CANCEL = 1
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') + ISNULL(SSP_POS + ' ', '') LIKE @PERSONAL OR @PERSONAL IS NULL)

		UNION ALL

		SELECT
			3 AS RESERVE, SSP_ID, SP_ID, ClientID, ServiceStatusIndex,
			NULL AS RN,
			NULL AS CLIENT_RN,
			ClientFullName, ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') AS SSP_FIO,
			SSP_POS, SSP_PHONE, ServiceName, ManagerName,
			SSP_NOTE, CASE ISNULL(SSP_NOTE, '') WHEN '' THEN 0 ELSE 1 END AS SSP_NOTE_EXISTS,
			SSP_CREATE_USER + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 104) + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 108) AS SSP_CREATE
		FROM
			dbo.ClientView WITH(NOEXPAND)
			INNER JOIN Training.SeminarSign ON SP_ID_CLIENT = ClientID
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		WHERE SP_ID_SEMINAR = @SCH_ID AND SSP_CANCEL = 2
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') + ISNULL(SSP_POS + ' ', '') LIKE @PERSONAL OR @PERSONAL IS NULL)

		UNION ALL

		SELECT
			4 AS RESERVE, SSP_ID, SP_ID, ClientID, ServiceStatusIndex,
			NULL AS RN,
			NULL AS CLIENT_RN,
			ClientFullName, ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') AS SSP_FIO,
			SSP_POS, SSP_PHONE, ServiceName, ManagerName,
			SSP_NOTE, CASE ISNULL(SSP_NOTE, '') WHEN '' THEN 0 ELSE 1 END AS SSP_NOTE_EXISTS,
			SSP_CREATE_USER + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 104) + ' ' + CONVERT(NVARCHAR(128), SSP_CREATE_DATE, 108) AS SSP_CREATE
		FROM
			dbo.ClientView WITH(NOEXPAND)
			INNER JOIN Training.SeminarSign ON SP_ID_CLIENT = ClientID
			INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
		WHERE SP_ID_SEMINAR = @SCH_ID AND SSP_CANCEL = 3
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') + ISNULL(SSP_POS + ' ', '') LIKE @PERSONAL OR @PERSONAL IS NULL)

		ORDER BY RESERVE, ManagerName, ClientFullName, SSP_FIO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[SEMINAR_SIGN_SELECT] TO rl_training_r;
GO
