USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[DISTR_FINANCING_DEFAULT_GET]
	@distrid INT
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

		IF (SELECT TOP 1 SYS_ID_SO FROM dbo.DistrView WITH(NOEXPAND) WHERE DIS_ID = @distrid) = 1
		BEGIN
			SELECT
				SN_NAME, SN_ID,
				SST_CAPTION, SST_ID,
				NULL AS TT_NAME, NULL AS TT_ID,
				PP_NAME, PP_ID,
				1 AS DF_COEF, 0 AS DF_DISCOUNT, 1 AS DF_MON_COUNT, 0 AS DF_FIXED_SUM,
				COP_ID, COP_NAME,
				/*(
					SELECT TOP 1 CO_END_DATE
					FROM
						dbo.ContractTable INNER JOIN
						dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID
					WHERE COD_ID_DISTR = DIS_ID
						AND CO_ACTIVE = 1
					ORDER BY CO_DATE DESC
				) AS DF_END*/
				CONVERT(SMALLDATETIME, NULL) AS DF_END
			FROM
				dbo.DistrView WITH(NOEXPAND) LEFT OUTER JOIN
				dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME AND
								RN_DISTR_NUM = DIS_NUM AND
								RN_COMP_NUM = DIS_COMP_NUM LEFT OUTER JOIN
				dbo.SystemTypeTable ON SST_NAME = RN_DISTR_TYPE LEFT OUTER JOIN
				dbo.SystemNetCountTable ON SNC_NET_COUNT = RN_NET_COUNT AND SNC_TECH = RN_TECH_TYPE AND SNC_ODON = RN_ODON AND SNC_ODOFF = RN_ODOFF LEFT OUTER JOIN
				dbo.SystemNetTable ON SN_ID = SNC_ID_SN,
				dbo.PriceTable			LEFT OUTER JOIN
				dbo.ContractPayTable ON COP_MONTH = 0 AND COP_DAY = 5
			WHERE DIS_ID = @distrid AND PP_ID = 1
		END
		ELSE
		BEGIN
			SELECT
				SN_NAME, SN_ID,
				SST_CAPTION, SST_ID,
				NULL AS TT_NAME, NULL AS TT_ID,
				PP_NAME, PP_ID,
				1 AS DF_COEF, 0 AS DF_DISCOUNT, 6 AS DF_MON_COUNT, 0 AS DF_FIXED_SUM, COP_ID, COP_NAME,
				CONVERT(SMALLDATETIME, NULL) AS DF_END
			FROM
				dbo.DistrView WITH(NOEXPAND),
				dbo.SystemTypeTable,
				dbo.SystemNetCountTable LEFT OUTER JOIN
				dbo.SystemNetTable ON SN_ID = SNC_ID_SN,
				dbo.PriceTable		LEFT OUTER JOIN
				dbo.ContractPayTable ON COP_MONTH = 0 AND COP_DAY = 5
			WHERE
				DIS_ID = @distrid AND
				PP_ID = 1 AND
				SN_ID = 1 AND
				SST_ID = 4
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_DEFAULT_GET] TO rl_distr_financing_r;
GO
