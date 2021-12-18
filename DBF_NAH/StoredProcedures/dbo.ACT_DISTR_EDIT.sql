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

ALTER PROCEDURE [dbo].[ACT_DISTR_EDIT]
	-- Список параметров процедуры
	@adid INT,
	@price MONEY,
	@taxprice MONEY,
	@totalprice MONEY,
	@Expire SmalLDateTime,
	@IsOnline bit
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

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
			SELECT ACT_ID_CLIENT, ACT_ID, 'ACT', 'Изменение суммы', CONVERT(VARCHAR(20), PR_DATE, 104) + ' ' + DIS_STR + ' - с ' + dbo.MoneyFormat(AD_TOTAL_PRICE) + ' на ' + dbo.MoneyFormat(@totalprice)
			FROM
				dbo.ActTable a
				INNER JOIN dbo.ActDistrTable b ON a.ACT_ID = b.AD_ID_ACT
				INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR
				INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
			WHERE AD_ID = @adid

		UPDATE dbo.ActDistrTable
		SET AD_PRICE = @price,
			AD_TAX_PRICE = @taxprice,
			AD_TOTAL_PRICE = @totalprice,
			AD_EXPIRE = @expire,
			IsOnline = @IsOnline
		WHERE AD_ID = @adid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_DISTR_EDIT] TO rl_act_w;
GO
