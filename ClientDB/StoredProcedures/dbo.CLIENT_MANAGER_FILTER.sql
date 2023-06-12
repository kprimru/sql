USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_MANAGER_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_MANAGER_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_MANAGER_FILTER]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SENDER	NVARCHAR(MAX),
	@NOTE	NVARCHAR(256),
	@STATUS	NVARCHAR(MAX),
	@TYPE	NVARCHAR(MAX) = NULL
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
			ClientID, ClientFullName, Cast(DATE + TIME AS DateTime) AS Date, SENDER, SHORT,
			CASE SHORT
				WHEN '' THEN ''
				ELSE SHORT + CHAR(10)
			END + NOTE AS NOTE,
			ServiceStatusIndex,
			'' AS TP_NAME,
			z.UPD_DATE, z.UPD_USER
		FROM Task.Tasks a
		INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
		INNER JOIN dbo.ClientTable c ON c.ClientID = a.ID_CLIENT
		INNER JOIN dbo.ServiceStatusTable d ON c.StatusID = d.ServiceStatusID
		OUTER APPLY
		(
			SELECT TOP (1) UPD_DATE, UPD_USER
			FROM
			(
				SELECT TOP 1 UPD_DATE, UPD_USER
				FROM Task.Tasks z
				WHERE z.ID_MASTER = a.ID
				ORDER BY UPD_DATE
    
				UNION ALL
    
				SELECT TOP 1 UPD_DATE, UPD_USER
				FROM Task.Tasks z
				WHERE z.ID = a.ID
				ORDER BY UPD_DATE
			) AS z
			ORDER BY UPD_DATE
		) AS z
		WHERE SENDER <> 'Автомат'
			AND a.STATUS = 1
			AND (a.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.DATE <= @END OR @END IS NULL)
			AND (a.SENDER IN (SELECT ID FROM dbo.TableStringFromXML(@SENDER)) OR @SENDER IS NULL)
			AND (a.NOTE LIKE @NOTE OR @NOTE IS NULL)
			AND (c.StatusID IN (SELECT ID FROM dbo.TableIDFromXML(@STATUS)) OR @STATUS IS NULL)

		UNION ALL

		SELECT
			ClientID, ClientFullName, DATE, PERSONAL AS SENDER, '' AS SHORT,
			NOTE,
			ServiceStatusIndex,
			b.NAME AS TP_NAME,
			z.UPD_DATE, z.UPD_USER
		FROM dbo.ClientContact a
		INNER JOIN dbo.ClientTable c ON c.ClientID = a.ID_CLIENT
		INNER JOIN dbo.ServiceStatusTable d ON c.StatusID = d.ServiceStatusID
		INNER JOIN dbo.ClientContactType b ON a.ID_TYPE = b.ID
		OUTER APPLY
		(
			SELECT TOP (1) UPD_DATE, UPD_USER
			FROM
			(
				SELECT TOP 1 UPD_DATE, UPD_USER
				FROM dbo.ClientContact z
				WHERE z.ID_MASTER = a.ID
				ORDER BY UPD_DATE
    
				UNION ALL
    
				SELECT TOP 1 UPD_DATE, UPD_USER
				FROM dbo.ClientContact z
				WHERE z.ID = a.ID
				ORDER BY UPD_DATE
			) AS z
			ORDER BY UPD_DATE
		) AS z
		WHERE a.STATUS = 1
			AND (a.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.DATE <= @END OR @END IS NULL)
			AND (a.PERSONAL IN (SELECT ID FROM dbo.TableStringFromXML(@SENDER)) OR @SENDER IS NULL)
			AND (a.NOTE LIKE @NOTE OR @NOTE IS NULL)
			AND (c.StatusID IN (SELECT ID FROM dbo.TableIDFromXML(@STATUS)) OR @STATUS IS NULL)
			AND (a.ID_TYPE IN (SELECT ID FROM dbo.TableGUIDFromXML(@TYPE)) OR @TYPE IS NULL)

		ORDER BY DATE DESC, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_MANAGER_FILTER] TO rl_manager_filter;
GRANT EXECUTE ON [dbo].[CLIENT_MANAGER_FILTER] TO rl_task_all;
GO
