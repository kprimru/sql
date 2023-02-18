USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EISData@Prepare]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EISData@Prepare]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EISData@Prepare]
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
        @RowIndex       Int,
        @Status         Int,
        @Url            VarChar(2048),
        @Customer_Id    VarChar(100),
        @Response       NVarChar(Max);

	-- ToDo избавить от таблицы. Сделать одним запросом
    DECLARE @Customers Table
    (
        [Row:Index]             Int             Identity(1,1)   NOT NULL,
        [Customer_Id]           VarChar(100)                    NOT NULL,
        [Contract_Id]           VarChar(100)                    NOT NULL,
        [RegNum]                VarChar(100)                    NOT NULL,
        [Url]                   VarChar(2048)                       NULL,
        [ResponseStatus]        Int                                 NULL,
        [ResponseData]          NVarChar(Max)                       NULL,
        [CustomerData]          NVarChar(Max)                       NULL,
        [Client_Id]             Int                                 NULL,
        [Inn]                   VarChar(100)                        NULL,
        [Name]                  VarChar(512)                        NULL,
        [ExpectedClient_Id]     Int                                 NULL,
        PRIMARY KEY CLUSTERED([Row:Index])
    );

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @Xml_S = Cast(@InData AS NVarChar(Max));
        SET @Xml_S = Replace(@Xml_S, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', '');
        SET @X = SubString(@Xml_S, CharIndex('<', @Xml_S), CharIndex('>', @Xml_S));

        SET @Xml_S = Replace(@Xml_S, @X, '<export>');

        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS NVarChar(Max)), '<ns2:', '<'), '</ns2:', '</');
        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS NVarChar(Max)), '<ns3:', '<'), '</ns3:', '</');
        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS NVarChar(Max)), '<ns4:', '<'), '</ns4:', '</');
        SET @Xml_S = Replace(Replace(Cast(@Xml_S AS NVarChar(Max)), '<ns5:', '<'), '</ns5:', '</');

        SET @Xml = Cast(@Xml_S AS Xml);

        INSERT INTO @Customers ([Customer_Id], [Url], [Contract_Id], [RegNum])
        SELECT
            [Customer_Id] = c.value('(./EDOAddInfo/customerID)[1]', 'VarChar(100)'),
            [Url] = c.value('(./url)[1]', 'VarChar(2048)'),
            [Id] = c.value('(./id)[1]', 'VarChar(50)'),
            [RegNum] = c.value('(./regNum)[1]', 'VarChar(100)')
        FROM @Xml.nodes('/export/EDOInfo/contractEDOAddInfoList/contractEDOAddInfo') a(c);

        UPDATE C SET
            [Client_Id] = F.ID_CLIENT,
            [CustomerData] = Cast(E.[Data] AS NVarChar(Max))
        FROM @Customers AS C
        CROSS APPLY
        (
            SELECT TOP (1) CF.ID_CLIENT
            FROM dbo.ClientFinancing AS CF
            WHERE EIS_CODE = [Customer_Id]
        ) AS F
        OUTER APPLY
        (
            SELECT TOP (1) E.Data
            FROM dbo.ClientFinancingEIS AS E
            WHERE E.Client_Id = F.ID_CLIENT
            ORDER BY E.[Date] DESC
        ) AS E;

        -- ToDo почему-то постоянно возвращается 404
        /*
        SET @RowIndex = 0;

        WHILE (1 = 1) BEGIN
            SELECT TOP (1)
                @RowIndex   = C.[Row:Index],
                @Url        = C.[Url]
            FROM @Customers AS C
            WHERE C.[Row:Index] > @RowIndex
                AND C.[Url] IS NOT NULL
                AND C.[Client_Id] IS NOT NULL
            ORDER BY
                C.[Row:Index];

            IF @@RowCount < 1
                BREAK;

            --WAITFOR DELAY '00:00:01';

            EXEC [Common].[Http@Get?Data]
                @Url        = @Url,
                @Status     = @Status OUT,
                @Response   = @Response OUT;

            UPDATE @Customers SET
                [ResponseStatus]    = @Status,
                [ResponseData]      = @Response
            WHERE [Row:Index] = @RowIndex;

            IF @Status = 200 BEGIN
                SET @Xml_S = Replace(
                                Cast(@Response AS VarChar(Max)),
                                --'xmlns="http://zakupki.gov.ru/eruz/types/1" xmlns:ns5="http://zakupki.gov.ru/eruz/SMTypes/1" xmlns:ns2="http://zakupki.gov.ru/eruz/common/1" xmlns:ns4="http://zakupki.gov.ru/eruz/nsi/1" xmlns:ns3="http://zakupki.gov.ru/oos/export/1"'
                                'xmlns="http://zakupki.gov.ru/oos/types/1" xmlns:ns6="http://zakupki.gov.ru/oos/CPtypes/1" xmlns:ns5="http://zakupki.gov.ru/oos/TPtypes/1" xmlns:ns8="http://zakupki.gov.ru/oos/EPtypes/1" xmlns:ns7="http://zakupki.gov.ru/oos/pprf615types/1" xmlns:ns9="http://zakupki.gov.ru/oos/SMTypes/1" xmlns:ns11="http://zakupki.gov.ru/oos/control99/1" xmlns:ns10="http://zakupki.gov.ru/oos/printform/1" xmlns:ns2="http://zakupki.gov.ru/oos/export/1" xmlns:ns4="http://zakupki.gov.ru/oos/base/1" xmlns:ns3="http://zakupki.gov.ru/oos/common/1"'
                            , '');

                SET @Xml_S = Replace(@Xml_S, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', '');

                SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns2:', '<'), '</ns2:', '</');
                SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns3:', '<'), '</ns3:', '</');
                SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns4:', '<'), '</ns4:', '</');
                SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns5:', '<'), '</ns5:', '</');

                SET @Xml = Cast(@Xml_S AS Xml);

                --SELECT @Xml

                UPDATE @Customers SET
                    [Inn]   = @Xml.value('(/export/contract/customer/inn)[1]', 'VarChar(100)'),
                    [Name]  = @Xml.value('(/export/contract/customer/fullName)[1]', 'VarChar(512)'),
                    [ResponseData]  = Cast(@Xml AS NVarChar(Max))
                WHERE [Row:Index] = @RowIndex;
            END;
        END;

        UPDATE C SET
            [ExpectedClient_Id] = L.[Client_Id]
        FROM @Customers AS C
        OUTER APPLY
        (
            SELECT [ClientCountByInn] = Count(*)
            FROM dbo.ClientTable
            WHERE CL_INN = C.[Inn]
        ) AS I
        OUTER APPLY
        (
            SELECT TOP(1) [Client_Id] = [CL_ID]
            FROM dbo.ClientTable AS L
            WHERE L.[CL_INN] = C.[Inn]
                AND I.[ClientCountByInn] = 1
        ) AS L
        WHERE C.[Client_Id] IS NULL
            AND C.[Inn] IS NOT NULL

        SELECT TOP (1) @Xml_S = [ResponseData], @Customer_Id = [Customer_Id]
        FROM @Customers
        WHERE [ResponseStatus] = 200;

        IF @@RowCount = 1 BEGIN
            SET @Xml_S =
                        Replace(
                            Cast(@Xml_S AS VarChar(Max)),
                            'xmlns="http://zakupki.gov.ru/eruz/types/1" xmlns:ns5="http://zakupki.gov.ru/eruz/SMTypes/1" xmlns:ns2="http://zakupki.gov.ru/eruz/common/1" xmlns:ns4="http://zakupki.gov.ru/eruz/nsi/1" xmlns:ns3="http://zakupki.gov.ru/oos/export/1"'
                            , '')

            SET @Xml_S = Replace(@Xml_S, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', '');

            SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns2:', '<'), '</ns2:', '</');
            SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns3:', '<'), '</ns3:', '</');
            SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns4:', '<'), '</ns4:', '</');
            SET @Xml_S = Replace(Replace(Cast(@Xml_S AS VarChar(Max)), '<ns5:', '<'), '</ns5:', '</');

            PRINT @Xml_S

            SET @Xml = Cast(@Xml_S AS Xml);

            SELECT @Xml, @Customer_Id
        END;
        */

        SELECT
            [Customer_Id]           = C.[Customer_Id],
            [Contract_Id]           = C.[Contract_Id],
            [RegNum]                = C.[RegNum],
            [Url]                   = C.[Url],
            [ResponseStatus]        = C.[ResponseStatus],
            [ResponseData]          = C.[ResponseData],
            [CustomerData]          = C.[CustomerData],
            [Client_Id]             = C.[Client_Id],
            [ClientPsedo]           = CL.[CL_PSEDO],
            [Inn]                   = C.[Inn],
            [Name]                  = C.[Name],
            [ExpectedClient_Id]     = C.[ExpectedClient_Id],
			[Client_IDs]			= Cast(C.[ExpectedClient_Id] AS VarChar(100)),
            [Checked]               = Cast(0 AS Bit)
        FROM @Customers AS C
        LEFT JOIN dbo.ClientTable AS CL ON C.Client_Id = CL.CL_ID;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EISData@Prepare] TO rl_distr_financing_w;
GO
