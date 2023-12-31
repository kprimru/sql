USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[PRIMARY_PAY_DEFAULT_GET]
	@distrid INT,
	@periodid SMALLINT
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
			TX_ID, TX_CAPTION, ORG_ID, ORG_PSEDO,
			CAST(((PS_PRICE + PP_COEF_ADD)
											* PP_COEF_MUL * SN_COEF * (100 - DF_DISCOUNT) / 100) AS MONEY) AS PRP_PRICE
		FROM
			dbo.TaxTable,
			dbo.DistrView a WITH(NOEXPAND) INNER JOIN
			dbo.DistrFinancingView z ON z.DIS_ID = a.DIS_ID INNER JOIN
			dbo.PriceSystemTable b ON b.PS_ID_SYSTEM = a.SYS_ID INNER JOIN
			dbo.ClientTable y ON CD_ID_CLIENT = CL_ID LEFT OUTER JOIN
			dbo.OrganizationTable x ON ORG_ID = CL_ID_ORG
		WHERE a.DIS_ID = @distrid AND PP_ID = 2 AND PS_ID_PERIOD = @periodid AND TX_ID = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRIMARY_PAY_DEFAULT_GET] TO rl_primary_pay_r;
GO
