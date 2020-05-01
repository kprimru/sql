USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Control].[CONTROL_FILTER]
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@STATUS		SMALLINT,
	@GROUP		UNIQUEIDENTIFIER,
	@RECEIVER	NVARCHAR(128),
	@NSTART		SMALLDATETIME,
	@NFINISH	SMALLDATETIME,
	@TEXT		NVARCHAR(256),
	@AUTHOR		NVARCHAR(128) = NULL
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
			ClientID, ClientFullName, ManagerName, ServiceName, DATE, AUTHOR, NOTE, NOTIFY,
			ISNULL(c.NAME, a.RECEIVER) AS RECEIVER,
			REMOVE_USER + ' / ' + CONVERT(NVARCHAR(64), REMOVE_DATE, 104) + ' ' + CONVERT(NVARCHAR(64), REMOVE_DATE, 108) AS REMOVE_DATA,
			REMOVE_NOTE
		FROM
			Control.ClientControl a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
			LEFT OUTER JOIN Control.ControlGroup c ON a.ID_GROUP = c.ID
		WHERE (a.DATE >= @START OR @START IS NULL)
			AND (a.DATE < @FINISH OR @FINISH IS NULL)
			AND (b.ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (b.ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (a.ID_GROUP = @GROUP OR @GROUP IS NULL)
			AND (a.RECEIVER = @RECEIVER OR @RECEIVER IS NULL)
			AND (@STATUS IS NULL OR @STATUS = 0 OR @STATUS = 1 AND REMOVE_DATE IS NULL OR @STATUS = 2 AND REMOVE_DATE IS NOT NULL)
			AND (a.NOTIFY >= @NSTART OR @NSTART IS NULL)
			AND (a.NOTIFY <= @NFINISH OR @NFINISH IS NULL)
			AND (a.NOTE LIKE @TEXT OR @TEXT IS NULL)
			AND (a.AUTHOR LIKE @AUTHOR OR @AUTHOR IS NULL)
		ORDER BY a.DATE DESC, ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Control].[CONTROL_FILTER] TO rl_control_r;
GO