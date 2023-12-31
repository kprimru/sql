USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[REG_NODE_SUBHOST_TOTAL]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT = NULL
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

		IF OBJECT_ID('tempdb..#delivery') IS NOT NULL
			DROP TABLE #delivery

		CREATE TABLE #delivery
			(
				ID				INT IDENTITY(1, 1),
				RNS_ID			INT,
				SH_SHORT_NAME	VARCHAR(50),
				PR_DATE			SMALLDATETIME,
				SYS_SHORT_NAME	VARCHAR(50),
				SST_CAPTION		VARCHAR(50),
				SN_NAME			VARCHAR(50),
				RNS_COMMENT		VARCHAR(100),
				DIS_STR			VARCHAR(50),
				OPER			VARCHAR(100),
				RNS_SUM			MONEY
			)

		INSERT INTO #delivery
			EXEC Subhost.REG_NODE_SUBHOST_SELECT @PR_ID, @SH_ID

		SELECT *,
			(
				SELECT SUM(RNS_SUM)
				FROM #delivery b
				WHERE a.SYS_SHORT_NAME = b.SYS_SHORT_NAME
					AND a.SST_CAPTION = b.SST_CAPTION
					AND a.SN_NAME = b.SN_NAME
			) AS SYS_SUM,
			(
				SELECT COUNT(*)
				FROM #delivery b
				WHERE a.SYS_SHORT_NAME = b.SYS_SHORT_NAME
					AND a.SST_CAPTION = b.SST_CAPTION
					AND a.SN_NAME = b.SN_NAME
			) AS SYS_COUNT
		FROM #delivery a
		ORDER BY ID

		IF OBJECT_ID('tempdb..#delivery') IS NOT NULL
			DROP TABLE #delivery

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[REG_NODE_SUBHOST_TOTAL] TO rl_subhost_calc;
GO
