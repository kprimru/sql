USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_DETAIL_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_DETAIL_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[TO_DETAIL_PRINT]
	@TO_ID	INT
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
			SYS_SHORT_NAME, SST_CAPTION,
			SN_NAME,
			CASE DIS_COMP_NUM
				WHEN 1 THEN CONVERT(VARCHAR(20), DIS_NUM)
				ELSE CONVERT(VARCHAR(20), DIS_NUM) + '/' + CONVERT(VARCHAR(20), DIS_COMP_NUM)
			END AS DIS_STR,
			DS_NAME
		FROM
			dbo.TODistrTable a
			INNER JOIN	dbo.DistrView b WITH(NOEXPAND) ON a.TD_ID_DISTR = b.DIS_ID
			LEFT OUTER JOIN	dbo.RegNodeTable c ON
								c.RN_SYS_NAME = b.SYS_REG_NAME
							AND	c.RN_DISTR_NUM = b.DIS_NUM
							AND c.RN_COMP_NUM = b.DIS_COMP_NUM
			LEFT OUTER JOIN	dbo.SystemNetCountTable ON SNC_NET_COUNT = RN_NET_COUNT  AND SNC_TECH = RN_TECH_TYPE AND SNC_ODON = RN_ODON AND SNC_ODOFF = RN_ODOFF
			LEFT OUTER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
			LEFT OUTER JOIN dbo.SystemTypeTable ON SST_NAME = RN_DISTR_TYPE
			LEFT OUTER JOIN dbo.DistrStatusTable ON DS_REG = RN_SERVICE
		WHERE TD_ID_TO = @TO_ID --AND RN_SERVICE = 0
		ORDER BY SYS_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TO_DETAIL_PRINT] TO rl_to_w;
GO
