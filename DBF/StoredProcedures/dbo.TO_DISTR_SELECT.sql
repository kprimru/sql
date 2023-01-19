USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_DISTR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_DISTR_SELECT]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_DISTR_SELECT]
	@toid INT
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
			a.DIS_ID, a.DIS_STR, a.TD_ID, DS_NAME, SST_CAPTION, DSS_ID, DSS_NAME, TD_FORCED,
			SN_NAME
		FROM
			dbo.TODistrView a
			LEFT OUTER JOIN	dbo.RegNodeTable b ON SYS_REG_NAME = RN_SYS_NAME
						AND DIS_NUM = RN_DISTR_NUM
						AND DIS_COMP_NUM = RN_COMP_NUM
			LEFT OUTER JOIN	dbo.DistrStatusTable c ON DS_REG = RN_SERVICE
			LEFT OUTER JOIN	dbo.SystemTypeTable d ON SST_NAME = RN_DISTR_TYPE
			LEFT OUTER JOIN dbo.ClientDistrView e ON e.DIS_ID = a.DIS_ID
			LEFT OUTER JOIN
			dbo.SystemNetCountTable ON SNC_NET_COUNT = RN_NET_COUNT AND SNC_TECH = RN_TECH_TYPE AND SNC_ODON = RN_ODON AND SNC_ODOFF = RN_ODOFF LEFT OUTER JOIN
			dbo.SystemNetTable ON SNC_ID_SN = SN_ID
		WHERE TD_ID_TO = @toid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TO_DISTR_SELECT] TO rl_client_r;
GRANT EXECUTE ON [dbo].[TO_DISTR_SELECT] TO rl_to_distr_r;
GO
