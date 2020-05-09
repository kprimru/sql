USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_DUTY_FILTER2]
	@START		SMALLDATETIME 	= NULL,
	@FINISH		SMALLDATETIME 	= NULL,
	@CALL_TYPE	NVARCHAR(MAX)	= NULL,
	@DUTY		NVARCHAR(MAX)	= NULL,
	@STATUS		TINYINT			= NULL,
	@COMMENT	NVARCHAR(512)	= NULL,
	@SERVICE	INT				= NULL,
	@SYSTEM		INT				= NULL,
	@NPO		TINYINT			= NULL,
	@DIRECTION	NVARCHAR(MAX)	= NULL,
	@RESULT		TINYINT			= NULL,
	@NOTIFY		TINYINT			= NULL,
	@CATEGORY	TinyInt			= NULL,
	@LINK		TINYINT			= NULL
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

		SET @FINISH = DATEADD(DAY, 1, @FINISH)

		SELECT
			a.ClientID, b.ClientFullName,
			CONVERT(NVARCHAR(32), dbo.DateOf(ClientDutyDateTime), 104) as ClientDutyDateStr,
			DutyName, CallTypeName, ClientDutyDocs, ClientDutyQuest, ClientDutyComment,
			ServiceName, ManagerName, ClientDutyGive,
			ISNULL(ClientDutySurname + ' ' + ClientDutyName + ' ' + ClientDutyPatron, ClientDutyContact) AS ClientDutyContact,
			ClientDutyPos, CASE ClientDutyNPO WHEN 1 THEN 'Да' ELSE 'Нет' END AS ClientDutyNPO,
			ClientDutyComplete, ClientDutyUncomplete,
			ClientDutyAnswer, g.NAME AS DIR_NAME,
			REVERSE(STUFF(REVERSE((
				SELECT SystemShortName + ', '
				FROM
					dbo.ClientDutyIBTable INNER JOIN
					dbo.SystemTable ON SystemTable.SystemID = ClientDutyIBTable.SystemID
				WHERE a.ClientDutyID = ClientDutyIBTable.ClientDutyID
				ORDER BY SystemShortName FOR XML PATH('')
			)),1,1,'')) AS IBList,
			REVERSE(STUFF(REVERSE((
				SELECT SystemShortName + ', '
				FROM
					dbo.ClientDistrView WITH(NOEXPAND)
				WHERE ID_CLIENT = b.ClientID AND DS_REG = 0
				ORDER BY SystemShortName FOR XML PATH('')
			)),1,1,'')) AS SystemList,
			REVERSE(STUFF(REVERSE((
				SELECT Convert(VARCHAR(10), SystemTable.SystemID) + ', '
				FROM
					dbo.ClientDutyIBTable INNER JOIN
					dbo.SystemTable ON SystemTable.SystemID = ClientDutyIBTable.SystemID
				WHERE a.ClientDutyID = ClientDutyIBTable.ClientDutyID
				ORDER BY SystemShortName FOR XML PATH('')
			)),1,1,'')) AS CheckedIB,
			CASE j.NOTIFY WHEN 0 THEN 'Да' WHEN 1 THEN 'Нет' ELSE 'Не указано' END AS NOTIFY,
			CASE i.ANSWER WHEN 0 THEN 'Да' WHEN 1 THEN 'Нет' ELSE 'Не указано' END AS ANSWER,
			CASE i.SATISF WHEN 0 THEN 'Да' WHEN 1 THEN 'Нет' ELSE 'Не указано' END AS SATISF,
			ServiceStatusIndex, a.ID_DIRECTION, a.CallTypeID, a.DutyID, a.ID_GRANT_TYPE
		FROM
			[dbo].[ClientList@Get?Read]()
			INNER JOIN dbo.ClientDutyTable a ON WCL_ID = ClientID
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
			INNER JOIN dbo.ClientTable h ON h.ClientID = b.ClientID
			INNER JOIN dbo.DutyTable c ON c.DutyID = a.DutyID
			LEFT OUTER JOIN dbo.CallTypeTable f ON f.CallTypeID = a.CallTypeID
			LEFT OUTER JOIN dbo.CallDirection g ON g.ID = a.ID_DIRECTION
			LEFT OUTER JOIN dbo.ClientDutyNotify j ON j.ID_DUTY = a.ClientDutyID
			LEFT OUTER JOIN dbo.ClientDutyResult i ON i.ID_DUTY = a.ClientDutyID
		WHERE
			a.STATUS = 1
			AND (ClientDutyDateTime >= @START OR @START IS NULL)
			AND (ClientDutyDateTime < @FINISH OR @FINISH IS NULL) 
			AND (a.DutyID IN (SELECT ID FROM dbo.TableIDFromXML(@DUTY)) OR @DUTY IS NULL)
			AND (a.CallTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@CALL_TYPE)) OR @CALL_TYPE IS NULL)
			AND (ClientDutyComment LIKE @COMMENT OR ClientDutyQuest LIKE @COMMENT OR @COMMENT IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ID_DIRECTION IN (SELECT ID FROM dbo.TableGUIDFromXML(@DIRECTION)) OR @DIRECTION IS NULL)
			AND (@LINK IS NULL OR @LINK = 0 OR @LINK = 1 AND LINK = 1 OR @LINK = 2 AND LINK = 0)
			AND (h.ClientTypeId = @CATEGORY OR @CATEGORY IS NULL)
			AND	(
					@SYSTEM IS NULL
					OR
					EXISTS(
							SELECT *
							FROM dbo.ClientDutyIBTable z
							WHERE z.ClientDutyID = a.ClientDutyID
								AND SystemID = @SYSTEM
						)
				)
			AND (@STATUS IS NULL OR @STATUS = 0 OR @STATUS = 1 AND ClientDutyComplete = 1 OR @STATUS = 2 AND ClientDutyComplete = 0)
			AND (@NPO IS NULL OR @NPO = 0 OR @NPO = 1 AND ClientDutyNPO = 1 OR @NPO = 2 AND ClientDutyNPO = 0)
			AND (
					@RESULT IS NULL
					OR @RESULT = 0
					OR
						@RESULT = 2
						AND NOT EXISTS(
									SELECT *
									FROM dbo.ClientDutyResult z
									WHERE z.STATUS = 1
										AND z.ID_DUTY = a.ClientDutyID
									)
					OR
						@RESULT = 1
						AND EXISTS(
									SELECT *
									FROM dbo.ClientDutyResult z
									WHERE z.STATUS = 1
										AND z.ID_DUTY = a.ClientDutyID
									)
				)
			AND (
					@NOTIFY IS NULL
					OR @NOTIFY = 0
					OR
						@NOTIFY = 2
						AND NOT EXISTS(
									SELECT *
									FROM dbo.ClientDutyNotify z
									WHERE z.STATUS = 1
										AND z.ID_DUTY = a.ClientDutyID
									)
					OR
						@NOTIFY = 1
						AND EXISTS(
									SELECT *
									FROM dbo.ClientDutyNotify z
									WHERE z.STATUS = 1
										AND z.ID_DUTY = a.ClientDutyID
									)
				)

		ORDER BY ClientDutyDateTime DESC, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_FILTER2] TO rl_filter_duty;
GO