USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[WEIGHT_LOAD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[WEIGHT_LOAD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[WEIGHT_LOAD]
WITH EXECUTE AS OWNER
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
			SystemID,
			SST_ID,
			NT_ID,
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
			FROM DBF.dbo.WeightRules					W
			INNER JOIN DBF.dbo.PeriodTable			P	ON W.ID_PERIOD = P.PR_ID
			INNER JOIN DBF.dbo.SystemTable			S	ON W.ID_SYSTEM = S.SYS_ID
			INNER JOIN DBF.dbo.SystemTypeTable		ST	ON W.ID_TYPE = ST.SST_ID
			INNER JOIN DBF.dbo.SystemNetCountTable	SN	ON W.ID_NET = SN.SNC_ID
		) AS W
		INNER JOIN dbo.SystemTable AS S ON S.SystemBaseName = W.SYS_REG_NAME
		INNER JOIN Din.SystemType AS T ON T.SST_REG = W.SST_NAME
		INNER JOIN Din.NetType AS N ON N.NT_NET = W.SNC_NET_COUNT AND N.NT_TECH = W.SNC_TECH AND N.NT_ODON = W.SNC_ODON AND N.NT_ODOFF = W.SNC_ODOFF
		WHERE RN = 1;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
