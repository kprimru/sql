USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[WEIGHT_RULES_CHANGES_SELECT]
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
	
		SELECT	MIN(PR_DATE) AS [CHANGE_DATE],
				SYS_REG_NAME,
				SST_NAME,
				SNC_NET_COUNT, 
				SNC_TECH, 
				SNC_ODON, 
				SNC_ODOFF,
				WEIGHT,
				ROW_NUM-R AS DELTA
		FROM (
				SELECT
						PR_DATE,
						SYS_REG_NAME,
						SST_NAME,
						SNC_NET_COUNT, 
						SNC_TECH, 
						SNC_ODON, 
						SNC_ODOFF,
						W.WEIGHT,
						ROW_NUMBER() OVER(ORDER BY SYS_REG_NAME, SST_NAME, SNC_NET_COUNT, SNC_TECH, SNC_ODON, SNC_ODOFF, W.WEIGHT, PR_DATE) AS [ROW_NUM],
						RANK() OVER(PARTITION BY SYS_REG_NAME, SST_NAME, SNC_NET_COUNT, SNC_TECH, SNC_ODON, SNC_ODOFF, W.WEIGHT ORDER BY PR_DATE) AS [R]

				FROM	dbo.WeightRules							W
						INNER JOIN dbo.PeriodTable				P        ON W.ID_PERIOD = P.PR_ID
						INNER JOIN dbo.SystemTable				S        ON W.ID_SYSTEM = S.SYS_ID
						INNER JOIN dbo.SystemTypeTable          ST       ON W.ID_TYPE = ST.SST_ID
						INNER JOIN dbo.SystemNetCountTable      SN       ON W.ID_NET = SN.SNC_ID
			)T
		GROUP BY SYS_REG_NAME, SST_NAME, SNC_NET_COUNT, SNC_TECH, SNC_ODON, SNC_ODOFF, WEIGHT, ROW_NUM-R

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
