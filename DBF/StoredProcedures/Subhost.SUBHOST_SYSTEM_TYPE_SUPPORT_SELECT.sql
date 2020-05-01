USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_SYSTEM_TYPE_SUPPORT_SELECT]
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

		DECLARE @temp TABLE
			(
				SST_ID INT,
				SST_CAPTION VARCHAR(100),
				SST_COEF BIT,
				SST_KBU	BIT,
				SST_ORDER INT
			)

		INSERT INTO @temp
			SELECT SST_ID, SST_CAPTION, SST_COEF, SST_KBU, SST_PORDER
			FROM 
				dbo.SystemTypeTable a INNER JOIN
				(
					SELECT DISTINCT SST_ID_HOST
					FROM dbo.SystemTypeTable
					WHERE SST_ID_HOST IS NOT NULL
				) b ON a.SST_ID = b.SST_ID_HOST
			WHERE EXISTS
				(
					SELECT *
					FROM 
						dbo.PriceTypeSystemTable INNER JOIN
						dbo.PriceTypeTable ON PT_ID = PTS_ID_PT
					WHERE PT_ID_GROUP IN (5, 7) AND PTS_ID_ST = SST_ID
				)

		SELECT 
			SST_ID, SST_CAPTION, SST_COEF, SST_KBU, SST_ORDER,
			(
				SELECT COUNT(*)
				FROM @temp
				WHERE SST_COEF = 1
			) AS SST_COUNT
		FROM @temp
		ORDER BY SST_ORDER
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_SYSTEM_TYPE_SUPPORT_SELECT] TO rl_subhost_calc;
GO