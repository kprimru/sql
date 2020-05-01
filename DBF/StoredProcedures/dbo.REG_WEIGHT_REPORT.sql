USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REG_WEIGHT_REPORT]
	@PR_ID	SMALLINT,
	@DETAIL	BIT
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

		IF OBJECT_ID('tempdb..#restore') IS NOT NULL
			DROP TABLE #restore

		CREATE TABLE #restore
			(
				HST_ID	SMALLINT,
				SYS_ID	SMALLINT,
				DIS_NUM	INT,
				DIS_COMP	TINYINT,
				SST_ID	SMALLINT,
				SH_ID	SMALLINT,
				SNC_ID	SMALLINT,
				CNT		INT
			)

		INSERT INTO #restore
			SELECT *
			FROM dbo.REG_WEIGHT_REPORT_SELECT(@PR_ID)		

		IF OBJECT_ID('tempdb..#calc') IS NOT NULL
			DROP TABLE #calc

		CREATE TABLE #calc
			(
				ID			INT IDENTITY(1, 1) PRIMARY KEY,
				ID_MASTER	INT,
				SYS_ID		SMALLINT,		
				SYS_SHORT	VARCHAR(50),
				SST_ID		SMALLINT,
				SST_CAPTION	VARCHAR(50),
				SN_ID		SMALLINT,
				NET			VARCHAR(20),			
				SH_SUBHOST	BIT,
				SH_COEF		DECIMAL(4, 2),		
				SST_COEF	DECIMAL(4, 2),
				NET_COEF	DECIMAL(4, 2),
				SYS_COUNT	SMALLINT,
				SYS_RESTORE	SMALLINT,
				WEIGHT		DECIMAL(12, 8)
			)

		INSERT INTO #calc(SYS_ID, SYS_SHORT)
			SELECT SYS_ID, SYS_SHORT_NAME
			FROM dbo.SystemTable
			WHERE
				EXISTS
				(
					SELECT *
					FROM 
						dbo.PeriodRegExceptView
						INNER JOIN dbo.DistrStatusTable ON REG_ID_STATUS = DS_ID
					WHERE REG_ID_SYSTEM = SYS_ID
						AND REG_ID_PERIOD = @PR_ID 
						AND DS_REG = 0
				) OR EXISTS
				(
					SELECT *
					FROM #restore
					WHERE SystemTable.SYS_ID = #restore.SYS_ID
				)
			ORDER BY SYS_ORDER		
				
		INSERT INTO #calc
			(
				ID_MASTER,
				SYS_ID, SYS_SHORT,
				SST_ID,	SST_CAPTION, SN_ID, NET, 
				SH_SUBHOST,
				SH_COEF, 
				SST_COEF, NET_COEF,
				SYS_COUNT, SYS_RESTORE,
				WEIGHT
			)
			SELECT 
				ID, SYS_ID, SYS_SHORT_NAME, SST_ID, SST_CAPTION,
				SN_ID, SN_NAME, SH_SUBHOST,
				SH_CALC, SYS_SST_CALC, SN_TT_CALC,
				SUM(SYS_CNT),
				SUM(RES_CNT), NULL
			FROM
				(
					SELECT 
						(SELECT ID FROM #calc WHERE #calc.SYS_ID = a.SYS_ID) AS ID,
						SYS_ID, SYS_SHORT_NAME, SST_CAPTION, 
						SN_NAME, 
						SH_SUBHOST,
						SC_VALUE AS SH_CALC, SYS_CALC * STC_VALUE AS SYS_SST_CALC, SNCC_VALUE AS SN_TT_CALC,
						COUNT(*) AS SYS_CNT, 
						0 AS RES_CNT,					
						SYS_ORDER, SNCC_VALUE AS SN_CALC,
						SST_ID, SH_ID, SN_ID
					FROM 
						dbo.SystemTable a
						INNER JOIN dbo.PeriodRegExceptView b ON REG_ID_SYSTEM = SYS_ID
						INNER JOIN 
							(
								SELECT SST_ID, SST_CAPTION, STC_VALUE
								FROM 
									dbo.SystemTypeTable 
									INNER JOIN dbo.SystemTypeCoef ON STC_ID_TYPE = SST_ID
								WHERE STC_ID_PERIOD = @PR_ID
							) AS t ON SST_ID = REG_ID_TYPE
						INNER JOIN 
							(
								SELECT SNC_ID, SN_ID, SN_NAME, SNCC_VALUE
								FROM
									dbo.SystemNetCountTable 
									INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PR_ID
							) AS g ON SNC_ID = REG_ID_NET					
						INNER JOIN
							(
								SELECT SH_ID, SH_SUBHOST, SH_SHORT_NAME, SC_VALUE
								FROM
									dbo.SubhostTable 
									INNER JOIN dbo.SubhostCoef ON SC_ID_SUBHOST = SH_ID
								WHERE SC_ID_PERIOD = @PR_ID
							) AS x ON SH_ID = REG_ID_HOST					
						INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS			
					WHERE REG_ID_PERIOD = @PR_ID AND DS_REG = 0
					GROUP BY SYS_ID, SYS_SHORT_NAME, SST_CAPTION, SH_SUBHOST, SC_VALUE, SYS_CALC, STC_VALUE, SNCC_VALUE, SN_NAME, SYS_ORDER, REG_ID_TYPE, SN_ID, REG_ID_HOST, SH_ID, SST_ID
			
					UNION

					SELECT 
						(SELECT ID FROM #calc WHERE #calc.SYS_ID = a.SYS_ID) AS ID,
						a.SYS_ID, SYS_SHORT_NAME, SST_CAPTION, 
						SN_NAME, 
						SH_SUBHOST,
						SC_VALUE AS SH_CALC, SYS_CALC * STC_VALUE, SNCC_VALUE,
						0, 
						COUNT(*),
						SYS_ORDER, SNCC_VALUE AS SN_CALC, 
						a.SST_ID, a.SH_ID, d.SN_ID
					FROM 
						#restore a
						INNER JOIN dbo.SystemTable b ON b.SYS_ID = a.SYS_ID
						INNER JOIN 
							(
								SELECT SST_ID, SST_CAPTION, STC_VALUE
								FROM 
									dbo.SystemTypeTable 
									INNER JOIN dbo.SystemTypeCoef ON STC_ID_TYPE = SST_ID
								WHERE STC_ID_PERIOD = @PR_ID
							) AS c ON c.SST_ID = a.SST_ID
						INNER JOIN 
							(
								SELECT SNC_ID, SN_ID, SN_NAME, SNCC_VALUE
								FROM
									dbo.SystemNetCountTable 
									INNER JOIN dbo.SystemNetTable ON SNC_ID_SN = SN_ID
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PR_ID
							) AS d ON d.SNC_ID = a.SNC_ID										
						INNER JOIN 
							(
								SELECT SH_ID, SH_SUBHOST, SH_SHORT_NAME, SC_VALUE
								FROM
									dbo.SubhostTable
									INNER JOIN dbo.SubhostCoef ON SC_ID_SUBHOST = SH_ID
								WHERE SC_ID_PERIOD = @PR_ID
							) AS g ON g.SH_ID = a.SH_ID
					GROUP BY a.SYS_ID, SYS_SHORT_NAME, SST_CAPTION, SH_SUBHOST, SC_VALUE, SYS_CALC, STC_VALUE, SNCC_VALUE, SN_NAME, SYS_ORDER, a.SST_ID, d.SN_ID, a.SH_ID 
				) AS o_O
			GROUP BY ID, SYS_ID, SYS_SHORT_NAME, SST_ID, SST_CAPTION,
				SN_ID, SN_NAME, SH_CALC, SYS_SST_CALC, SN_TT_CALC, SYS_ORDER, 
				SH_SUBHOST, SN_CALC
			ORDER BY SYS_ORDER, SST_CAPTION, SH_SUBHOST, SN_CALC

		UPDATE #calc
		SET WEIGHT = ROUND((SYS_COUNT + ISNULL(SYS_RESTORE, 0)) * NET_COEF * SH_COEF * SST_COEF, 4)
		WHERE ID_MASTER IS NOT NULL

		UPDATE #calc
		SET WEIGHT = (SELECT SUM(WEIGHT) FROM #calc a WHERE #calc.ID = a.ID_MASTER),
			SYS_COUNT = (SELECT SUM(SYS_COUNT) FROM #calc a WHERE #calc.ID = a.ID_MASTER),
			SYS_RESTORE = (SELECT SUM(SYS_RESTORE) FROM #calc a WHERE #calc.ID = a.ID_MASTER)
		WHERE ID_MASTER IS NULL
			
		IF @DETAIL = 1
			SELECT 
				ID, ID_MASTER, SYS_ID, SYS_SHORT, SST_CAPTION, NET, 
				CASE 
					WHEN ID_MASTER IS NULL THEN NULL
					ELSE
						CASE SH_SUBHOST
							WHEN 1 THEN 'на подхосте'
							WHEN 0 THEN 'на хосте'
							ELSE '???'
						END
				END AS SH_SUBHOST, SH_COEF,
				SST_COEF, NET_COEF, SYS_COUNT, SYS_RESTORE, WEIGHT,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							SYS_SHORT + ' ' + CONVERT(VARCHAR(20), DIS_NUM) + 
							CASE DIS_COMP
								WHEN 1 THEN ''
								ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP)
							END + ', '
						FROM 
							#restore b 
							INNER JOIN dbo.SystemNetCountTable c ON b.SNC_ID = c.SNC_ID
							INNER JOIN dbo.SubhostTable d ON d.SH_ID = b.SH_ID
						WHERE a.SYS_ID = b.SYS_ID
							AND a.SST_ID = b.SST_ID
							AND a.SN_ID = c.SNC_ID_SN
							AND a.SH_SUBHOST = d.SH_SUBHOST
						ORDER BY DIS_NUM, DIS_COMP FOR XML PATH('')
					)
				), 1, 2, '')) AS RES_LIST
			FROM #calc a
			ORDER BY ID
		ELSE
			SELECT 
				SYS_SHORT, SYS_COUNT, SYS_RESTORE, WEIGHT,
				REVERSE(STUFF(REVERSE(
					(
						SELECT 
							SYS_SHORT + ' ' + CONVERT(VARCHAR(20), DIS_NUM) + 
							CASE DIS_COMP
								WHEN 1 THEN ''
								ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP)
							END + ', '
						FROM #restore b
						WHERE a.SYS_ID = b.SYS_ID
						ORDER BY DIS_NUM, DIS_COMP FOR XML PATH('')
					)
				), 1, 2, '')) AS RES_LIST
			FROM #calc a
			WHERE ID_MASTER IS NULL
			ORDER BY ID
			
		IF OBJECT_ID('tempdb..#calc') IS NOT NULL
			DROP TABLE #calc

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr


		IF OBJECT_ID('tempdb..#restore') IS NOT NULL
			DROP TABLE #restore
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[REG_WEIGHT_REPORT] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REG_WEIGHT_REPORT] TO rl_reg_report_r;
GO