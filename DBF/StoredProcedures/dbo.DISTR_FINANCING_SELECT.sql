USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Описание:
*/
ALTER PROCEDURE [dbo].[DISTR_FINANCING_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

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
			DF_ID, DIS_STR, DIS_ID, SN_ID,
			SN_NAME, PP_ID, PP_NAME, DF_MON_COUNT,
			DF_FIXED_PRICE, DF_DISCOUNT, PR_DATE AS DF_FIRST_MON, DSS_NAME,
			C.CO_NUM, C.CO_END_DATE,
			T.COUR_NAME, DF_EXCHANGE, DF_END, DF_BEGIN,
			T.TO_NUM
		FROM dbo.DistrFinancingView a
		OUTER APPLY
		(
		    SELECT TOP 1 CO_END_DATE, CO_NUM
			FROM
				dbo.ContractTable INNER JOIN
				dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID
			WHERE CO_ID_CLIENT = @clientid
				AND COD_ID_DISTR = DIS_ID
				AND CO_ACTIVE = 1
			ORDER BY CO_END_DATE DESC
		) AS C
		OUTER APPLY
		(
		    SELECT COUR_NAME, TO_NUM
			FROM
				dbo.CourierTable INNER JOIN
				dbo.TOTable ON TO_ID_COUR = COUR_ID INNER JOIN
				dbo.TODistrTable ON TD_ID_TO = TO_ID
			WHERE TD_ID_DISTR = DIS_ID
		) AS T
		WHERE CD_ID_CLIENT = @clientid
				AND DIS_ACTIVE = 1
		ORDER BY DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_SELECT] TO rl_distr_financing_r;
GO