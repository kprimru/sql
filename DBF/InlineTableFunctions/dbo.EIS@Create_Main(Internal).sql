USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Create?Main(Internal)]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[EIS@Create?Main(Internal)] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[EIS@Create?Main(Internal)]
(
    @Act_Id			Int,
	@Invoice_Id		Int,
	@File_Id        VarChar(100),
	@IdentGUId      VarChar(100),
	@StageGuid		VarChar(100)	= NULL,
	@ProductGuid	VarChar(100)	= NULL,
	@Grouping		Bit				= 1
)
RETURNS TABLE
AS
RETURN
(
	SELECT [Data] =
        (
            SELECT
                [ИдФайл]    = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [ВерсФорм]  = '5.01',
                [ВерсПрог]  = '11.0',
                (
                    SELECT
                        [ИдОтпр]    = O.[EIS_CODE],
                        [ИдПол]     = F.[EIS_CODE],
                        (
                            SELECT
                                [ИННЮЛ]     = '7710568760',
                                [НаимОрг]   = 'Федеральное казначейство',
                                [ИдЭДО]     = '2ZK'
                            FOR XML RAW ('СвОЭДОтпр'), TYPE
                        )
                    FOR XML RAW('СвУчДокОбор'), TYPE
                ),
                (
                    SELECT
                        [КНД]               = '1115131',
                        [Функция]           = 'СЧФДОП',
                        [ПоФактХЖ]          = 'Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
                        [НаимДокОпр]        = 'Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
						[ДатаИнфПр]         = Convert(VarChar(20), GetDate(), 104),
                        [ВремИнфПр]         = Replace(Convert(VarChar(20), GetDate(), 108), ':', '.'),
                        [НаимЭконСубСост]   = O.[ORG_FULL_NAME],
                        [СоглСтрДопИнф]     = '0000.0000.0000',
                        (
                            SELECT
                                [НомерСчФ]  = MD.[InvoiceNum],
                                [ДатаСчФ]   = Convert(VarChar(20), GetDate(), 104),
                                [КодОКВ]    = 643,
                                [dbo].[EIS@Get?Seller](O.[ORG_ID]),
								(
									SELECT
										[НомерПРД]	= MD.[InvoiceNum],
										[ДатаПРД]	= Convert(VarChar(20), MD.[InvoiceDate], 104),
										[СуммаПРД]	= dbo.MoneyFormatCustom(Sum(R.[INR_SALL]), '.')
									FROM [dbo].[InvoiceRowTable] AS R
									WHERE R.[INR_ID_INVOICE] = MD.[Invoice_Id]
									FOR XML RAW ('СвПРД'), TYPE
								),
								[dbo].[EIS@Get?Buyer](MD.[Client_Id], @IdentGUId),
                                (
                                    SELECT
                                        [НаимОКВ] = 'Российский рубль',
                                        (
                                            SELECT TOP (1)
                                                [ДатаГосКонт]   = Convert(VarChar(20), CO_DATE, 104),
                                                [НомерГосКонт]  = CO_NUM
                                            FROM dbo.ContractTable AS CO
											WHERE CO.[CO_ID] = MD.[Contract_Id]
                                            FOR XML RAW('ИнфПродГосЗакКазн'), TYPE
                                        )
                                    FOR XML RAW('ДопСвФХЖ1'), TYPE
                                ),
								(
									SELECT
										[НаимДокОтгр]	= 'Документ о приемке',
										[НомДокОтгр]	= MD.[InvoiceNum],
										[ДатаДокОтгр]	= Convert(VarChar(20), GetDate(), 104)
									FOR XML RAW('ДокПодтвОтгр'), TYPE
								)
                            FOR XML RAW('СвСчФакт'), TYPE
                        ),
						[dbo].[EIS@Get?Table Invoice](MD.[Invoice_Id], @Grouping, ED.[ProductName], ED.[ProductOKEICode], ED.[ProductOKEIFullName], ED.[ProductOKPD2Code], ED.[ProductVolumeSpecifyingMethod]),
                        (
                            SELECT
                                (
                                    SELECT TOP (1)
                                        [СодОпер]   = 'Услуги оказаны в полном объеме',
                                        [ВидОпер]   = 'Оказание информационных услуг за ' + DateName(MONTH, MD.[Date]) + ' ' + Cast(DatePart(Year, MD.[Date]) AS VarChar(100)) + ' г.',
                                        [ДатаПер]   = Convert(VarChar(20), MD.[Date], 104),
                                        [ДатаНач]   = Convert(VarChar(20), CASE WHEN ED.[StartDate] > PR_DATE THEN ED.[StartDate] ELSE PR_DATE END, 104),
                                        [ДатаОкон]  = Convert(VarChar(20), CASE WHEN ED.[FinishDate] <= MD.[Date] THEN ED.[FinishDate] ELSE MD.[Date] END, 104),
                                        (
                                            SELECT TOP (1)
                                                [НаимОсн]   = CK.CK_NAME,
                                                [НомОсн]    = CO.CO_NUM,
                                                [ДатаОсн]   = Convert(VarChar(20), CO.CO_DATE, 104),
                                                [ДопСвОсн]  = 'Реестровый номер в реестре контрактов: ' + ED.[RegNum]
                                            FROM dbo.ContractTable AS CO
											INNER JOIN dbo.ContractKind AS CK ON CO_ID_KIND = CK_ID
											WHERE CO.[CO_ID] = MD.[Contract_Id]
                                            FOR XML RAW('ОснПер'), TYPE
                                        ),
										(
											SELECT
											(
												SELECT
													[Должность]	= ORG_DIR_POS,
													[ОснПолн]	= 'Лицо, уполномоченное действовать без доверенности от имени юридического лица',
													(
														SELECT
															[Фамилия]	= ORG_DIR_FAM,
															[Имя]		= ORG_DIR_NAME,
															[Отчество]	= ORG_DIR_OTCH
														FOR XML RAW('ФИО'), TYPE
													)
												FOR XML RAW('РабОргПрод'), TYPE
											)
											FOR XML RAW('СвЛицПер'), TYPE
										),
                                        (
                                            SELECT
                                                [NULL]      = NULL
                                            FOR XML RAW('ТранГруз'), TYPE
                                        )
									FOR XML RAW('СвПер'), TYPE
                                )
                            FOR XML RAW('СвПродПер'), TYPE
                        ),
                        (
                            SELECT
                                [ОблПолн]   = 5,
                                [Статус]    = 1,
                                [ОснПолн]   = 'Должностные обязанности',
                                (
                                    SELECT
                                        [ИННЮЛ]     = O.ORG_INN,
                                        [НаимОрг]   = O.ORG_FULL_NAME,
                                        [Должн]     = O.ORG_DIR_POS,
                                        [ИныеСвед]  = 1,
                                        (
                                            SELECT
                                                [Фамилия] = ORG_DIR_FAM,
                                                [Имя] = ORG_DIR_NAME,
                                                [Отчество] = ORG_DIR_OTCH
                                            FOR XML RAW('ФИО'), TYPE
                                        )
                                    FOR XML RAW('ЮЛ'), TYPE
                                )
                            FOR XML RAW('Подписант'), TYPE
                        )
                    FOR XML RAW('Документ'), TYPE
                )
            FROM
			(
				SELECT
					[Client_Id]			= C.[Client_Id],
					[OriginalClient_Id]	= A.[ACT_ID_CLIENT],
					[Organization_Id]	= A.[ACT_ID_ORG],
					[Date]				= A.[ACT_DATE],
					[TotalSum]			= AD.[ACT_PRICE],
					[Invoice_Id]		= I.[INS_ID],
					[InvoiceNum]		= I.[INS_NUM],
					[InvoiceDate]		= I.[INS_DATE],
					[Contract_Id]		= CO.[Contract_Id]
				FROM [dbo].[ActTable]					AS A
				CROSS APPLY
				(
					SELECT [Client_Id] = IsNull(A.[ACT_ID_PAYER], A.[ACT_ID_CLIENT])
				) AS C
				INNER JOIN [dbo].[InvoiceSaleTable]		AS I ON A.[ACT_ID_INVOICE] = I.[INS_ID]
				OUTER APPLY
				(
					SELECT [ACT_PRICE] = Sum(AD.[AD_TOTAL_PRICE])
					FROM [dbo].[ActDistrTable] AS AD
					WHERE AD.[AD_ID_ACT] = A.[ACT_ID]
				) AS AD
				OUTER APPLY
				(
					SELECT TOP (1)
                        [Contract_Id] = CO.[CO_ID]
                    FROM dbo.ContractTable AS CO
                    INNER JOIN dbo.ContractKind AS CK ON CO_ID_KIND = CK_ID
                    INNER JOIN dbo.ContractDistrTable AS CD ON CD.COD_ID_CONTRACT = CO_ID
                    INNER JOIN dbo.ActDistrTable AS AD ON AD.AD_ID_ACT = A.ACT_ID AND AD.AD_ID_DISTR = CD.COD_ID_DISTR
                    WHERE CO_ID_CLIENT = A.[ACT_ID_CLIENT]
                        AND CO_ACTIVE = 1
				) AS CO
				WHERE ACT_ID = @Act_Id

				UNION ALL

				SELECT
					[Client_Id]			= C.[Client_Id],
					[OriginalClient_Id]	= I.[INS_ID_CLIENT],
					[Organization_Id]	= I.[INS_ID_ORG],
					[Date]				= I.[INS_DATE],
					[TotalSum]			= AD.[ACT_PRICE],
					[Invoice_Id]		= I.[INS_ID],
					[InvoiceNum]		= I.[INS_NUM],
					[InvoiceDate]		= I.[INS_DATE],
					[Contract_Id]		= CO.[Contract_Id]
				FROM [dbo].[InvoiceSaleTable]		AS I
				CROSS APPLY
				(
					SELECT [Client_Id] = IsNull(I.[INS_ID_PAYER], I.[INS_ID_CLIENT])
				) AS C
				OUTER APPLY
				(
					SELECT [ACT_PRICE] = Sum(IR.[INR_SNDS])
					FROM [dbo].[InvoiceRowTable] AS IR
					WHERE IR.[INR_ID_INVOICE] = I.[INS_ID]
				) AS AD
				OUTER APPLY
				(
					SELECT TOP (1)
                        [Contract_Id] = CO.[CO_ID]
                    FROM dbo.ContractTable AS CO
                    INNER JOIN dbo.ContractKind AS CK ON CO_ID_KIND = CK_ID
                    INNER JOIN dbo.ContractDistrTable AS CD ON CD.COD_ID_CONTRACT = CO_ID
                    INNER JOIN dbo.InvoiceRowTable AS AD ON AD.INR_ID_INVOICE = I.INS_ID AND AD.INR_ID_DISTR = CD.COD_ID_DISTR
                    WHERE CO_ID_CLIENT = I.[INS_ID_CLIENT]
                        AND CO_ACTIVE = 1
				) AS CO
				WHERE INS_ID = @Invoice_Id
			) AS MD
            INNER JOIN [dbo].[OrganizationTable]	AS O ON MD.[Organization_Id] = O.[ORG_ID]
            INNER JOIN [dbo].[PeriodTable]			AS P ON MD.[Date] BETWEEN P.[PR_DATE] AND P.[PR_END_DATE]
			INNER JOIN [dbo].[ClientFinancing]		AS F ON F.[ID_CLIENT] = MD.[Client_Id]
			OUTER APPLY
			(
				SELECT TOP (1)
					[IsActual] = 1
				FROM [dbo].[InvoiceRowTable] AS R
				WHERE R.[INR_ID_INVOICE] = MD.[Invoice_Id]
					AND R.[INR_GOOD] LIKE '%Актуализац%'
			) AS R
			OUTER APPLY
			(
				SELECT [IsActual] = IsNull(R.[IsActual], 0)
			) AS U
            OUTER APPLY [dbo].[EISData@Parse](F.[EIS_DATA], MD.[Date], MD.[TotalSum], U.[IsActual], @StageGuid, @ProductGuid) AS ED

            FOR XML RAW('Файл'), TYPE
        )
)GO
