USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_SUPPORT_LIST_SELECT]
	@PERIOD	INT,
	@SUBHOST SMALLINT
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
	
		DECLARE @PR_DATE SMALLDATETIME
		
		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PERIOD
		
		IF OBJECT_ID('tempdb..#sup_list') IS NOT NULL
			DROP TABLE #sup_list

		CREATE TABLE #sup_list
			(
				SST_ID	INT,
				SYS_SHORT_NAME	VARCHAR(50),
				TITLE VARCHAR(50),
				SYS_COUNT	INT
			)

		IF OBJECT_ID('tempdb..#con_list') IS NOT NULL
			DROP TABLE #con_list

		CREATE TABLE #con_list
			(
				SST_ID	INT,
				SYS_SHORT_NAME	VARCHAR(50),
				TITLE VARCHAR(50),
				SYS_COUNT	INT
			)

		INSERT INTO #sup_list
			EXEC Subhost.SUBHOST_SUPPORT_SELECT @PERIOD, @SUBHOST

		INSERT INTO #con_list
			EXEC Subhost.SUBHOST_SUPPORT_CONNECT_SELECT @PERIOD, @SUBHOST

		SELECT KIND, SYS_SHORT_NAME, SST_CAPTION, TITLE, SYS_COUNT, PRICE, SYS_ORDER, SST_PORDER, SYS_COUNT * PRICE AS SUMMA
		FROM
			(
				SELECT 
					'Сопровождение' AS KIND, a.SYS_SHORT_NAME, SST_CAPTION, TITLE, SYS_COUNT, 
					CONVERT(MONEY, ROUND(PS_PRICE * CASE SST_COEF WHEN 1 THEN SN_COEF ELSE 1 END, 2)) AS PRICE, 
					SYS_ORDER, SST_PORDER
				FROM 
					#sup_list a
					INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
					INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = a.SYS_SHORT_NAME
					INNER JOIN dbo.PriceSystemTable d ON d.PS_ID_SYSTEM = c.SYS_ID
					INNER JOIN dbo.PriceTypeTable e ON PT_ID = PS_ID_TYPE
					INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID 
														AND PTS_ID_ST = a.SST_ID
					INNER JOIN 
							(
								SELECT 
									SN_NAME, 
									CASE 
										WHEN @PR_DATE >= '20140101' THEN 
											CASE 
												WHEN @SUBHOST IN (12) THEN SNCC_VALUE
												ELSE SNCC_SUBHOST
											END
										ELSE SN_COEF
									END AS SN_COEF
								FROM 
									dbo.SystemNetTable
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PERIOD							
							) AS o_O ON TITLE = SN_NAME
				WHERE PS_ID_PERIOD = @PERIOD
					AND PT_ID_GROUP IN (5, 7)
					AND NOT EXISTS
						(
							SELECT *
							FROM Subhost.SubhostPriceSystemTable
							WHERE SPS_ID_HOST = @SUBHOST
								AND SPS_ID_PERIOD = @PERIOD
								AND SPS_ID_SYSTEM = SYS_ID
								AND SPS_ID_TYPE = PT_ID
						)
						
				UNION ALL
				
				SELECT 
					'Сопровождение' AS KIND, a.SYS_SHORT_NAME, SST_CAPTION, TITLE, SYS_COUNT, 
					CONVERT(MONEY, SPS_PRICE * CASE SST_COEF WHEN 1 THEN SN_COEF ELSE 1 END) AS PRICE, 
					SYS_ORDER, SST_PORDER
				FROM 
					#sup_list a
					INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
					INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = a.SYS_SHORT_NAME
					INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_ST = a.SST_ID
					INNER JOIN dbo.PriceTypeTable ON PT_ID = PTS_ID_PT
					INNER JOIN Subhost.SubhostPriceSystemTable ON SPS_ID_HOST = @SUBHOST 
															AND SPS_ID_PERIOD = @PERIOD
															AND SPS_ID_SYSTEM = SYS_ID
															AND SPS_ID_TYPE = PTS_ID_PT
					INNER JOIN
							(
								SELECT 
									SN_NAME, 
									CASE 
										WHEN @PR_DATE >= '20140101' THEN 
											CASE 
												WHEN @SUBHOST IN (12) THEN SNCC_VALUE
												ELSE SNCC_SUBHOST
											END
										ELSE SN_COEF
									END AS SN_COEF
								FROM 
									dbo.SystemNetTable
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PERIOD

							) AS o_O ON TITLE = SN_NAME
				WHERE PT_ID_GROUP IN (5, 7)

				UNION ALL

				SELECT 
					'Подключено' AS KIND, a.SYS_SHORT_NAME, SST_CAPTION, TITLE, SYS_COUNT, 
					CONVERT(MONEY, PS_PRICE * CASE SST_COEF WHEN 1 THEN SN_COEF ELSE 1 END) AS PRICE, 
					SYS_ORDER, SST_PORDER
				FROM 
					#con_list a
					INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
					INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = a.SYS_SHORT_NAME
					INNER JOIN dbo.PriceSystemTable d ON d.PS_ID_SYSTEM = c.SYS_ID
					INNER JOIN dbo.PriceTypeTable e ON PT_ID = PS_ID_TYPE
					INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID 
													AND PTS_ID_ST = a.SST_ID
					INNER JOIN 
							(
								SELECT 
									SN_NAME, 
									CASE 
										WHEN @PR_DATE >= '20140101' THEN 
											CASE 
												WHEN @SUBHOST IN (12) THEN SNCC_VALUE
												ELSE SNCC_SUBHOST
											END
										ELSE SN_COEF
									END AS SN_COEF
								FROM 
									dbo.SystemNetTable
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PERIOD
							) AS o_O ON TITLE = SN_NAME
				WHERE PS_ID_PERIOD = @PERIOD
					AND PT_ID_GROUP IN (5, 7)
					AND NOT EXISTS
						(
							SELECT *
							FROM Subhost.SubhostPriceSystemTable
							WHERE SPS_ID_HOST = @SUBHOST
								AND SPS_ID_PERIOD = @PERIOD
								AND SPS_ID_SYSTEM = SYS_ID
								AND SPS_ID_TYPE = PT_ID
						)
				
				UNION ALL
				
				SELECT 
					'Подключено' AS KIND, a.SYS_SHORT_NAME, SST_CAPTION, TITLE, SYS_COUNT, 
					CONVERT(MONEY, SPS_PRICE * CASE SST_COEF WHEN 1 THEN SN_COEF ELSE 1 END) AS PRICE, 
					SYS_ORDER, SST_PORDER
				FROM 
					#con_list a
					INNER JOIN dbo.SystemTypeTable b ON a.SST_ID = b.SST_ID
					INNER JOIN dbo.SystemTable c ON c.SYS_SHORT_NAME = a.SYS_SHORT_NAME
					INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_ST = a.SST_ID
					INNER JOIN dbo.PriceTypeTable ON PT_ID = PTS_ID_PT
					INNER JOIN Subhost.SubhostPriceSystemTable ON SPS_ID_HOST = @SUBHOST 
															AND SPS_ID_PERIOD = @PERIOD
															AND SPS_ID_SYSTEM = SYS_ID
															AND SPS_ID_TYPE = PTS_ID_PT			
					INNER JOIN 
							(
								SELECT 
									SN_NAME, 
									CASE 
										WHEN @PR_DATE >= '20140101' THEN 
											CASE 
												WHEN @SUBHOST IN (12) THEN SNCC_VALUE
												ELSE SNCC_SUBHOST
											END
										ELSE SN_COEF
									END AS SN_COEF
								FROM 
									dbo.SystemNetTable
									INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
								WHERE SNCC_ID_PERIOD = @PERIOD
							) AS o_O ON TITLE = SN_NAME
				WHERE PT_ID_GROUP IN (5, 7)
			) AS o_O
		ORDER BY KIND, SST_PORDER, SYS_ORDER

		IF OBJECT_ID('tempdb..#sup_list') IS NOT NULL
			DROP TABLE #sup_list

		IF OBJECT_ID('tempdb..#con_list') IS NOT NULL
			DROP TABLE #con_list
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
