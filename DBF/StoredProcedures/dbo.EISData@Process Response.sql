USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EISData@Process Response]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EISData@Process Response]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EISData@Process Response]
    @InData     NVarChar(Max)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Xml            Xml,
        @X              NVarChar(Max),
        @Xml_S          NVarChar(Max),
        @Inn            VarChar(100),
        @Name           VarChar(256),
		@ContractNumber	VarChar(256),
        @Expected_Id    Int;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        /*
        SET @Xml_S = Replace(
                        Cast(@InData AS NVarChar(Max)),
                        --'xmlns="http://zakupki.gov.ru/eruz/types/1" xmlns:ns5="http://zakupki.gov.ru/eruz/SMTypes/1" xmlns:ns2="http://zakupki.gov.ru/eruz/common/1" xmlns:ns4="http://zakupki.gov.ru/eruz/nsi/1" xmlns:ns3="http://zakupki.gov.ru/oos/export/1"'
                        'xmlns="http://zakupki.gov.ru/oos/types/1" xmlns:ns6="http://zakupki.gov.ru/oos/CPtypes/1" xmlns:ns5="http://zakupki.gov.ru/oos/TPtypes/1" xmlns:ns8="http://zakupki.gov.ru/oos/EPtypes/1" xmlns:ns7="http://zakupki.gov.ru/oos/pprf615types/1" xmlns:ns9="http://zakupki.gov.ru/oos/SMTypes/1" xmlns:ns11="http://zakupki.gov.ru/oos/control99/1" xmlns:ns10="http://zakupki.gov.ru/oos/printform/1" xmlns:ns2="http://zakupki.gov.ru/oos/export/1" xmlns:ns4="http://zakupki.gov.ru/oos/base/1" xmlns:ns3="http://zakupki.gov.ru/oos/common/1"'
                    , '');

        SET @Xml_S = Replace(@Xml_S, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', '');
        */
        SET @Xml_S = Cast(@InData AS NVarChar(Max));
        SET @Xml_S = Replace(@Xml_S, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', '');
        SET @X = SubString(@Xml_S, CharIndex('<', @Xml_S), CharIndex('>', @Xml_S));

        SET @Xml_S = Replace(@Xml_S, @X, '<export>');

        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns2:', '<'), '</ns2:', '</');
        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns3:', '<'), '</ns3:', '</');
        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns4:', '<'), '</ns4:', '</');
        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns5:', '<'), '</ns5:', '</');

        SET @Xml = Cast(@Xml_S AS Xml);

        --SELECT @Xml

        SELECT
            @Inn   = @Xml.value('(/export/contract/customer/inn)[1]', 'VarChar(100)'),
            @Name  = @Xml.value('(/export/contract/customer/fullName)[1]', 'VarChar(512)'),
			@ContractNumber = @Xml.value('(/export/contract/number)[1]', 'VarChar(512)');

        IF @Inn IS NOT NULL
            SELECT
                @Expected_Id = L.[Client_Id]
            FROM
            (
                SELECT [NULL] = NULL
            ) AS N
            OUTER APPLY
            (
                SELECT [ClientCountByInn] = Count(*)
                FROM dbo.ClientTable
                WHERE CL_INN = @INN
            ) AS I
            OUTER APPLY
            (
                SELECT TOP(1) [Client_Id] = [CL_ID]
                FROM dbo.ClientTable AS L
				INNER JOIN dbo.ContractTable AS C ON CO_ID_CLIENT = CL_ID
                WHERE L.[CL_INN] = @Inn
					AND C.CO_NUM = @ContractNumber
                    --AND I.[ClientCountByInn] = 1
            ) AS L;

        SELECT
            [Inn]           = @Inn,
            [Name]          = @Name,
            [Expected_Id]   = @Expected_Id,
            [ResponseText]  = Cast(@Xml AS NVarChar(Max));

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EISData@Process Response] TO rl_distr_financing_w;
GO
