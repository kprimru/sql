USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[EIS@Get?Buyer]
(
	@Client_Id		Int,
	@IdentGUId      VarChar(100)
)
RETURNS XML
AS
BEGIN
	RETURN
		(
			SELECT
                [ОКПО]          = CL.[CL_OKPO],
                [КраткНазв]     = F.[EIS_DATA].value('(/export/contract/customer/shortName)[1]', 'VarChar(512)'),
                [ИнфДляУчаст]   = @IdentGUId,
                (
                    SELECT
                        [НаимОрг]   = F.[EIS_DATA].value('(/export/contract/customer/fullName)[1]', 'VarChar(512)'),
                        [ИННЮЛ]     = CL.[CL_INN],
                        [КПП]       = CL.[CL_KPP]
                    FOR XML RAW('СвЮЛУч'), TYPE, ROOT('ИдСв')
                ),
                (
                    SELECT
                        [Индекс]    = CA.[CA_INDEX],
                        [КодРегион] = CA.[CT_REGION],
                        [Район]     = CA.[AR_NAME],
                        [Город]     = CA.[CT_NAME],
                        [Улица]     = CA.[ST_NAME],
                        [Дом]       = CA.[CA_HOME]
                    FROM [dbo].[ClientAddressView] AS CA
                    WHERE	CA.[CA_ID_CLIENT] = @Client_Id
                        AND CA.[CA_ID_TYPE] = 1
                    FOR XML RAW('АдрРФ'), TYPE, ROOT('Адрес')
                ),
                (
                    SELECT
                        [Тлф]       = NullIf(CL.[CL_PHONE], ''),
                        [ЭлПочта]   = NullIf(CL.[CL_EMAIL], '')
                    FOR XML RAW('Контакт'), TYPE
                ),
				(
					SELECT
                        [НомерСчета] = CL.[CL_ACCOUNT],
                        (
                            SELECT
                                [НаимБанк]  = BA.[BA_NAME],
                                [БИК]       = BA.[BA_BIK],
                                [КорСчет]   = IsNull(NullIf(BA.[BA_LORO], ''), '00000000000000000000')
                            FROM [dbo].[BankTable] AS BA
                            WHERE BA.[BA_ID] = CL.[CL_ID_BANK]
                            FOR XML RAW('СвБанк'), TYPE
                        )
                    FOR XML RAW('БанкРекв'), TYPE
				)
            FROM [dbo].[ClientTable]			AS CL
			INNER JOIN [dbo].[ClientFinancing]	AS F ON F.[ID_CLIENT] = @Client_Id
            WHERE CL.[CL_ID] = @Client_Id
            FOR XML RAW ('СвПокуп'), TYPE
		)
END
GO
