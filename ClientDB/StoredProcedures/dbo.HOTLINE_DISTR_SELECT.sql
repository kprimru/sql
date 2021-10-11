USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[HOTLINE_DISTR_SELECT]
	@NAME			NVARCHAR(128),
	@DISTR			INT,
	@SERVICE		INT,
	@MANAGER		INT,
	@TYPE			NVARCHAR(MAX),
	@HIDE_UNSERVICE	BIT,
	@TP				TINYINT,
	@CL_CNT			INT = NUL OUTPUT,
	@CMP_CNT		INT = NUL OUTPUT
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF @HIDE_UNSERVICE IS NULL
			SET @HIDE_UNSERVICE = 1

		IF OBJECT_ID('tempdb..#cl') IS NOT NULL
			DROP TABLE #cl

		CREATE TABLE #cl
			(
				ID			INT IDENTITY(1, 1) PRIMARY KEY,
				ID_PARENT	INT,
				ID_CLIENT	INT,
				NAME		NVARCHAR(256),
				SERVICE		NVARCHAR(128),
				ID_HOST		INT,
				DISTR		INT,
				COMP		TINYINT,
				DS_INDEX	INT,
				NT_SHORT	NVARCHAR(32),
				SST_SHORT	NVARCHAR(32),
				DT			NVARCHAR(256)
			)

		INSERT INTO #cl(ID_CLIENT, NAME, SERVICE, DS_INDEX)
			SELECT ClientID, ClientName, ServiceName, ServiceStatusIndex
			FROM
				(
					SELECT DISTINCT ClientID, ClientName, ServiceName + ISNULL(' (' + ManagerName + ')', '') AS ServiceName, ServiceStatusIndex, SystemOrder
					FROM dbo.RegNodeComplectClientView a
					WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
						AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
						AND (DistrNumber = @DISTR OR @DISTR IS NULL)
						AND (CLientName LIKE @NAME OR @NAME IS NULL)
						AND (@HIDE_UNSERVICE = 1 AND DS_REG = 0 OR @HIDE_UNSERVICE = 0 OR @TP = 2)
						AND
							(
								@TP = 1 AND NOT EXISTS
									(
										SELECT *
										FROM dbo.HotlineDistr b
										WHERE a.HostID = b.ID_HOST
											AND a.DistrNumber = b.DISTR
											AND a.CompNumber = b.COMP
											AND STATUS = 1
									)
								OR @TP = 2 AND EXISTS
									(
										SELECT *
										FROM dbo.HotlineDistr b
										WHERE a.HostID = b.ID_HOST
											AND a.DistrNumber = b.DISTR
											AND a.CompNumber = b.COMP
											AND STATUS = 1
									)
							)
				) AS a
			ORDER BY CASE WHEN ClientID IS NULL THEN 0 ELSE 1 END, ServiceName, ClientName, SystemOrder

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(NVARCHAR(64), NEWID()) + '] ON #cl (NAME, SERVICE, ID_CLIENT)'
		EXEC (@SQL)

		INSERT INTO #cl(ID_PARENT, ID_CLIENT, NAME, ID_HOST, DISTR, COMP, DS_INDEX, NT_SHORT, SST_SHORT, DT)
			SELECT
				(
					SELECT TOP 1 ID
					FROM #cl b
					WHERE ISNULL(a.ClientID, 0) = ISNULL(b.ID_CLIENT, 0)
						AND ISNULL(a.ClientName, '') = ISNULL(b.NAME, '')
						AND ISNULL(ServiceName + ISNULL(' (' + ManagerName + ')', ''), '') = ISNULL(b.SERVICE, '')
				),
				ClientID, DistrStr, HostID, DistrNumber, CompNumber, DS_INDEX, NT_SHORT, SST_SHORT,
				CASE @TP
					WHEN 1 THEN
							(
								SELECT TOP 1 CONVERT(NVARCHAR(64), UNSET_DATE, 120) + ' / ' + UNSET_USER
								FROM dbo.HotlineDistr b
								WHERE a.HostID = b.ID_HOST
									AND a.DistrNumber = b.DISTR
									AND a.CompNumber = b.COMP
								ORDER BY UNSET_DATE DESC
							)
					WHEN 2 THEN
							(
								SELECT TOP 1 CONVERT(NVARCHAR(64), SET_DATE, 120) + ' / ' + SET_USER
								FROM dbo.HotlineDistr b
								WHERE a.HostID = b.ID_HOST
									AND a.DistrNumber = b.DISTR
									AND a.CompNumber = b.COMP
								ORDER BY SET_DATE DESC
							)
				END

			FROM dbo.RegNodeComplectClientView a
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (DistrNumber = @DISTR OR @DISTR IS NULL)
				AND (CLientName LIKE @NAME OR @NAME IS NULL)
				AND NT_TECH IN (0, 1, 11)
				AND (SST_SHORT IN (SELECT ID FROM dbo.TableStringFromXML(@TYPE)) OR @TYPE IS NULL)
				AND (@HIDE_UNSERVICE = 1 AND DS_REG = 0 OR @HIDE_UNSERVICE = 0 OR @TP = 2)
				AND
					(
						@TP = 1 AND NOT EXISTS
							(
								SELECT *
								FROM dbo.HotlineDistr b
								WHERE a.HostID = b.ID_HOST
									AND a.DistrNumber = b.DISTR
									AND a.CompNumber = b.COMP
									AND STATUS = 1
							)
						OR @TP = 2 AND EXISTS
							(
								SELECT *
								FROM dbo.HotlineDistr b
								WHERE a.HostID = b.ID_HOST
									AND a.DistrNumber = b.DISTR
									AND a.CompNumber = b.COMP
									AND STATUS = 1
							)
					)
			ORDER BY SystemOrder, DistrNumber

		DELETE a
		FROM #cl a
		WHERE ID_PARENT IS NULL
			AND NOT EXISTS
				(
					SELECT *
					FROM #cl b
					WHERE a.ID = b.ID_PARENT
				)

		SET @CL_CNT = (SELECT COUNT(DISTINCT ID_CLIENT) FROM #cl)
		SET @CMP_CNT = (SELECT COUNT(*) FROM #cl WHERE ID_PARENT IS NOT NULL)

		SELECT *, CONVERT(BIT, 0) AS CHECKED
		FROM #cl
		ORDER BY ID

		IF OBJECT_ID('tempdb..#cl') IS NOT NULL
			DROP TABLE #cl

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[HOTLINE_DISTR_SELECT] TO rl_expert_distr;
GO
