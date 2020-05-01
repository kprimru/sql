USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_REG_SEARCH]
	@PR_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@DISTR	INT,
	@COMMENT	VARCHAR(50)
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
			REG_ID, 
			SYS_SHORT_NAME, REG_ID_SYSTEM, SYS_ORDER, 
			REG_DISTR_NUM, REG_COMP_NUM, 
			SST_NAME, REG_ID_TYPE, 
			DS_REG, DS_NAME, REG_ID_STATUS, 
			REG_DATE, REG_COMMENT, 
			SNC_NET_COUNT, REG_ID_NET, SNC_ID_SN,
			NULL AS TT_NAME, NULL AS REG_ID_TECH_TYPE, 
			REG_COMPLECT, CONVERT(BIT, 0) AS REG_SELECT
		FROM dbo.PeriodRegView
		WHERE REG_ID_PERIOD = @PR_ID AND
			(REG_ID_SYSTEM = @SYS_ID OR @SYS_ID IS NULL) AND
			(REG_DISTR_NUM = @DISTR OR @DISTR IS NULL) AND
			(REG_COMMENT LIKE @COMMENT OR @COMMENT IS NULL)
		ORDER BY SYS_ORDER, REG_DISTR_NUM
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_REG_SEARCH] TO rl_subhost_calc;
GO