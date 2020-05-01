USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_SYSTEM_SELECT]
	@SH_ID	SMALLINT = NULL,
	@PR_ID	SMALLINT = NULL,
	@HIDE	BIT = 0,
	@HIDE2	BIT = 0
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
	
		DECLARE @KBU DECIMAL(8, 4)

		SELECT @KBU = SHC_KBU
		FROM Subhost.SubhostCalc
		WHERE SHC_ID_SUBHOST = @SH_ID
			AND SHC_ID_PERIOD = @PR_ID

		DECLARE @SYST	TABLE(SYST_ID SMALLINT)
		
		
		IF @HIDE = 1
		BEGIN
			INSERT INTO @SYST(SYST_ID)
				SELECT DISTINCT RNS_ID_SYSTEM
				FROM Subhost.RegNodeSubhostTable
				WHERE RNS_ID_PERIOD = @PR_ID
					AND RNS_ID_HOST = @SH_ID
				
				UNION 
				
				SELECT DISTINCT DIU_ID_SYSTEM
				FROM Subhost.Diu
				WHERE DIU_ID_SUBHOST = @SH_ID
					AND DIU_ACTIVE = 1
				
				UNION 
				
				SELECT DISTINCT SCP_ID_SYSTEM
				FROM Subhost.SubhostCompensationTable
				WHERE SCP_ID_SUBHOST = @SH_ID
					AND SCP_ID_PERIOD = @PR_ID
					
				UNION 
				
				SELECT DISTINCT REG_ID_SYSTEM
				FROM 
					dbo.PeriodRegTable
					INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
				WHERE REG_ID_HOST = @SH_ID
					AND REG_ID_PERIOD = @PR_ID
					AND DS_REG = 0
		END
		ELSE IF @HIDE2 = 1
		BEGIN
			INSERT INTO @SYST(SYST_ID)			
				SELECT DISTINCT DIU_ID_SYSTEM
				FROM Subhost.Diu
				WHERE DIU_ID_SUBHOST = @SH_ID
					AND DIU_ACTIVE = 1
					
				UNION 
				
				SELECT DISTINCT SCP_ID_SYSTEM
				FROM Subhost.SubhostCompensationTable
				WHERE SCP_ID_SUBHOST = @SH_ID
					AND SCP_ID_PERIOD = @PR_ID
					
				UNION 
				
				SELECT DISTINCT REG_ID_SYSTEM
				FROM 
					dbo.PeriodRegTable
					INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
					INNER JOIN 
						(
							SELECT SST_ID
							FROM
								(
									SELECT SST_ID, SST_ID_HOST
									FROM dbo.SystemTypeTable
									WHERE NOT EXISTS
										(
											SELECT *
											FROM dbo.SystemTypeSubhost
											WHERE STS_ID_SUBHOST = @SH_ID
												AND STS_ID_TYPE = SST_ID
										)
										AND SST_NAME <> 'NCT'

									UNION ALL

									SELECT SST_ID, STS_ID_HOST
									FROM 
										dbo.SystemTypeTable
										INNER JOIN dbo.SystemTypeSubhost ON STS_ID_TYPE = SST_ID
									WHERE STS_ID_SUBHOST = @SH_ID
										AND SST_NAME <> 'NCT'
								) AS o_O
							WHERE SST_ID_HOST IS NOT NULL
						) AS z ON REG_ID_TYPE = SST_ID
				WHERE REG_ID_HOST = @SH_ID
					AND REG_ID_PERIOD = @PR_ID
					AND DS_REG = 0
		END
		ELSE
		BEGIN
			INSERT INTO @SYST(SYST_ID)
				SELECT SYS_ID
				FROM dbo.SystemTable
				WHERE SYS_ID_SO = 1
		END

		SELECT SYS_ID, SYS_SHORT_NAME, NULL AS SYS_OLD, NULL AS SYS_NEW, SYS_ORDER, @KBU AS SYS_KBU
		FROM 
			dbo.SystemTable
			INNER JOIN @SYST ON SYST_ID = SYS_ID
		WHERE SYS_ID_SO = 1
			AND NOT EXISTS
				(
					SELECT *
					FROM Subhost.SubhostKBUTable
					WHERE SK_ID_SYSTEM = SYS_ID
						AND SK_ID_HOST = @SH_ID
						AND SK_ID_PERIOD = @PR_ID
				)

		UNION ALL

		SELECT SYS_ID, SYS_SHORT_NAME, NULL AS SYS_OLD, NULL AS SYS_NEW, SYS_ORDER, SK_KBU AS SYS_KBU
		FROM 
			dbo.SystemTable INNER JOIN
			Subhost.SubhostKBUTable ON SK_ID_SYSTEM = SYS_ID
			INNER JOIN @SYST ON SYST_ID = SYS_ID
		WHERE SK_ID_HOST = @SH_ID AND SK_ID_PERIOD = @PR_ID

		UNION ALL

		SELECT 
			NULL AS SYS_ID, 
			'с ' + b.SYS_SHORT_NAME + ' на ' + c.SYS_SHORT_NAME, 
			b.SYS_SHORT_NAME AS SYS_OLD, c.SYS_SHORT_NAME AS SYS_NEW, 
			CASE
				WHEN b.SYS_ORDER > c.SYS_ORDER THEN b.SYS_ORDER + 1
				ELSE c.SYS_ORDER + 1
			END, NULL AS SYS_KBU
		FROM 
			/*(
				SELECT SYS_ID_HOST
				FROM dbo.SystemTable
				WHERE SYS_ID_HOST IS NOT NULL
				GROUP BY SYS_ID_HOST
				HAVING COUNT(*) > 1
			) a INNER JOIN*/
			dbo.SystemTable b /*ON a.SYS_ID_HOST = b.SYS_ID_HOST INNER JOIN*/
			CROSS JOIN dbo.SystemTable c /*ON a.SYS_ID_HOST = c.SYS_ID_HOST*/
		WHERE b.SYS_ID <> c.SYS_ID
			AND @HIDE2 = 0
			AND EXISTS
				(
					SELECT *
					FROM Subhost.RegNodeSubhostTable
					WHERE RNS_ID_PERIOD = @PR_ID
						AND RNS_ID_HOST = @SH_ID
						AND RNS_ID_OLD_SYS = b.SYS_ID
						AND RNS_ID_NEW_SYS = c.SYS_ID
				)

		ORDER BY SYS_ORDER, SYS_SHORT_NAME
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_SYSTEM_SELECT] TO rl_subhost_calc;
GO