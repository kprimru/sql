USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[EIS@Create?Apply(Internal)]
(
    @Act_Id			Int,
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
                                [ТипСчет]		= 'РСБ',
								[НаимБанк]		= BA.BA_NAME,
                                [БИК]			= O.ORG_BIK,
                                [КорСчетБанк]   = O.ORG_LORO,
								[РасчСчет]		= O.ORG_ACCOUNT
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
                [dbo].[EIS@Get?Apply Good](I.[INS_ID], @Grouping, @Detail, ED.[ProductName], ED.[ProductOKEICode], ED.[ProductOKEIFullName], ED.[ProductOKPD2Code], ED.[Product_GUId], ED.[ProductSid]),
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
                            WHERE CA.[CA_ID_CLIENT] = C.[Client_Id]
                                AND CA.[CA_ID_TYPE] = 2
                            FOR XML RAW('СведМестоПоставки'), TYPE
                        )
                    FOR XML RAW('СведМестаПоставки'), TYPE
                )
            FROM [dbo].[ActTable]					AS A
			CROSS APPLY
			(
				SELECT [Client_Id] = IsNull(A.[ACT_ID_PAYER], A.[ACT_ID_CLIENT])
			) AS C
            INNER JOIN [dbo].[OrganizationTable]	AS O ON A.[ACT_ID_ORG] = O.[ORG_ID]
            INNER JOIN [dbo].[InvoiceSaleTable]		AS I ON A.[ACT_ID_INVOICE] = I.[INS_ID]
            INNER JOIN [dbo].[PeriodTable]			AS P ON A.[ACT_DATE] BETWEEN P.[PR_DATE] AND P.[PR_END_DATE]
			INNER JOIN [dbo].[ClientFinancing]		AS F ON F.[ID_CLIENT] = C.[Client_Id]
			OUTER APPLY
			(
				SELECT [ACT_PRICE] = Sum(AD.[AD_TOTAL_PRICE])
				FROM [dbo].[ActDistrTable] AS AD
				WHERE AD.[AD_ID_ACT] = A.[ACT_ID]
			) AS AD
			OUTER APPLY
			(
				SELECT TOP (1)
					[IsActual] = 1
				FROM [dbo].[InvoiceRowTable] AS R
				WHERE R.[INR_ID_INVOICE] = I.[INS_ID]
					AND R.[INR_GOOD] LIKE '%Актуализац%'
			) AS R
			OUTER APPLY
			(
				SELECT [IsActual] = IsNull(R.[IsActual], 0)
			) AS U
            OUTER APPLY [dbo].[EISData@Parse](F.[EIS_DATA], A.[ACT_DATE], AD.[ACT_PRICE], U.[IsActual], @StageGuid, @ProductGuid) AS ED
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('ФайлУПДПрод'), TYPE
        )
)GO
