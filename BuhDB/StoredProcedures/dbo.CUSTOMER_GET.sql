USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CUSTOMER_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CUSTOMER_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CUSTOMER_GET]
	@ID     Int,
	@DISTR  VARCHAR(100)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @Client_Id      Int;

    IF @DISTR IS NULL
        SELECT
            [CustomerName]      = C.[CustomerName],
            [CustomerINN]       = C.[CustomerINN],
            [CustomerBIK]       = C.[CustomerBIK],
            [CustomerURAdress]  = C.[CustomerURAdress],
            [Recieve]           = C.[Recieve],
            [RecieveAdress]     = C.[RecieveAdress],
            [CustomerCalc]      = C.[CustomerCalc],
            [CustomerPurchaser] = C.[CustomerPurchaser],
            [CustomerAddress]   = CT.CityPrefix + ' ' + CT.CityName + ', ' + S.StreetPrefix + ' ' + S.StreetName + ', ' + C.CustomerHome + ', тел. ' + C.CustomerPhone,
            [CustomerBank]      = B.BankName + '   ' + CB.CityPrefix + ' ' + CB.CityName
        FROM dbo.CustomerTable AS C
        LEFT JOIN dbo.StreetTable AS S ON S.StreetID = C.StreetID
        LEFT JOIN dbo.CityTable AS CT ON CT.CityID = S.CityID
        LEFT JOIN dbo.BankTable AS B ON B.BankID = C.BankID
        LEFT JOIN dbo.CityTable AS CB ON CB.CityID = B.CityID
        WHERE CustomerID = @ID
    ELSE BEGIN
        SET @Client_Id =
            (
                SELECT TOP (1)
                    D.[Client_Id]
                FROM dbo.DBFDistrView AS D
                WHERE D.[Distr] = @DISTR
                ORDER BY D.[SystemOrder], D.[Comp]
            );

        IF @Client_Id IS NULL BEGIN
            EXEC [dbo].[CUSTOMER_GET]
                @ID         = @ID,
                @DISTR      = NULL;

            RETURN;
        END;

        SELECT
            [CustomerName]      = C.[ClientFullName],
            [CustomerINN]       = C.[ClientINN],
            [CustomerBIK]       = C.[ClientBik],
            [CustomerURAdress]  = C.[ClientUAddress],
            [Recieve]           = C.[ClientFullName],
            [RecieveAdress]     = C.[ClientAddress],
            [CustomerCalc]      = C.[ClientCalc],
            [CustomerPurchaser] = C.[ClientFullName],
            [CustomerAddress]   = C.[ClientAddress],
            [CustomerBank]      = C.[ClientBank]
        FROM
        (
            SELECT TOP (1)
                D.[Client_Id]
            FROM dbo.DBFDistrView AS D
            WHERE D.[Distr] = @DISTR
            ORDER BY D.[SystemOrder], D.[Comp]
        ) AS D
        CROSS APPLY
        (
            SELECT
                [Client_Id],
                [ClientFullName],
                [ClientShortName],
                [ClientINN],
                [ClientCalc],
                [ClientBank],
                [ClientBik],
                [ClientAddress],
                [ClientUAddress]
            FROM dbo.DBFClientView AS C
            WHERE C.[Client_Id] = D.[Client_Id]
        ) AS C
    END;
END
GO
GRANT EXECUTE ON [dbo].[CUSTOMER_GET] TO DBCount;
GO
