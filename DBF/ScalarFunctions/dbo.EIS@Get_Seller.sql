USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Get?Seller]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[EIS@Get?Seller] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[EIS@Get?Seller]
(
	@Org_Id	SmallInt
)
RETURNS XML
AS
BEGIN
	RETURN
		(
			SELECT
                [КраткНазв] = O.[ORG_SHORT_NAME],
                (
                    SELECT
                        [НаимОрг]   = O.[ORG_FULL_NAME],
                        [ИННЮЛ]     = O.[ORG_INN],
                        [КПП]       = O.[ORG_KPP]
                    FOR XML RAW('СвЮЛУч'), TYPE, ROOT('ИдСв')
                ),
                (
                    SELECT
                        [Индекс]    = O.[ORG_INDEX],
                        [КодРегион] = C.[CT_REGION],
                        [Город]     = C.[CT_NAME],
                        [Улица]     = S.[ST_NAME],
                        [Дом]       = O.[ORG_HOME]
                    FROM [dbo].[StreetTable]		AS S
                    INNER JOIN [dbo].[CityTable]	AS C ON C.[CT_ID] = S.[ST_ID_CITY]
                    WHERE S.[ST_ID] = O.[ORG_ID_STREET]
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
                        [НомерСчета] = O.[ORG_ACCOUNT],
                        (
                            SELECT
                                [НаимБанк]  = BA.[BA_NAME],
                                [БИК]       = O.[ORG_BIK],
                                [КорСчет]   = O.[ORG_LORO]
                            FROM [dbo].[BankTable] AS BA
                            WHERE BA.[BA_ID] = O.[ORG_ID_BANK]
                            FOR XML RAW('СвБанк'), TYPE
                        )
                    FOR XML RAW('БанкРекв'), TYPE
                )
			FROM [dbo].[OrganizationTable] AS O
			WHERE O.[ORG_ID] = @Org_Id
            FOR XML RAW ('СвПрод'), TYPE
		)
END
GO
