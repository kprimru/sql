USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[EIS@Get?Apply Good]
(
	@Invoice_Id		Int,
	@Grouping		Bit,
	@Detail			Bit,
	@ProductNameForGrouping		VarChar(Max),
	@ProductOKEICode			VarChar(100),
	@ProductOKEIFullName		VarChar(256),
	@ProductOKPD2Code			VarChar(100),
	@ProductGuid				VarChar(100),
	@ProductSid					VarChar(100)
)
RETURNS XML
AS
BEGIN
	RETURN
		(
			SELECT
				(
                    SELECT
						(
                            SELECT
                                [ИдТРУ]         = @ProductGuid,
								[ТехИдТРУ]		= @ProductSid,
                                [НаимТовИсх]    = R.[ProductName],
								(
									SELECT
										[НомСтр]			= R.[RowNumber],
										[ЦенаИзКонтСНДС]	= dbo.MoneyFormatCustom(R.[INR_SALL], '.'),
										[ПрУлучшХаракт]		= '1'
									FOR XML RAW ('НеЛПСвед'), TYPE
								)
							WHERE @Detail = 0
                            FOR XML RAW('НедеталТРУ'), TYPE
                        ),
						(
							SELECT
								(
									SELECT
                                        [ИдТРУ]         = @ProductGuid,
                                        [КодТов]        = @ProductOKPD2Code,
                                        [НаимТов]       = @ProductNameForGrouping,
                                        --[НаимТов]       = Max(INR_GOOD),
                                        [КодЕдИзм]      = @ProductOKEICode,
                                        [НаимЕдИзм]     = @ProductOKEIFullName,
                                        [ЦенаЕдИзм]     = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                        [КолТов]        = 1,
                                        [ПрТовРаб]      = 3,
                                        [СтТовБезНДС]   = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                        [НалСт]         ='20%',
                                        [СтТовУчНал]    = dbo.MoneyFormatCustom(Sum(R.INR_SALL), '.'),
                                        (
                                            SELECT
                                                (
                                                    SELECT
                                                        [СумНал] = dbo.MoneyFormatCustom(Sum(R.INR_SNDS), '.')
                                                    FOR XML PATH(''), TYPE
                                                )
                                            FOR XML RAW('СумНал'), TYPE
                                        ),
                                        (
                                            SELECT
                                                (
                                                    SELECT
                                                        [БезАкциз] = 'без акциза'
                                                    FOR XML PATH(''), TYPE
                                                )
                                            FOR XML RAW('Акциз'), TYPE
                                        )
                                    FROM dbo.InvoiceRowTable AS R
                                    WHERE R.INR_ID_INVOICE = @Invoice_Id
                                    FOR XML RAW('СведРод'), TYPE
								),
								(
									SELECT
										[НомСтр]		= 1,
										[ИдТРУ]			= @ProductGuid,
										[ЦенаСНДС]		= dbo.MoneyFormatCustom(R.INR_SALL, '.'),
										[ПрУлучшХаракт]	= 1
									FOR XML RAW('СведДетал'), TYPE
								)
							WHERE @Detail = 1
							FOR XML RAW('ДеталТРУ'), TYPE
						)
					FROM
					(
						SELECT
							[ProductName],
							[INR_SALL],
							[RowNumber] = Row_Number() OVER(ORDER BY [ProductName])
						FROM
						(
							SELECT
								[ProductName]	= R.[INR_GOOD] + ' ' + R.[INR_NAME],
								[INR_SALL]		= Sum(R.INR_SALL)
							FROM dbo.InvoiceRowTable AS R
							WHERE R.INR_ID_INVOICE = @Invoice_Id
							GROUP BY R.[INR_GOOD] + ' ' + R.[INR_NAME]
						) AS R
						WHERE @Grouping = 0

						UNION ALL

						SELECT
							[ProductName],
							[INR_SALL],
							[RowNumber] = Row_Number() OVER(ORDER BY [ProductName])
						FROM
						(
							SELECT
								[ProductName]	= @ProductNameForGrouping,
								[INR_SALL]		= Sum(R.[INR_SALL])
							FROM [dbo].[InvoiceRowTable] AS R
							WHERE R.[INR_ID_INVOICE] = @Invoice_Id
						) AS R
						WHERE @Grouping = 1
					) AS R

                    FOR XML RAW('СведТРУ'), TYPE
                )
            FOR XML RAW('СведТов'), TYPE
		)
END
GO
