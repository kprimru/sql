USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[WEIGHT_LOAD]
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

		DELETE FROM dbo.Weight;

		INSERT INTO dbo.Weight
		SELECT
			PR_DATE,
			SYS_REG_NAME,
			SST_NAME,
			SNC_NET_COUNT, SNC_TECH, SNC_ODON, SNC_ODOFF,
			W.WEIGHT
		FROM
		(
			SELECT
				PR_DATE,
				SYS_REG_NAME,
				SST_NAME,
				SNC_NET_COUNT, SNC_TECH, SNC_ODON, SNC_ODOFF,
				W.WEIGHT,
				RN = ROW_NUMBER() OVER(PARTITION BY SYS_REG_NAME, SST_NAME, SNC_NET_COUNT, SNC_TECH, SNC_ODON, SNC_ODOFF, WEIGHT ORDER BY PR_DATE)
			FROM [PC275-SQL\DELTA].DBF.dbo.WeightRules					W
			INNER JOIN [PC275-SQL\DELTA].DBF.dbo.PeriodTable			P	ON W.ID_PERIOD = P.PR_ID
			INNER JOIN [PC275-SQL\DELTA].DBF.dbo.SystemTable			S	ON W.ID_SYSTEM = S.SYS_ID
			INNER JOIN [PC275-SQL\DELTA].DBF.dbo.SystemTypeTable		ST	ON W.ID_TYPE = ST.SST_ID
			INNER JOIN [PC275-SQL\DELTA].DBF.dbo.SystemNetCountTable	SN	ON W.ID_NET = SN.SNC_ID
		) AS W
		WHERE RN = 1
		ORDER BY PR_DATE, SYS_REG_NAME, SST_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
