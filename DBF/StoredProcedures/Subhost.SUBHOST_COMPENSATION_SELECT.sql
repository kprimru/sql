USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_COMPENSATION_SELECT]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
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

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		SELECT
			SCP_ID, SCP_DISTR_STR, SST_CAPTION, a.SN_NAME, SCP_COMMENT,
			CASE
				WHEN DS_REG IS NULL THEN '������� �� ������� � ��'
				WHEN DS_REG = 1 THEN '������� ��������� � ��'
				WHEN b.SN_NAME <> a.SN_NAME THEN '�������� ��� ����. � �� - "' + b.SN_NAME + '"'
			END AS SCP_ERROR,
			CONVERT(MONEY, (
				SELECT PS_PRICE
				FROM
					dbo.PriceSystemTable
					INNER JOIN dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
					INNER JOIN dbo.PriceTypeSystemTable ON PTS_ID_PT = PT_ID
					INNER JOIN dbo.SystemTypeTable z ON z.SST_CAPTION = a.SST_CAPTION
					INNER JOIN dbo.SystemTypeTable y ON z.SST_ID_HOST = y.SST_ID
				WHERE PT_ID_GROUP IN (5, 7)
					AND PTS_ID_ST = y.SST_ID
					AND a.SYS_ID = PS_ID_SYSTEM
					AND PS_ID_PERIOD = @PR_ID
			) *
			(
				SELECT SN_COEF
				FROM
					(
						SELECT
							SN_NAME,
							CASE
								WHEN @PR_DATE >= '20140101' THEN
									CASE
										WHEN @SH_ID IN (12) THEN SNCC_VALUE
										ELSE SNCC_SUBHOST
									END
								ELSE SN_COEF
							END AS SN_COEF
						FROM
							dbo.SystemNetTable
							INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
						WHERE SNCC_ID_PERIOD = @PR_ID
					) z

				WHERE a.SN_NAME = z.SN_NAME
			)) AS SCP_SUM
		FROM
			Subhost.SubhostCompensationView a LEFT OUTER JOIN
			dbo.PeriodRegTable ON REG_ID_SYSTEM = SYS_ID
								AND REG_DISTR_NUM = SCP_DISTR
								AND REG_COMP_NUM = SCP_COMP
								AND REG_ID_PERIOD = @PR_ID LEFT OUTER JOIN
			dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS LEFT OUTER JOIN
			dbo.SystemNetCountTable ON REG_ID_NET = SNC_ID LEFT OUTER JOIN
			dbo.SystemNetTable b ON b.SN_ID = SNC_ID_SN
			--dbo.SystemNetTable b ON b.SN_ID = REG_ID_NET
		WHERE SCP_ID_SUBHOST = @SH_ID AND SCP_ID_PERIOD = @PR_ID
		ORDER BY SYS_ORDER, SCP_DISTR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_COMPENSATION_SELECT] TO rl_subhost_calc;
GO
