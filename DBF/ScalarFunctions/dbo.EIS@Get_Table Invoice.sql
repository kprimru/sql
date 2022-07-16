USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[EIS@Get?Table Invoice]
(
	@Invoice_Id		Int,
	@Grouping		Bit,
	@ProductNameForGrouping		VarChar(Max),
	@ProductOKEICode			VarChar(100),
	@ProductOKEIFullName		VarChar(256),
	@ProductOKPD2Code			VarChar(100)

)
RETURNS XML
AS
BEGIN
	RETURN
		(
			SELECT
                (
                    SELECT
                        [НомСтр]        = R.[RowNumber],
                        [НаимТов]       = R.[ProductName],
                        [ОКЕИ_Тов]      = @ProductOKEICode,
                        [КолТов]        = 1,
                        [ЦенаТов]       = [dbo].[MoneyFormatForEIS](R.[Total], R.[Tax]),
                        [СтТовБезНДС]   = [dbo].[MoneyFormatCustom](R.[Price], '.'),
                        [НалСт]         = Cast(Cast(R.[Tax] AS Int) AS VarChar(20)) + '%',
                        [СтТовУчНал]    = [dbo].[MoneyFormatCustom](R.[Total], '.'),
                        (
                            SELECT
                                [БезАкциз] = 'без акциза'
                            FOR XML PATH('Акциз'), TYPE
                        ),
                        (
                            SELECT
                                [СумНал] = [dbo].[MoneyFormatCustom](R.[TaxPrice], '.')
                            FOR XML PATH('СумНал'), TYPE
                        ),
                        (
                            SELECT
                                [ПрТовРаб]      = 3,
                                [НаимЕдИзм]     = @ProductOKEIFullName,
                                [КрНаимСтрПр]   = 'Российская Федерация',
                                [КодТов]        = @ProductOKPD2Code
                            FOR XML RAW('ДопСведТов'), TYPE
                        )
                    FROM
					(
						SELECT
							[RowNumber]		= 1,
							[ProductName]	= @ProductNameForGrouping,
							[Price]			= Sum(R.[INR_SUM] * IsNull(R.[INR_COUNT], 1)),
							[TaxPrice]		= Sum(R.INR_SNDS),
							[Total]			= Sum(R.[INR_SALL]),
							[Tax]			= T.[TX_PERCENT]
						FROM [dbo].[InvoiceRowTable]		AS R
						INNER JOIN [dbo].[DistrView]		AS D WITH(NOEXPAND) ON D.[DIS_ID] = R.[INR_ID_DISTR]
						INNER JOIN [dbo].[SaleObjectTable]	AS S ON S.[SO_ID] = D.[SYS_ID_SO]
						INNER JOIN [dbo].[TaxTable]			AS T ON T.[TX_ID] = R.[INR_ID_TAX]
						WHERE R.[INR_ID_INVOICE] = @Invoice_Id
							AND @Grouping = 1
						GROUP BY TX_PERCENT

						UNION ALL

						SELECT
							[RowNumber]		= Row_Number() OVER(ORDER BY D.[SYS_ORDER], D.[DIS_NUM]),
							[ProductName]	= R.[INR_GOOD] + ' ' + R.[INR_NAME],
							[Price]			= R.[INR_SUM] * IsNull(R.[INR_COUNT], 1),
							[TaxPrice]		= R.[INR_SNDS],
							[Total]			= R.[INR_SALL],
							[Tax]			= T.[TX_PERCENT]
						FROM [dbo].[InvoiceRowTable]		AS R
						INNER JOIN [dbo].[DistrView]		AS D WITH(NOEXPAND) ON D.[DIS_ID] = R.[INR_ID_DISTR]
						INNER JOIN [dbo].[SaleObjectTable]	AS S ON S.[SO_ID] = D.[SYS_ID_SO]
						INNER JOIN [dbo].[TaxTable]			AS T ON T.[TX_ID] = R.[INR_ID_TAX]
						WHERE R.[INR_ID_INVOICE] = @Invoice_Id
							AND @Grouping = 0
					) AS R
					ORDER BY R.[RowNumber]
					FOR XML RAW('СведТов'), TYPE
                ),
                (
                    SELECT
                        [СтТовБезНДСВсего]  = [dbo].[MoneyFormatCustom](Sum(R.[INR_SUM] * IsNull(R.[INR_COUNT], 1)), '.'),
                        [СтТовУчНалВсего]   = [dbo].[MoneyFormatCustom](Sum(R.[INR_SALL]), '.'),
                        (
                            SELECT
                                [СумНал] = [dbo].[MoneyFormatCustom](Sum(R.[INR_SNDS]), '.')
                            FOR XML PATH('СумНалВсего'), TYPE
                        )
                    FROM [dbo].[InvoiceRowTable]	AS R
					INNER JOIN [dbo].[TaxTable]		AS T ON T.[TX_ID] = R.[INR_ID_TAX]
                    WHERE R.[INR_ID_INVOICE] = @Invoice_Id
					GROUP BY T.[TX_PERCENT]
                    FOR XML RAW('ВсегоОпл'), TYPE
                )
            FOR XML RAW('ТаблСчФакт'), TYPE
		)
END
GO
