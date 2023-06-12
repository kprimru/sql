USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_PRINT?UPD COMM]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_PRINT?UPD COMM]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD COMM]
    @Act_Id     Int,
    @ActData    VarBinary(Max) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @ActDate        SmallDateTime,
        @EisCode        VarChar(256),
        @ActPrice       Money,
        @Client_Id      Int,
        @MainContent    Xml,
        @ApplyContent   Xml,
        @File_Id        VarChar(100),
        @MainBase64     VarChar(Max),
        @ActBase64     VarChar(Max),
        @ApplyBase64    VarChar(Max);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @File_Id    = Cast(NewId() AS VarChar(100));

        SELECT
            @ActDate = ACT_DATE,
            @Client_Id  = ACT_ID_CLIENT,
            @ActPrice = ACT_PRICE
        FROM dbo.ActTable
        OUTER APPLY
        (
            SELECT ACT_PRICE = Sum(AD_TOTAL_PRICE)
            FROM dbo.ActDistrTable
            WHERE AD_ID_ACT = ACT_ID
        ) AS AD
        WHERE ACT_ID = @Act_Id;

        SELECT @EISCode = [EIS_COMM_CODE]
        FROM dbo.ClientFinancing
        WHERE ID_CLIENT = @Client_Id;

        IF @EISCode IS NULL OR @EISCode = ''
            RaisError ('Не заполнен атрибут "Код ЕИС" у клиента', 16, 1);

        SET @MainContent =
        (
            SELECT
                [ИдФайл]    = 'ON_NSCHFDOPPR_' + F.[EIS_COMM_CODE] + '_' + O.[EIS_COMM_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [ВерсФорм]  = '5.01',
                [ВерсПрог]  = 'Астрал.ЭДО',
                (
                    SELECT
                        [ИдОтпр]    = O.[EIS_COMM_CODE],
                        [ИдПол]     = F.[EIS_COMM_CODE],
                        (
                            SELECT
                                [ИННЮЛ]     = '4029017981',
                                [НаимОрг]   = 'АО Калуга Астрал',
                                [ИдЭДО]     = '2AE'
                            FOR XML RAW ('СвОЭДОтпр'), TYPE
                        )
                    FOR XML RAW('СвУчДокОбор'), TYPE
                ),
                (
                    SELECT
                        [КНД]               = '1115131',
                        [Функция]           = 'СЧФДОП',
                        [ДатаИнфПр]         = Convert(VarChar(20), GetDate(), 104),
                        [ВремИнфПр]         = Replace(Convert(VarChar(20), GetDate(), 108), ':', '.'),
                        [ПоФактХЖ]          = 'Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
                        [НаимДокОпр]        = 'Счет-фактура и документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
                        [НаимЭконСубСост]   = O.ORG_FULL_NAME,
                        (
                            SELECT
                                [НомерСчФ]  = I.INS_NUM,
                                --[ДатаСчФ]   = Convert(VarChar(20), I.INS_DATE, 104),
                                [ДатаСчФ]   = Convert(VarChar(20), I.INS_DATE, 104),
                                [КодОКВ]    = 643,
                                (
                                    SELECT
                                        [КраткНазв] = O.ORG_SHORT_NAME,
                                        (
                                            SELECT
                                                [НаимОрг]   = O.ORG_FULL_NAME,
                                                [ИННЮЛ]     = O.ORG_INN,
                                                [КПП]       = O.ORG_KPP
                                            FOR XML RAW('СвЮЛУч'), TYPE, ROOT('ИдСв')
                                        ),
                                        (
                                            SELECT
                                                [Индекс]    = O.ORG_INDEX,
                                                [КодРегион] = C.CT_REGION,
                                                [Город]     = C.CT_NAME,
                                                [Улица]     = S.ST_NAME,
                                                [Дом]       = ORG_HOME
                                            FROM dbo.StreetTable AS S
                                            INNER JOIN dbo.CityTable AS C ON S.ST_ID_CITY = C.CT_ID
                                            WHERE S.ST_ID = O.ORG_ID_STREET
                                            FOR XML RAW('АдрРФ'), TYPE, ROOT('Адрес')
                                        ),
                                        (
                                            SELECT
                                                [Id] = NULL
                                            FOR XML RAW('СвБанк'), TYPE, ROOT('БанкРекв')
                                        )
                                    FOR XML RAW ('СвПрод'), TYPE
                                ),
                                (
                                    SELECT TOP (1)
                                        [НомерПРД]  = IN_PAY_NUM,
                                        [ДатаПРД]   = Convert(VarChar(20), IN_PAY_DATE, 104)
                                    FROM dbo.ActDistrTable
                                    INNER JOIN dbo.IncomeDistrTable ON AD_ID_DISTR = ID_ID_DISTR AND AD_ID_PERIOD = ID_ID_PERIOD
                                    INNER JOIN dbo.IncomeTable ON IN_ID = ID_ID_INCOME
                                    WHERE AD_ID_ACT = ACT_ID
                                    ORDER BY IN_PAY_DATE DESC, IN_PAY_NUM
                                    FOR XML RAW('СвПРД'), TYPE
                                ),
                                (
                                    SELECT
                                        (
											SELECT
												(
													SELECT
														[НаимОрг]   = CL.CL_FULL_NAME,
														[ИННЮЛ]     = CL.CL_INN,
														[КПП]       = CL.CL_KPP
													WHERE Len(CL_INN) != 12
													FOR XML RAW('СвЮЛУч'), TYPE
												),
												(
													SELECT
														(
															SELECT
																[Фамилия]   = CP.PER_FAM,
																[Имя]		= CP.PER_NAME,
																[Отчество]  = CP.PER_OTCH
															FROM dbo.ClientPersonalTable AS CP
															WHERE CP.PER_ID_CLIENT = CL.CL_ID
															FOR XML RAW('ФИО'), TYPE
														)
													WHERE Len(CL_INN) = 12
													FOR XML RAW('СвИП'), TYPE
												)
											FOR XML RAW('ИдСв'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [Индекс]    = CA.CA_INDEX,
                                                [КодРегион] = CA.CT_REGION,
                                                [Район]     = CA.AR_NAME,
                                                [Город]     = CA.CT_NAME,
                                                [Улица]     = NullIf(CA.ST_NAME, ''),
                                                [Дом]       = NullIf(CA_HOME, '')
                                            FROM dbo.ClientAddressView AS CA
                                            WHERE CA.CA_ID_CLIENT = CL.CL_ID
                                                AND CA.CA_ID_TYPE = 1
                                            FOR XML RAW('АдрРФ'), TYPE, ROOT('Адрес')
                                        )
                                    FROM dbo.ClientTable AS CL
                                    WHERE CL.CL_ID = I.INS_ID_CLIENT
                                    FOR XML RAW ('СвПокуп'), TYPE
                                ),
                                (
                                    SELECT
                                        [НаимОКВ] = 'Российский рубль',
                                        (
                                            SELECT
                                                [НаимОсн]   = 'Без документа-основания'
                                            FOR XML RAW('ОснУстДенТреб'), TYPE
                                        )
                                    FOR XML RAW('ДопСвФХЖ1'), TYPE
                                ),
                                (
                                    SELECT
                                        [НаимДокОтгр]   = ' ',
                                        [НомДокОтгр]    = CASE WHEN R.MAX_RN = 1 THEN '1' ELSE '1-' + Cast(R.MAX_RN AS VarChar(20)) END + ' №' + Cast(INS_NUM AS VarChar(20)),
                                        [ДатаДокОтгр]   = Convert(VarChar(20), ACT_DATE, 104)
                                    FROM
                                    (
                                        SELECT
                                            MAX_RN = Count(*)
                                        FROM dbo.InvoiceRowTable AS R
                                        WHERE R.INR_ID_INVOICE = I.INS_ID
                                    ) AS R
                                    FOR XML RAW('ДокПодтвОтгр'), TYPE
                                )
                            FOR XML RAW('СвСчФакт'), TYPE
                        ),
                        (
                            SELECT
                                (
                                    SELECT
                                        [НомСтр]        = Row_Number() OVER(ORDER BY D.SYS_ORDER, D.DIS_NUM),
                                        [ОКЕИ_Тов]      = '362',
                                        [НаимТов]       = R.INR_GOOD + ' ' + R.INR_NAME,
                                        --[ОКЕИ_Тов]      = S.[SO_OKEI],
                                        [КолТов]        = 1,
                                        -- ToDo хардкод 20%
                                        [ЦенаТов]       = CASE WHEN P.[Price] LIKE '%.' THEN P.[Price] + '00' ELSE P.[Price] END,
                                        [СтТовБезНДС]   = dbo.MoneyFormatCustom(R.INR_SUM * IsNull(R.INR_COUNT, 1), '.'),
                                        [НалСт]         = Cast(CAST(TX_PERCENT AS Int) AS VarChar(20)) + '%',
                                        [СтТовУчНал]    = dbo.MoneyFormatCustom(R.INR_SALL, '.'),
                                        (
                                            SELECT
                                                [БезАкциз] = 'без акциза'
                                            FOR XML PATH('Акциз'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [СумНал] = dbo.MoneyFormatCustom(R.INR_SNDS, '.')
                                            FOR XML PATH('СумНал'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [ПрТовРаб]      = 3,
                                                [НадлОтп]       = 1,
                                                -- ToDo
                                                [ХарактерТов]   = 'Услуги по модификации Системы и ее составных частей (Комплектов Системы)',
                                                [НаимЕдИзм]     = 'мес'
                                            FOR XML RAW('ДопСведТов'), TYPE
                                        )
                                    FROM dbo.InvoiceRowTable AS R
                                    INNER JOIN dbo.DistrView AS D WITH(NOEXPAND) ON R.INR_ID_DISTR = D.DIS_ID
                                    INNER JOIN dbo.SaleObjectTable AS S ON S.SO_ID = D.SYS_ID_SO
                                    INNER JOIN dbo.TaxTable AS T ON T.TX_ID = R.INR_ID_TAX
                                    OUTER APPLY
                                    (
                                        SELECT
                                            [Price] = [Common].[Trim#Right](Convert(VarChar(100), Cast(Cast(R.INR_SALL AS Decimal(20, 12)) / (1 + 20.0/100) AS Decimal(20, 11))), '0')
                                    ) AS P
                                    WHERE R.INR_ID_INVOICE = I.INS_ID
                                    ORDER BY D.SYS_ORDER, D.DIS_NUM
                                    FOR XML RAW('СведТов'), TYPE
                                ),
                                (
                                    SELECT
                                        [СтТовБезНДСВсего]  = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                        [СтТовУчНалВсего]   = dbo.MoneyFormatCustom(Sum(R.INR_SALL), '.'),
                                        (
                                            SELECT
                                                [СумНал] = dbo.MoneyFormatCustom(Sum(R.INR_SNDS), '.')
                                            FOR XML PATH('СумНалВсего'), TYPE
                                        ),
                                        (
                                            SELECT --ToDo
                                                1--IsNull(R.INR_COUNT, 1)
                                            FOR XML PATH('КолНеттоВс'), TYPE
                                        )
                                    FROM dbo.InvoiceRowTable AS R
                                    WHERE R.INR_ID_INVOICE = I.INS_ID
                                    FOR XML RAW('ВсегоОпл'), TYPE
                                )
                            FOR XML RAW('ТаблСчФакт'), TYPE
                        ),
                        (
                            SELECT
                                (
                                    SELECT
                                        [СодОпер]   = 'Перечисленные в документе ценности переданы',
                                        (
                                            SELECT TOP (1)
                                                [НаимОсн]   = CK.CK_NAME,
                                                [НомОсн]    = CO.CO_NUM,
                                                [ДатаОсн]   = Convert(VarChar(20), CO.CO_DATE, 104)
                                            FROM dbo.ContractTable AS CO
                                            INNER JOIN dbo.ContractKind AS CK ON CO_ID_KIND = CK_ID
                                            INNER JOIN dbo.ContractDistrTable AS CD ON CD.COD_ID_CONTRACT = CO_ID
                                            INNER JOIN dbo.ActDistrTable AS AD ON AD.AD_ID_ACT = A.ACT_ID AND AD.AD_ID_DISTR = CD.COD_ID_DISTR
                                            WHERE CO_ID_CLIENT = A.ACT_ID_CLIENT
                                                AND CO_ACTIVE = 1
                                            FOR XML RAW('ОснПер'), TYPE
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
                                        [Должн]     = O.ORG_DIR_POS,
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
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('Файл'), TYPE
        );

        SELECT
            [Folder]        = Replace(Replace(Replace(RTrim(Ltrim(C.CL_PSEDO)), '\', ''), ':', ''), '/', ''),
            [FileName]      = IsNull(Replace(Replace(Replace(F.[FileName], '\', ''), ':', ''), '/', ''), Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100))), -- ToDo костыль
            [Data]          = F.[Data]
        FROM dbo.ActTable           AS A
        INNER JOIN dbo.ClientTable  AS C ON A.ACT_ID_CLIENT = C.CL_ID
        CROSS APPLY
        (
            SELECT
                [FileName]  = @MainContent.value('(/Файл/@ИдФайл)[1]', 'VarChar(256)') + '.xml',
                [Data]      = Cast(@MainContent AS VarChar(Max))
        )AS F
        WHERE A.ACT_ID = @Act_Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT?UPD COMM] TO rl_act_p;
GO
