USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EIS@Create?Main]
    @Act_Id			Int,
	@File_Id        VarChar(100),
	@IdentGUId      VarChar(100),
	@StageGuid		VarChar(100)	= NULL,
	@ProductGuid	VarChar(100)	= NULL,
	@Grouping		Bit				= 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@MainContentXml	Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY


        SET @MainContentXml =
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
                                [НомерСчФ]  = I.[INS_NUM],
                                [ДатаСчФ]   = Convert(VarChar(20), GetDate(), 104),
                                [КодОКВ]    = 643,
                                [dbo].[EIS@Get?Seller](O.[ORG_ID]),
								(
									SELECT
										[НомерПРД]	= I.[INS_NUM],
										[ДатаПРД]	= Convert(VarChar(20), I.[INS_DATE], 104),
										[СуммаПРД]	= dbo.MoneyFormatCustom(Sum(R.[INR_SALL]), '.')
									FROM [dbo].[InvoiceRowTable] AS R
									WHERE R.[INR_ID_INVOICE] = I.[INS_ID]
									FOR XML RAW ('СвПРД'), TYPE
								),
								[dbo].[EIS@Get?Buyer](C.[Client_Id], @IdentGUId),
                                (
                                    SELECT
                                        [НаимОКВ] = 'Российский рубль',
                                        (
                                            SELECT TOP (1)
                                                [ДатаГосКонт]   = Convert(VarChar(20), CO_DATE, 104),
                                                [НомерГосКонт]  = CO_NUM
                                            FROM dbo.ContractTable AS CO
                                            INNER JOIN dbo.ContractDistrTable AS CD ON CD.COD_ID_CONTRACT = CO_ID
                                            INNER JOIN dbo.ActDistrTable AS AD ON AD.AD_ID_ACT = A.ACT_ID AND AD.AD_ID_DISTR = CD.COD_ID_DISTR
                                            WHERE CO_ID_CLIENT = A.ACT_ID_CLIENT
                                                AND CO_ACTIVE = 1
                                            FOR XML RAW('ИнфПродГосЗакКазн'), TYPE
                                        )
                                    FOR XML RAW('ДопСвФХЖ1'), TYPE
                                ),
								(
									SELECT
										[НаимДокОтгр]	= 'Документ о приемке',
										[НомДокОтгр]	= I.[INS_NUM],
										[ДатаДокОтгр]	= Convert(VarChar(20), GetDate(), 104)
									FOR XML RAW('ДокПодтвОтгр'), TYPE
								)
                            FOR XML RAW('СвСчФакт'), TYPE
                        ),
						[dbo].[EIS@Get?Table Invoice](I.[INS_ID], @Grouping, ED.[ProductName], ED.[ProductOKEICode], ED.[ProductOKEIFullName], ED.[ProductOKPD2Code]),
                        (
                            SELECT
                                (
                                    SELECT TOP (1)
                                        [СодОпер]   = 'Услуги оказаны в полном объеме',
                                        [ВидОпер]   = 'Оказание информационных услуг за ' + DateName(MONTH, ACT_DATE) + ' ' + Cast(DatePart(Year, ACT_DATE) AS VarChar(100)) + ' г.',
                                        [ДатаПер]   = Convert(VarChar(20), ACT_DATE, 104),
                                        [ДатаНач]   = Convert(VarChar(20), CASE WHEN ED.[StartDate] > PR_DATE THEN ED.[StartDate] ELSE PR_DATE END, 104),
                                        [ДатаОкон]  = Convert(VarChar(20), CASE WHEN ED.[FinishDate] <= A.[ACT_DATE] THEN ED.[FinishDate] ELSE A.[ACT_DATE] END, 104),
                                        (
                                            SELECT TOP (1)
                                                [НаимОсн]   = CK.CK_NAME,
                                                [НомОсн]    = CO.CO_NUM,
                                                [ДатаОсн]   = Convert(VarChar(20), CO.CO_DATE, 104),
                                                [ДопСвОсн]  = 'Реестровый номер в реестре контрактов: ' + ED.[RegNum]
                                            FROM dbo.ContractTable AS CO
                                            INNER JOIN dbo.ContractKind AS CK ON CO_ID_KIND = CK_ID
                                            INNER JOIN dbo.ContractDistrTable AS CD ON CD.COD_ID_CONTRACT = CO_ID
                                            INNER JOIN dbo.ActDistrTable AS AD ON AD.AD_ID_ACT = A.ACT_ID AND AD.AD_ID_DISTR = CD.COD_ID_DISTR
                                            WHERE CO_ID_CLIENT = A.ACT_ID_CLIENT
                                                AND CO_ACTIVE = 1
                                            FOR XML RAW('ОснПер'), TYPE
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
            FOR XML RAW('Файл'), TYPE
        );

		SELECT [Data] = CAST(@MainContentXml AS VarChar(Max));

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Create?Main] TO rl_act_p;
GO
