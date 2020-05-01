USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Reg].[REG_NODE_SEARCH1]
	@SYS		NVARCHAR(MAX)	=	NULL,
	@DISTR		INT				=	NULL,
	@TYPE		NVARCHAR(MAX)	=	NULL,
	@NET		NVARCHAR(MAX)	=	NULL,
	@SH			NVARCHAR(MAX)	=	NULL,
	@COMMENT	NVARCHAR(150)	=	NULL,
	@STATUS		NVARCHAR(MAX)	=	NULL,
	@BEGIN		SMALLDATETIME	=	NULL,
	@END		SMALLDATETIME	=	NULL,
	@COMPLECT	NVARCHAR(150)	=	NULL,
	@CNT		BIT				=	NULL,
	@RC			INT				=	NULL	OUTPUT
WITH RECOMPILE
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

		/*
		IF @SYS IS NULL
			SET @SYS =
				(
					SELECT SystemID AS 'ITEM'
					FROM dbo.SystemTable
					FOR XML PATH(''), ROOT('LIST')
				)

		IF @TYPE IS NULL
			SET @TYPE =
				(
					SELECT SST_ID AS 'ITEM'
					FROM Din.SystemType
					FOR XML PATH(''), ROOT('LIST')
				)

		IF @NET IS NULL
			SET @NET =
				(
					SELECT NT_ID AS 'ITEM'
					FROM Din.NetType
					FOR XML PATH(''), ROOT('LIST')
				)

		IF @STATUS IS NULL
			SET @STATUS =
				(
					SELECT DS_ID AS 'ITEM'
					FROM dbo.DistrStatus
					FOR XML PATH(''), ROOT('LIST')
				)

		IF @SH IS NULL
			SET @SH =
				(
					SELECT DISTINCT SubhostName AS 'ITEM'
					FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
					FOR XML PATH(''), ROOT('LIST')
				)
		*/

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
			(
				HST		INT,
				DISTR	INT,
				COMP	INT
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(NVARCHAR(128), NEWID()) + '] ON #temp(DISTR, HST, COMP)'
		EXEC (@SQL)

		IF @DISTR IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE DistrNumber = @DISTR
		ELSE IF @COMMENT IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE Comment LIKE @COMMENT
		ELSE IF @BEGIN IS NOT NULL OR @END IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE (RegisterDate >= @BEGIN OR @BEGIN IS NULL)
					AND (RegisterDate <= @END OR @END IS NULL)
		ELSE IF @SYS IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.TableIDFromXML(@SYS) b ON a.SystemID = b.ID
		ELSE IF @TYPE IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.TableIDFromXML(@TYPE) d ON a.SST_ID = d.ID
		ELSE IF @NET IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.TableIDFromXML(@NET) c ON a.NT_ID = c.ID
		ELSE IF @SH IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.TableStringFromXML(@SH) e ON a.SubhostName = e.ID
		ELSE IF @STATUS IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.TableGUIDFromXML(@STATUS) f ON a.DS_ID = f.ID
		ELSE IF @COMPLECT IS NOT NULL
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE Complect LIKE @COMPLECT
		ELSE IF @CNT = 1
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
				WHERE TransferLeft = 0
		ELSE
			INSERT INTO #temp(HST, DISTR, COMP)
				SELECT HostID, DistrNumber, CompNumber
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)

		IF @DISTR IS NOT NULL
			DELETE
			FROM #temp
			WHERE DISTR <> @DISTR

		IF @COMMENT IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
						AND Comment LIKE @COMMENT
				)

		IF @BEGIN IS NOT NULL OR @END IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
						AND (RegisterDate >= @BEGIN OR @BEGIN IS NULL)
						AND (RegisterDate <= @END OR @END IS NULL)
				)

		IF @SYS IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						Reg.RegNodeSearchView a WITH(NOEXPAND)
						INNER JOIN dbo.TableIDFromXML(@SYS) b ON a.SystemID = b.ID
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
				)

		IF @TYPE IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						Reg.RegNodeSearchView a WITH(NOEXPAND)
						INNER JOIN dbo.TableIDFromXML(@TYPE) d ON a.SST_ID = d.ID
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
				)

		IF @NET IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						Reg.RegNodeSearchView a WITH(NOEXPAND)
						INNER JOIN dbo.TableIDFromXML(@NET) d ON a.NT_ID = d.ID
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
				)

		IF @SH IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						Reg.RegNodeSearchView a WITH(NOEXPAND)
						INNER JOIN dbo.TableStringFromXML(@SH) e ON a.SubhostName = e.ID
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
				)

		IF @STATUS IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						Reg.RegNodeSearchView a WITH(NOEXPAND)
						INNER JOIN dbo.TableGUIDFromXML(@STATUS) f ON a.DS_ID = f.ID
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
				)

		IF @COMPLECT IS NOT NULL
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						Reg.RegNodeSearchView a WITH(NOEXPAND)
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
						AND Complect LIKE @COMPLECT
				)

		IF @CNT = 1
			DELETE
			FROM #temp
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						Reg.RegNodeSearchView a WITH(NOEXPAND)
					WHERE HST = HostID
						AND DISTR = DistrNumber
						AND COMP = CompNumber
						AND TransferLeft = 0
				)

		SELECT
			a.DistrStr, a.SST_SHORT, a.NT_ID, TransferCount, TransferLeft,
			a.Comment, Complect, RegisterDate, a.DS_INDEX, SubhostName,
			a.HostID, a.SystemID, DistrNumber, CompNumber,
			SH_ID, SH_NAME, ISNULL(SC_REG, 0) AS SC_REG, ISNULL(SC_USR, 0) AS SC_USR,
			CONVERT(BIT, CASE WHEN a.DS_REG = 0 AND t.ID IS NOT NULL THEN 1 ELSE 0 END) AS BLACK,
			/*
			k.SET_DATE AS BLACK_DATE, k.SET_USER AS BLACK_USER, k.SET_REASON AS BLACK_REASON,
			l.SET_DATE AS WHITE_DATE, l.SET_USER AS WHITE_USER, l.SET_REASON AS WHITE_REASON,
			*/
			NULL AS BLACK_DATE, NULL AS BLACK_USER, NULL AS BLACK_REASON,
			NULL AS WHITE_DATE, NULL AS WHITE_USER, NULL AS WHITE_REASON,
			ServiceName, ManagerName,
			Weight =
				(
					SELECT TOP (1) WEIGHT
					FROM dbo.WeightView W WITH(NOEXPAND)
					WHERE W.SystemID = a.SystemID
						AND W.SST_ID = a.SST_ID
						AND W.NT_ID = a.NT_ID
					ORDER BY W.Date DESC
				)
		FROM
			#temp z
			INNER JOIN Reg.RegNodeSearchView a WITH(NOEXPAND) ON z.HST = a.HostID AND z.DISTR = a.DistrNumber AND z.COMP = a.CompNumber
			/*
			INNER JOIN dbo.TableIDFromXML(@SYS) b ON a.SystemID = b.ID
			INNER JOIN dbo.TableIDFromXML(@NET) c ON a.NT_ID = c.ID
			INNER JOIN dbo.TableIDFromXML(@TYPE) d ON a.SST_ID = d.ID
			INNER JOIN dbo.TableStringFromXML(@SH) e ON a.SubhostName = e.ID
			INNER JOIN dbo.TableGUIDFromXML(@STATUS) f ON a.DS_ID = f.ID
			*/
			LEFT OUTER JOIN dbo.SubhostComplect ON SC_ID_HOST = HostID
												AND SC_DISTR = DistrNumber
												AND SC_COMP = CompNumber
			LEFT OUTER JOIN dbo.Subhost ON SH_ID = SC_ID_SUBHOST
			LEFT OUTER JOIN dbo.BLACK_LIST_REG t ON t.DISTR = z.DISTR AND z.COMP = t.COMP AND t.ID_SYS = a.SystemID AND P_DELETE = 0
			--LEFT OUTER JOIN IP.Lists k ON k.ID_HOST = a.HostID AND k.DISTR = a.DistrNumber AND k.COMP = a.CompNumber AND k.UNSET_DATE IS NULL AND k.TP = 1
			--LEFT OUTER JOIN IP.Lists l ON l.ID_HOST = a.HostID AND l.DISTR = a.DistrNumber AND l.COMP = a.CompNumber AND l.UNSET_DATE IS NULL AND l.TP = 2
			LEFT OUTER JOIN dbo.ClientDistrView m WITH(NOEXPAND) ON m.HostID = a.HostID AND m.DISTR = a.DistrNumber AND m.COMP = a.CompNumber
			LEFT OUTER JOIN dbo.ClientView n WITH(NOEXPAND) ON n.ClientID = m.ID_CLIENT
		WHERE (DistrNumber = @DISTR OR @DISTR IS NULL)
			AND (a.Comment LIKE @COMMENT OR @COMMENT IS NULL)
			AND (RegisterDate >= @BEGIN OR @BEGIN IS NULL)
			AND (RegisterDate <= @END OR @END IS NULL)
		ORDER BY a.SystemOrder, DistrNumber, CompNumber

		SELECT @RC = @@ROWCOUNT

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Reg].[REG_NODE_SEARCH1] TO rl_reg_node_search;
GO