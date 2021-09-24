USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD]
    @Act_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Stage          VarChar(100),
        @ActDate        SmallDateTime,
        @Client_Id      Int,
        @EISData        Xml,
        @Data           Xml,
        @MainContent    Xml,
        @ApplyContent   Xml,
        @File_Id        VarChar(100),
        @MainBase64     VarChar(Max),
        @ApplyBase64    VarChar(Max);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @File_Id = Cast(NewId() AS VarChar(100));
        SELECT
            @ActDate = ACT_DATE,
            @Client_Id  = ACT_ID_CLIENT
        FROM dbo.ActTable
        WHERE ACT_ID = @Act_Id;

        SELECT @Data = EIS_DATA
        FROM dbo.ClientFinancing
        WHERE EIS_DATA IS NOT NULL
            AND ID_CLIENT = @Client_Id;

        SET @MainContent =
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
                        [ДатаИнфПр]         = Convert(VarChar(20), GetDate(), 104),
                        [ВремИнфПр]         = Replace(Convert(VarChar(20), GetDate(), 108), ':', '.'),
                        [ПоФактХЖ]          = 'Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
                        [НаимДокОпр]        = 'Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
                        [НаимЭконСубСост]   = O.ORG_FULL_NAME,
                        [СоглСтрДопИнф]     = '0000.0000.0000',
                        (
                            SELECT
                                [НомерСчФ]  = I.INS_NUM,
                                --[ДатаСчФ]   = Convert(VarChar(20), I.INS_DATE, 104),
                                [ДатаСчФ]   = Convert(VarChar(20), GetDate(), 104),
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
                                                [Тлф]       = O.ORG_PHONE,
                                                [ЭлПочта]   = O.ORG_EMAIL
                                            FOR XML RAW('Контакт'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [НомерСчета] = O.ORG_ACCOUNT,
                                                (
                                                    SELECT
                                                        [НаимБанк]  = BA.BA_NAME,
                                                        [БИК]       = O.ORG_BIK,
                                                        [КорСчет]   = O.ORG_LORO
                                                    FROM dbo.BankTable AS BA
                                                    WHERE BA_ID = ORG_ID_BANK
                                                    FOR XML RAW('СвБанк'), TYPE
                                                )
                                            FOR XML RAW('БанкРекв'), TYPE
                                        )
                                    FOR XML RAW ('СвПрод'), TYPE
                                ),
                                (
                                    SELECT
                                        [ОКПО]      = CL.CL_OKPO,
                                        [КраткНазв] = F.EIS_DATA.value('(/export/contract/customer/shortName)[1]', 'VarChar(512)'),
                                        (
                                            SELECT
                                                [НаимОрг]   = F.EIS_DATA.value('(/export/contract/customer/fullName)[1]', 'VarChar(512)'),--CL.CL_FULL_NAME,
                                                [ИННЮЛ]     = CL.CL_INN,
                                                [КПП]       = CL.CL_KPP
                                            FOR XML RAW('СвЮЛУч'), TYPE, ROOT('ИдСв')
                                        ),
                                        (
                                            SELECT
                                                [Индекс]    = CA.CA_INDEX,
                                                [КодРегион] = CA.CT_REGION,
                                                [Район]     = CA.AR_NAME,
                                                [Город]     = CA.CT_NAME,
                                                [Улица]     = CA.ST_NAME,
                                                [Дом]       = CA_HOME
                                            FROM dbo.ClientAddressView AS CA
                                            WHERE CA.CA_ID_CLIENT = CL.CL_ID
                                                AND CA.CA_ID_TYPE = 1
                                            FOR XML RAW('АдрРФ'), TYPE, ROOT('Адрес')
                                        ),
                                        (
                                            SELECT
                                                [Тлф]       = NullIf(CL.CL_PHONE, ''),
                                                [ЭлПочта]   = NullIf(CL.CL_EMAIL, '')
                                            FOR XML RAW('Контакт'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [Id] = NULL
                                            FOR XML RAW('СвБанк'), TYPE, ROOT('БанкРекв')
                                        )
                                    FROM dbo.ClientTable AS CL
                                    WHERE CL.CL_ID = I.INS_ID_CLIENT
                                    FOR XML RAW ('СвПокуп'), TYPE
                                ),
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
                                )
                            FOR XML RAW('СвСчФакт'), TYPE
                        ),
                        (
                            SELECT
                                (
                                    SELECT
                                        [НомСтр]        = Row_Number() OVER(ORDER BY D.SYS_ORDER, D.DIS_NUM),
                                        --[НаимТов]       = ED.[ProductName],
                                        [НаимТов]       = R.INR_GOOD + ' ' + R.INR_NAME,
                                        [ОКЕИ_Тов]      = ED.[ProductOKEICode],
                                        [КолТов]        = 1,
                                        -- ToDo хардкод 20%
                                        [ЦенаТов]       = CASE WHEN P.[Price] LIKE '%.' THEN P.[Price] + '00' ELSE P.[Price] END,
                                        [СтТовБезНДС]   = dbo.MoneyFormatCustom(R.INR_SUM * IsNull(R.INR_COUNT, 1), '.'),
                                        [НалСт]         = '20%',
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
                                                [НаимЕдИзм]     = ED.[ProductOKEIFullName],
                                                [КрНаимСтрПр]   = 'Российская Федерация',
                                                [КодТов]        = ED.[ProductOKPD2Code]
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
                                    ORDER BY D.SYS_ORDER, D.DIS_NUM FOR XML RAW('СведТов'), TYPE
                                ),
                                (
                                    SELECT
                                        [СтТовБезНДСВсего]  = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                        [СтТовУчНалВсего]   = dbo.MoneyFormatCustom(Sum(R.INR_SALL), '.'),
                                        (
                                            SELECT
                                                [СумНал] = dbo.MoneyFormatCustom(Sum(R.INR_SNDS), '.')
                                            FOR XML PATH('СумНалВсего'), TYPE
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
                                        [СодОпер]   = 'Услуги оказаны в полном объеме',
                                        --ToDo оказание информационных услуг?
                                        [ВидОпер]   = 'Оказание информационных услуг за ' + DateName(MONTH, ACT_DATE) + ' ' + Cast(DatePart(Year, ACT_DATE) AS VarChar(100)) + ' г.',
                                        [ДатаПер]   = Convert(VarChar(20), ACT_DATE, 104),
                                        --[ДатаПер]   = Convert(VarChar(20), GetDate(), 104),
                                        [ДатаНач]   = Convert(VarChar(20), PR_DATE, 104),
                                        [ДатаОкон]  = Convert(VarChar(20), PR_END_DATE, 104),
                                        (
                                            SELECT
                                                [НаимОсн]   = 'Без документа-основания'
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
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            OUTER APPLY [dbo].[EISData@Parse](F.EIS_DATA, @ActDate) AS ED
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('Файл'), TYPE
        );

        SET @ApplyContent =
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
                        [ИдЭтапКонт]    = F.EIS_DATA.value('(/export/contract/finances/budgetFunds/stages/guid)[1]', 'VarChar(100)')
                    FOR XML RAW('СведКонт'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                [ФирмНаимОрг] = O.[ORG_SHORT_NAME]
                            FOR XML RAW('ЮЛ'), TYPE
                        )
                    FOR XML RAW('СведПоставщик'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                (
                                    SELECT
                                        (
                                            SELECT
                                                [ИдТРУ]         = ED.[Product_GUId],
                                                [КодТов]        = ED.[ProductOKPD2Code],
                                                [НаимТов]       = ED.[ProductName],
                                                --[НаимТов]       = Max(INR_GOOD),
                                                [КодЕдИзм]      = ED.[ProductOKEICode],
                                                [НаимЕдИзм]     = ED.[ProductOKEIFullName],
                                                [ЦенаЕдИзм]     = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                                [КолТов]        = 1,
                                                [ПрТовРаб]      = 3,
                                                [СтТовБезНДС]   = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                                [НалСт]         = '20%',
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
                                                )/*,
                                                (
                                                    SELECT
                                                        [Код]   = '643',
                                                        [Наим]  = 'Российская Федерация'
                                                    FOR XML RAW('СтранаПроисх'), TYPE
                                                )*/
                                            FROM dbo.InvoiceRowTable AS R
                                            WHERE R.INR_ID_INVOICE = I.INS_ID
                                            FOR XML RAW('СведРод'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [НомСтр]        = Row_Number() OVER(ORDER BY D.SYS_ORDER, D.DIS_NUM),
                                                --[ИдТРУ]     = F.EIS_DATA.value('(/export/contract/products/product/guid)[1]', 'VarChar(100)'),
                                                [ИдТРУ]         = Replace(Cast(NewId() AS VarChar(100)), '-', ''),
                                                [ЦенаСНДС]      = dbo.MoneyFormatCustom(R.INR_SALL, '.'),
                                                [ПрУлучшХаракт] = 1
                                                /*,
                                                (
                                                    SELECT
                                                        [Код]   = '643',
                                                        [Наим]  = 'Российская Федерация'
                                                    FOR XML RAW('СтранаПроисх'), TYPE
                                                )
                                                */
                                            FROM dbo.InvoiceRowTable AS R
                                            INNER JOIN dbo.DistrView AS D WITH(NOEXPAND) ON R.INR_ID_DISTR = D.DIS_ID
                                            WHERE R.INR_ID_INVOICE = I.INS_ID
                                            FOR XML RAW('СведДетал'), TYPE
                                        )
                                    FOR XML RAW('ДеталТРУ'), TYPE
                                )
                            FOR XML RAW('СведТРУ'), TYPE
                        )
                    FOR XML RAW('СведТов'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                [Место] = IsNull(ST_PREFIX + ' ' + ST_NAME + ', ' + CA_HOME, CA_FREE),
                                (
                                    SELECT
                                        (
                                            SELECT
                                                [Код]   = '25000001000',
                                                [Наим]  = CT_NAME,
                                                [Адрес] = 'Российская Федерация, ' + RG_NAME + ', ' + CT_NAME + ' ' + CT_PREFIX
                                            FOR XML RAW('КЛАДР'), TYPE
                                        )
                                    FOR XML RAW('ПоКЛАДР'), TYPE
                                )
                                /*
                                (
                                    SELECT
                                        [Код]   = '05701000001',
                                        [Наим]  = 'Владивосток г',
                                        [Адрес] = '690002, КРАЙ ПРИМОРСКИЙ 25, Г ВЛАДИВОСТОК, ПР-КТ ОСТРЯКОВА, ДОМ 8'
                                    FOR XML RAW('ПоОКТМО'), TYPE
                                )
                                */
                            FROM dbo.ClientAddressView AS CA
                            WHERE CA.CA_ID_CLIENT = A.ACT_ID_CLIENT
                                AND CA.CA_ID_TYPE = 1
                            FOR XML RAW('СведМестоПоставки'), TYPE

                        )
                    FOR XML RAW('СведМестаПоставки'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            OUTER APPLY [dbo].[EISData@Parse](F.EIS_DATA, @ActDate) AS ED
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('ФайлУПДПрод'), TYPE
        );

        /*
        SET @ApplyContent =
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
                        [ИдЭтапКонт]    = F.EIS_DATA.value('(/export/contract/finances/budgetFunds/stages/guid)[1]', 'VarChar(100)')
                    FOR XML RAW('СведКонт'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                (
                                    SELECT
                                        [ИдТРУ]         = F.EIS_DATA.value('(/export/contract/products/product/guid)[1]', 'VarChar(100)'),
                                        [ТехИдТРУ]      = F.EIS_DATA.value('(/export/contract/products/product/sid)[1]', 'VarChar(100)'),
                                        [НаимТовИсх]    = F.EIS_DATA.value('(/export/contract/products/product/name)[1]', 'VarChar(100)'),
                                        (
                                            SELECT
                                                [НомСтр]            = '1',
                                                [ЦенаИзКонтСНДС]    = dbo.MoneyFormatCustom(Sum(R.[INR_SALL]), '.'),
                                                (
                                                    SELECT
                                                        [Код]   = '643',
                                                        [Наим]  = 'РОССИЯ'
                                                    FOR XML RAW('СтранаПроисх'), TYPE
                                                )
                                            FOR XML RAW('НеЛПСвед'), TYPE
                                        )
                                    FROM dbo.InvoiceRowTable      AS R
                                    WHERE I.INS_ID = INR_ID_INVOICE
                                    FOR XML RAW('НедеталТРУ'), TYPE
                                )
                            FOR XML RAW('СведТРУ'), TYPE
                        )
                    FOR XML RAW('СведТов'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('ФайлУПДПрод'), TYPE
        );
        */

        SET @MainBase64 = (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @MainContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64);
        SET @ApplyBase64 = (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @ApplyContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64);

        SET @Data =
        (
            SELECT
                [ИдТрПакет]     = Cast(NewId() AS VarChar(100)),
                [ИдФайл]        = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [ВерсФорм]      = '1.01',
                [ТипПрилож]     = 'УПДПрод',
                [ИдОтпр]        = O.[EIS_CODE],
                [ИдПол]         = F.[EIS_CODE],
                [ДатаВрФормир]  = GetDate(),
                (
                    SELECT
                        [Контент] = @MainBase64
                    FOR XML PATH('Документ'), TYPE
                ),
                (
                    SELECT
                        [Контент] = @ApplyBase64
                    FOR XML PATH('Прилож'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('ФайлПакет'), TYPE
        );

        SELECT
            [Folder]        = RTrim(Ltrim(C.CL_PSEDO)),
            [FileName]      = IsNull(F.[FileName], Cast(NewId() AS VarChar(50))), -- ToDo костыль
            [Data]          = F.[Data]
        FROM dbo.ActTable           AS A
        INNER JOIN dbo.ClientTable  AS C ON A.ACT_ID_CLIENT = C.CL_ID
        CROSS APPLY
        (
            SELECT
                [FileName]  = 'УПД_' + C.CL_PSEDO + '_' + Convert(VarChar(50), ACT_DATE, 112) + '_' + @File_Id + '.xml',
                [Data]      = Cast(@Data AS VarChar(Max))
            ---
            UNION ALL
            ---
            SELECT
                [FileName]  = @MainContent.value('(/Файл/@ИдФайл)[1]', 'VarChar(256)') + '.xml',
                [Data]      = Cast(@MainContent AS VarChar(Max))
            ---
            UNION ALL
            ---
            SELECT
                [FileName]  = @ApplyContent.value('(/ФайлУПДПрод/@ИдПрилож)[1]', 'VarChar(256)') + '.xml',
                [Data]      = Cast(@ApplyContent AS VarChar(Max))
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
GRANT EXECUTE ON [dbo].[ACT_PRINT?UPD] TO rl_act_p;
GO
