USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[HOTLINE_FILTER]
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@CLIENT		NVARCHAR(256),
	@SERVICE	INT,
	@MANAGER	NVARCHAR(MAX),
	@TEXT		NVARCHAR(256),
	@PERSONAL	NVARCHAR(MAX) = NULL
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

		SELECT ServiceStatusIndex, ManagerName, ServiceName, ClientFullName, DistrStr,
			FIRST_DATE, CHAT,
			RIC_PERSONAL, FIRST_ANS,
			DATEDIFF(SECOND, FIRST_DATE, FIRST_ANS) AS REACTION,
			DATEDIFF(SECOND, START, FIRST_ANS) AS ANSWER_TIME,
			FIO, PROFILE
		FROM
			dbo.HotlineChatView a WITH(NOEXPAND)
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DISTR = b.DISTR AND a.COMP = b.COMP
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		WHERE (FIRST_DATE >= @START OR @START IS NULL)
			AND (FIRST_DATE < @FINISH OR @FINISH IS NULL)
			AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
			AND (CHAT LIKE @TEXT OR @TEXT IS NULL)
			AND (
					@PERSONAL IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM dbo.TableStringFromXML(@PERSONAL) z
							WHERE a.RIC_PERSONAL LIKE '%' + z.ID + '%'
						)
				)
		ORDER BY FIRST_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[HOTLINE_FILTER] TO rl_hotline_filter;
GO
