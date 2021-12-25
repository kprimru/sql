USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DBFClientView]
AS
    SELECT
        [Client_Id]         = CL_ID,
        [ClientFullName]    = CL_FULL_NAME,
        [ClientShortName]   = CL_SHORT_NAME,
        [ClientINN]         = CL_INN,
        [ClientCalc]        = CL_ACCOUNT,
        [ClientBank]        = B.BA_NAME + ' ' + BCT.CT_PREFIX + BCT.CT_NAME,
        [ClientBik]         = B.BA_BIK,
        [ClientAddress]     = A.[ADDR_STRING],
        [ClientUAddress]    = UA.[ADDR_STRING]
    FROM [PC275-SQL\DELTA].[DBF].[dbo].[ClientTable]    AS C
    LEFT JOIN [PC275-SQL\DELTA].[DBF].[dbo].[BankTable] AS B    ON B.BA_ID = C.CL_ID_BANK
    LEFT JOIN [PC275-SQL\DELTA].[DBF].[dbo].[CityTable] AS BCT  ON BCT.CT_ID = B.BA_ID_CITY
    OUTER APPLY
    (
        SELECT A.ADDR_STRING
        FROM [PC275-SQL\DELTA].[DBF].[dbo].[ClientFinancingAddressView] AS A
        WHERE A.CL_ID = C.CL_ID
            AND A.FAT_NOTE = 'Адрес плательщика в счете'
            AND A.CA_ID_TYPE = 1
    ) AS UA
    OUTER APPLY
    (
        SELECT A.ADDR_STRING
        FROM [PC275-SQL\DELTA].[DBF].[dbo].[ClientFinancingAddressView] AS A
        WHERE A.CL_ID = C.CL_ID
            AND A.FAT_NOTE = 'Адрес грузополучателя в счет-фактуре на накладную'
            AND A.CA_ID_TYPE = 2
    ) AS A;
GO
