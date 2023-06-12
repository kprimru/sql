USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INCOME_1C_UPLOAD_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INCOME_1C_UPLOAD_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[INCOME_1C_UPLOAD_SELECT]
	@BEGIN	SMALLDATETIME,
	--@END	SMALLDATETIME,
	@ORG	SMALLINT
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
			O.[ORG_FULL_NAME],
			[Номер] = I.[IN_PAY_NUM],
			[Дата] = Convert(VarChar(20), I.[IN_PAY_DATE], 104),
			[Сумма] = I.[IN_SUM],
			[ПлательщикСчет] = C.[CL_ACCOUNT],
			[ДатаСписано] = NULL,
			[Плательщик] = C.[CL_FULL_NAME],
			[ПлательщикИНН] = C.[CL_INN],
			[ПлательщикРасчСчет] = C.[CL_ACCOUNT],
			[ПлательщикБанк1] = B.BA_NAME,
			B.[BA_LORO], --[ПлательщикКорсчет] =
			B.[BA_BIK], --[ПлательщикБИК] =
			O.ORG_ACCOUNT, --[ПолучательСчет] =
			I.IN_DATE, --[ДатаПоступило] =
			O.ORG_SHORT_NAME, --[Получатель] =
			O.ORG_INN, --[ПолучательИНН] =
			OB.BA_NAME, --[ПолучательБанк1] =
			[ВидПлатежа] = 'Электронно',
			[НазначениеПлатежа] = 'Оплата за ' + T.PR_NAME + ' года. В том числе НДС ' + Cast(Floor(T.TX_PERCENT) AS VarChar(20)) + ' % - ' +   dbo.MoneyFormat(IN_SUM - (IN_SUM / ((100 + TX_PERCENT) / 100))) + ' рублей.'
		FROM dbo.IncomeTable				AS I
			INNER JOIN dbo.ClientTable			AS C ON CL_ID = IN_ID_CLIENT
			OUTER APPLY
		(
			SELECT TOP (1)
				TX_PERCENT,
				PR_NAME
			FROM dbo.IncomeDistrTable					AS ID
				INNER JOIN dbo.DistrView				AS D WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
				INNER JOIN dbo.SaleObjectTable			AS SO ON SYS_ID_SO = SO_ID
				INNER JOIN dbo.PeriodTable				AS P ON P.PR_ID = ID.ID_ID_PERIOD
				INNER JOIN dbo.TaxTable					AS T ON SO_ID_TAX = TX_ID
			WHERE IN_ID = ID_ID_INCOME
		) AS T
			INNER JOIN dbo.OrganizationTable		AS O ON O.ORG_ID = I.IN_ID_ORG
			LEFT JOIN dbo.BankTable					AS B ON B.BA_ID = C.[CL_ID_BANK]
			LEFT JOIN dbo.BankTable					AS OB ON OB.BA_ID = O.[ORG_ID_BANK]
		WHERE
			IN_DATE = @BEGIN --'20230518'
			AND
			IN_ID_ORG = @ORG--1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
