USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_INNOVATION_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@INNOVATION	UNIQUEIDENTIFIER,
	@SERVICE	INT,
	@MANAGER	NVARCHAR(MAX),
	@STATUS		INT,
	@CONTROL	INT,
	@FAIL_CNT	INT = NULL OUTPUT
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

		IF OBJECT_ID('tempdb..#inn') IS NOT NULL
			DROP TABLE #inn

		SELECT
			ClientID, ManagerName, ServiceName, ClientFullName, ServiceStatusIndex,
			CASE PERS WHEN 1 THEN 'Да' ELSE 'Нет' END AS PERS_STR,
			PERS,
			CASE CONTROL_EXISTS WHEN 1 THEN 'Да' ELSE 'Нет' END AS CONTROL_STR,
			CONTROL_EXISTS,
			CASE CONTROL_OK WHEN 1 THEN 'Да' ELSE 'Нет' END AS OK_STR,
			CONTROL_OK,
			CASE CONTROL_FAIL WHEN 1 THEN 'Да' ELSE 'Нет' END AS FAIL_STR,
			CONTROL_FAIL,
			CONTROL_NOTE, PERS_LIST
		INTO #inn
		FROM
			(
				SELECT
					b.ClientID, b.ManagerName, b.ServiceName, b.ClientFullName, b.ServiceStatusIndex,
					CONVERT(BIT, (
						SELECT COUNT(*)
						FROM dbo.ClientInnovationPersonal z
						WHERE z.ID_INNOVATION = a.ID
					)) AS PERS,
					CONVERT(BIT, (
						SELECT COUNT(*)
						FROM
							dbo.ClientInnovationControl z
							INNER JOIN dbo.ClientInnovationPersonal y ON z.ID_PERSONAL = y.ID
						WHERE y.ID_INNOVATION = a.ID
					)) AS CONTROL_EXISTS,
					CONVERT(BIT, (
						SELECT COUNT(*)
						FROM
							dbo.ClientInnovationControl z
							INNER JOIN dbo.ClientInnovationPersonal y ON z.ID_PERSONAL = y.ID
						WHERE y.ID_INNOVATION = a.ID
							AND z.RESULT = 1
					)) AS CONTROL_OK,
					CONVERT(BIT, (
						SELECT COUNT(*)
						FROM
							dbo.ClientInnovationControl z
							INNER JOIN dbo.ClientInnovationPersonal y ON z.ID_PERSONAL = y.ID
						WHERE y.ID_INNOVATION = a.ID
							AND z.RESULT <> 1
					)) AS CONTROL_FAIL,
					(
						SELECT TOP 1 z.NOTE
						FROM
							dbo.ClientInnovationControl z
							INNER JOIN dbo.ClientInnovationPersonal y ON z.ID_PERSONAL = y.ID
						WHERE y.ID_INNOVATION = a.ID
							AND z.NOTE <> ''
					) AS CONTROL_NOTE,
					REVERSE(STUFF(REVERSE(
						(
							SELECT z.SURNAME + ' ' + z.NAME + ' ' + z.PATRON + ' (' + z.POSITION + ')' + CHAR(10)
							FROM dbo.ClientInnovationPersonal z
							WHERE z.ID_INNOVATION = a.ID
							ORDER BY SURNAME, NAME, PATRON, POSITION FOR XML PATH('')
						)), 1, 1, '')) AS PERS_LIST
				FROM
					dbo.ClientInnovation a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
				WHERE a.ID_INNOVATION = @INNOVATION
					AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
					AND
						(
							EXISTS
							(
								SELECT *
								FROM
									dbo.ClientInnovationControl z
									INNER JOIN dbo.ClientInnovationPersonal y ON z.ID_PERSONAL = y.ID
								WHERE y.ID_INNOVATION = a.ID
									AND (z.DATE >= @BEGIN OR @BEGIN IS NULL)
									AND (z.DATE <= @END OR @END IS NULL)
							) OR (@BEGIN IS NULL AND @END IS NULL)
						)
			) AS o_O
		WHERE (@STATUS = 0 OR @STATUS = 1 AND PERS = 1 OR @STATUS = 2 AND PERS = 0 OR @STATUS IS NULL)
			AND (@CONTROL = 0 OR @CONTROL = 1 AND CONTROL_EXISTS = 1 OR @CONTROL = 2 AND CONTROL_EXISTS = 0 OR @CONTROL = 3 AND CONTROL_FAIL = 1)
		ORDER BY ManagerName, ServiceName, ClientFullName

		SET @FAIL_CNT = (SELECT COUNT(*) FROM #inn WHERE FAIL_STR = 'Да')

		SELECT *
		FROM #inn
		ORDER BY ManagerName, ServiceName, ClientFullName

		IF OBJECT_ID('tempdb..#inn') IS NOT NULL
			DROP TABLE #inn

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_INNOVATION_FILTER] TO rl_filter_innovation;
GO