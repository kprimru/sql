USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[PRIMARY_PAY_GET_PRICE_BY_DISTR]
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
		-- посчитать по фин.установкам стоимость дистрибутива (если установки указаны)
		DECLARE @sncoef DECIMAL(8, 4)

		SELECT @sncoef = SN_COEF
		FROM 
			dbo.SystemNetTable c INNER JOIN
			dbo.SystemNetCountTable d ON d.SNC_ID_SN = c.SN_ID
		WHERE 
			SNC_NET_COUNT = (
								SELECT RN_NET_COUNT
								FROM
									dbo.RegNodeTable e INNER JOIN
									dbo.DistrView f WITH(NOEXPAND) ON
												e.RN_SYS_NAME = f.SYS_REG_NAME AND
												e.RN_DISTR_NUM = f.DIS_NUM AND
												e.RN_COMP_NUM = f.DIS_COMP_NUM
								WHERE DIS_ID = @distrid
							)

		IF @sncoef IS NULL
			SET @sncoef = 1

		SELECT PS_PRICE * @sncoef * PP_COEF_MUL AS DIS_PRICE
		FROM
			dbo.PriceView a INNER JOIN
			dbo.PeriodTable b ON a.PR_ID = b.PR_ID INNER JOIN
			dbo.PriceTable c ON c.PP_ID_TYPE = a.PT_ID
		WHERE SYS_ID =
						(
							SELECT SYS_ID
							FROM dbo.DistrView WITH(NOEXPAND)
							WHERE DIS_ID = @distrid
						) AND
			GETDATE() BETWEEN b.PR_DATE AND b.PR_END_DATE AND PP_ID = 2

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRIMARY_PAY_GET_PRICE_BY_DISTR] TO rl_primary_pay_r;
GO