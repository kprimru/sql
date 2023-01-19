USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REPORT_CLIENT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REPORT_CLIENT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[REPORT_CLIENT_SELECT]
	@CL_ID	VARCHAR(MAX)
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
			CL_FULL_NAME, CL_ID,
			TO_NUM, TO_NAME, CL_INN,
			CT_NAME, ST_NAME + ',' + TA_HOME TO_ADDRESS,
			SYS_SHORT_NAME, RN_NET_COUNT, SST_CAPTION,
			CONVERT(VARCHAR(20), DIS_NUM) +
			CONVERT(VARCHAR(20),
				CASE DIS_COMP_NUM
					WHEN 1 THEN ''
					ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP_NUM)
				END
			) AS DIS_NUM,
			CASE RN_SERVICE
				WHEN 0 THEN 'Сопровождается'
				WHEN 1 THEN 'Не сопровождается'
				ELSE 'Неизвестно'
			END AS RN_STATUS
		FROM
			dbo.ClientTable INNER JOIN
			dbo.TOTable ON TO_ID_CLIENT = CL_ID INNER JOIN
			dbo.TOAddressTable ON TA_ID_TO = TO_ID INNER JOIN
			dbo.StreetTable ON ST_ID = TA_ID_STREET INNER JOIN
			dbo.CityTable ON CT_ID = ST_ID_CITY INNER JOIN
			dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR LEFT OUTER JOIN
			dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
						AND RN_DISTR_NUM = DIS_NUM
						AND RN_COMP_NUM = DIS_COMP_NUM LEFT OUTER JOIN
			dbo.SystemTypeTable ON SST_NAME = RN_DISTR_TYPE
		WHERE TO_ID_CLIENT IN
			(
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@CL_ID, ',')
			)
			AND SYS_ID_SO = 1
		ORDER BY CL_PSEDO, TO_NUM, SYS_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_CLIENT_SELECT] TO rl_client_w;
GO
