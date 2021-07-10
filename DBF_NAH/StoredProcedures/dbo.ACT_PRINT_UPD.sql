USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD]
    @Act_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @Data Xml;

    --EXEC [Debug].[Execution@Start]
      --  @Proc_Id        = @@ProcId,
        --@Params         = @Params,
        --@DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @Data =
        (
            SELECT
                [КНД]               = '1115131',
                [Функция]           = 'ДОП',
                [ПоФактХЖ]          = 'Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
                [НаимДокОпр]        = 'Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)',
                [НаимЭконСубСост]   = O.ORG_FULL_NAME,
                [СоглСтрДопИнф]     = '0000.0000.0000',
                (
                    SELECT
                        [НомерСчФ]  = I.INS_NUM,
                        [ДатаСчФ]   = I.INS_DATE,
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
                                        [Id] = NULL
                                    FOR XML RAW('СвБанк'), TYPE, ROOT('БанкРекв')
                                )
                            FOR XML RAW ('СвПрод'), TYPE
                        ),
                        (
                            SELECT
                                [ОКПО]      = CL.CL_OKPO,
                                [КраткНазв] = CL.CL_SHORT_NAME,
                                (
                                    SELECT
                                        [НаимОрг]   = CL.CL_FULL_NAME,
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
                                        [ДатаГосКонт]   = CO_DATE,
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
                                [НомСтр]        = Row_Number() OVER(ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM),
                                [НаимТов]       = R.INR_GOOD + ' ' + R.INR_NAME,
                                [ОКЕИ_Тов]      = S.SO_OKEI,
                                [КолТов]        = IsNull(R.INR_COUNT, 1),
                                [ЦенаТов]       = R.INR_SUM,
                                [СтТовБезНДС]   = R.INR_SUM * IsNull(R.INR_COUNT, 1),
                                [НалСт]         = Cast(Cast(T.TX_PERCENT AS Int) AS VarChar(10)) + ' %',
                                [СтТовУчНал]    = R.INR_SALL,
                                (
                                    SELECT
                                        [БезАкциз] = 'без акциза'
                                    FOR XML PATH('Акциз'), TYPE
                                ),
                                (
                                    SELECT
                                        [СумНал] = R.INR_SNDS
                                    FOR XML PATH('СумНал'), TYPE
                                )
                            FROM dbo.InvoiceRowTable AS R
                            INNER JOIN dbo.DistrView AS D WITH(NOEXPAND) ON R.INR_ID_DISTR = D.DIS_ID
                            INNER JOIN dbo.SaleObjectTable AS S ON S.SO_ID = D.SYS_ID_SO
                            INNER JOIN dbo.TaxTable AS T ON T.TX_ID = R.INR_ID_TAX
                            WHERE R.INR_ID_INVOICE = I.INS_ID
                            FOR XML RAW('СведТов'), TYPE
                        ),
                        (
                            SELECT
                                [СтТовБезНДСВсего]  = Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)),
                                [СтТовУчНалВсего]   = Sum(R.INR_SALL),
                                (
                                    SELECT
                                        [СумНал] = Sum(R.INR_SNDS)
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
                                [ДатаПер]   = ACT_DATE,
                                [ДатаНач]   = PR_DATE,
                                [ДатаОкон]  = PR_END_DATE,
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
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('Документ'), TYPE
        );

        SELECT @Data AS DATA;

        --EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        --SET @DebugError = Error_Message();

        --EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT?UPD] TO rl_act_p;
GO