USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Create?Apply(Internal)]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[EIS@Create?Apply(Internal)] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[EIS@Create?Apply(Internal)]
(
    @Act_Id			Int,
	@Invoice_Id		Int,
	@File_Id        VarChar(100),
	@IdentGUId      VarChar(100),
	@StageGuid		VarChar(100)	= NULL,
	@ProductGuid	VarChar(100)	= NULL,
	@Grouping		Bit				= 1,
	@Detail			Bit				= 0
)
RETURNS TABLE
AS
RETURN
(
	SELECT
        [Data] =
        (
            SELECT
                [ИдПрилож]  = 'PRIL_ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [ИдФайл]    = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [ВерсФорм]  = '1.00',
                [РукОрг]    = '1',
                (
                    SELECT
                        [РеестрНомКонт] = F.EIS_REG_NUM,
                        [ИдВерсКонт]    = F.EIS_CONTRACT,
                        [ИдЭтапКонт]    = ED.[Stage_GUId]
                    FOR XML RAW('СведКонт'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                [ФирмНаимОрг] = O.[ORG_SHORT_NAME]
                            FOR XML RAW('ЮЛ'), TYPE
                        ),
						(
							SELECT
							    [ТипСчет]			= 'РСБ',
								[ИдПлатежнРеквКонт] = ED.[AccountGuid],
								[БИК]				= O.ORG_BIK,
								[НаимБанк]			= BA.BA_NAME,
                                [КорСчетБанк]		= O.ORG_LORO,
								[РасчСчет]			= O.ORG_ACCOUNT,
								[КонтрагентНаим]	= O.[ORG_SHORT_NAME],
								(
									SELECT
										[Код]	= '05701000',
										[Наим]	= 'Муниципальные образования Приморского края / Городские округа Приморского края / Владивостокский'
									FOR XML RAW('ОКТМО'), TYPE
								)
                            FROM dbo.BankTable AS BA
                            WHERE BA_ID = ORG_ID_BANK
                            FOR XML RAW('БанкРекв'), TYPE
						)
                    FOR XML RAW('СведПоставщик'), TYPE
                ),
				(
					SELECT
						[КодСВР]	= F.EIS_DATA.value('(/export/contract/customer/consRegistryNum)[1]', 'VarChar(512)')
					FOR XML RAW('СведЗаказчик'), TYPE
				),
                [dbo].[EIS@Get?Apply Good](MD.[Invoice_Id], @Grouping, @Detail, ED.[ProductName], ED.[ProductOKEICode], ED.[ProductOKEIFullName], ED.[ProductOKPD2Code], ED.[Product_GUId], ED.[ProductSid]),
                (
                    SELECT
                        (
                            SELECT
                                [Место]             = IsNull(CA_INDEX + ', ' + CT_NAME + ', ' + ST_PREFIX + ' ' + ST_NAME + ', ' + CA_HOME, CA_FREE),
                                [ИнфДляУчаст]       = '0',--@IdentGUId,
                                [ИдМестаПоставки]   = @IdentGUId,
                                (
                                    SELECT
                                        (
                                            SELECT
                                                [Код]   = '25000000000',
                                                [Наим]  = 'Приморский край',
                                                [Адрес] = 'Российская Федерация, Приморский край',
												(
													SELECT
														[РайонГород]   = CA.CT_NAME + ' ' + CT_PREFIX,
														[НаселенПункт]			= '-'
													FOR XML RAW('НеКЛАДР'), TYPE
												)
                                            FOR XML RAW('КЛАДР'), TYPE
                                        )
                                    FOR XML RAW('ПоКЛАДР'), TYPE
								)
                            FROM [dbo].[ClientAddressView] AS CA
                            WHERE CA.[CA_ID_CLIENT] = MD.[OriginalClient_Id]
                                AND CA.[CA_ID_TYPE] = 2
                            FOR XML RAW('СведМестоПоставки'), TYPE
                        )
                    FOR XML RAW('СведМестаПоставки'), TYPE
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
			INNER JOIN [dbo].[ClientFinancing]		AS F ON F.[ID_CLIENT] = MD.[OriginalClient_Id]
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
            FOR XML RAW('ФайлУПДПрод'), TYPE
        )
)GO
