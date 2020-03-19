USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[IP_JOURNAL_SELECT]
	@SUBHOST	NVARCHAR(16),
	@DISTR		INT,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@UNCOMPLETE	BIT,
	@CLIENT		NVARCHAR(256) = NULL
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
		IF @CLIENT = ''
			SET @CLIENT = NULL
		ELSE
			SET @CLIENT = '%' + @CLIENT + '%'

		-- ToDo ����� ������ ����...
		SELECT 
			TP, DS_INDEX,
			c.Comment, c.DistrStr,
			CSD_DATE, CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_LOG_FULL, CSD_USR, CSD_USR_FULL,
			CLIENT_CODE, SERVER_CODE, STT_SEND, CLIENT_CODE_ERROR, SERVER_CODE_ERROR
		FROM 
			(
				SELECT 
					0 AS TP, CSD_SYS, CSD_DISTR, CSD_COMP,
					CSD_DATE, CSD_DOWNLOAD_TIME, CSD_UPDATE_TIME, CSD_LOG_FULL, CSD_USR, CSD_USR_FULL,
					CLIENT_CODE, SERVER_CODE, STT_SEND, CLIENT_CODE_ERROR, SERVER_CODE_ERROR
				FROM IP.ClientStatDetailView a
				WHERE (a.CSD_DISTR = @DISTR OR @DISTR IS NULL)
					AND (a.CSD_DATE >= @START OR @START IS NULL)
					AND (a.CSD_DATE < @FINISH OR @FINISH IS NULL)
					--AND (a.CSD_DATE >= DATEADD(MONTH, -3, GETDATE()))
				
				UNION ALL
				
				SELECT 
					1 AS TP, LF_SYS, LF_DISTR, LF_COMP,
					LF_DATE, NULL, NULL, FL_NAME, NULL, NULL,
					NULL, NULL, NULL, NULL, NULL
				FROM 
					IP.LogFileView a
					--[PC275-SQL\OMEGA].IPLogs.dbo.LogFiles a
					--INNER JOIN [PC275-SQL\OMEGA].IPLogs.dbo.Files b ON a.LF_ID_FILE = b.FL_ID
				WHERE LF_DATE >= DATEADD(HOUR, -12, GETDATE())
					AND @UNCOMPLETE = 1
					AND (a.LF_DISTR = @DISTR OR @DISTR IS NULL)
					AND (a.LF_DATE >= @START OR @START IS NULL)
					AND (a.LF_DATE < @FINISH OR @FINISH IS NULL)
					--AND (a.LF_DATE >= DATEADD(MONTH, -3, GETDATE()))
					AND NOT EXISTS
						(
							SELECT *
							FROM IP.ClientStatView
							WHERE CSD_DISTR = LF_DISTR
								AND CSD_COMP = LF_COMP
								AND CSD_SYS = LF_SYS
								AND DATEADD(MILLISECOND, -DATEPART(MILLISECOND, CSD_DATE), CSD_DATE) = LF_DATE
						)
			) AS a
			INNER JOIN dbo.SystemTable b ON a.CSD_SYS = b.SystemNumber AND b.SystemRic = 20
			INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.CSD_DISTR AND c.CompNumber = a.CSD_COMP
		WHERE (
					c.SubhostName = @SUBHOST
					OR
					c.Complect IN
						(
							SELECT Complect
							FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
							INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = a.HostID
							INNER JOIN dbo.Subhost d ON SC_ID_SUBHOST = SH_ID
							WHERE SystemReg = 1 AND SC_REG = 1 AND SH_REG = @SUBHOST
						)
					
			)
			AND (c.Comment LIKE @CLIENT OR @CLIENT IS NULL)
			/*
			AND (a.CSD_DISTR = @DISTR OR @DISTR IS NULL)
			AND (a.CSD_DATE >= @START OR @START IS NULL)
			AND (a.CSD_DATE < @FINISH OR @FINISH IS NULL)
			AND (a.CSD_DATE >= DATEADD(MONTH, -3, GETDATE()))
			*/
		ORDER BY CSD_DATE DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
