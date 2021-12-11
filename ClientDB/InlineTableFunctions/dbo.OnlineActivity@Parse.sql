USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[OnlineActivity@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[OnlineActivity@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [dbo].[OnlineActivity@Parse]
(
    @Data Xml
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        [Year]          = V.[Year],
        [Week]          = V.[Week],
        [Week_Id]       = W.[Week_Id],
        [Login]         = [Login],
        [Activity]      = A.[Activity],
        [LoginCnt]      = V.[LoginCnt],
        [SessionTime]   = V.[SessionTime],
        [Host_Id]       = D.[Host_Id],
        [Distr]         = D.[Distr],
        [Comp]          = D.[Comp],
        [Email]         = V.[Email],
        [FIO]           = V.[FIO]
    FROM @Data.nodes('/ROOT/ITEM') AS n(v)
    CROSS APPLY
    (
        SELECT
            [Year]          = v.value('@Year[1]',         'Int'),
            [Week]          = v.value('@Week[1]',         'Int'),
            [Login]         = v.value('@Login[1]',        'VarChar(256)'),
            [Activity]      = v.value('@Activity[1]',     'Bit'),
            [LoginCnt]      = v.value('@LoginCnt[1]',     'SmallInt'),
            [SessionTime]   = v.value('@SessionTime[1]',  'SmallInt'),
            [Email]         = v.value('@Email[1]',        'VarChar(256)'),
            [FIO]           = v.value('@FIO[1]',          'VarChar(256)')
    ) AS V
    OUTER APPLY
    (
        SELECT
            [Activity] =
                Cast(
                    CASE
                        WHEN V.[LoginCnt] > 0 THEN 1
                        WHEN V.[LoginCnt] = 0 THEN 0
                        ELSE V.[Activity]
                    END AS Bit)
    ) AS A
    OUTER APPLY
    (
        SELECT
            [Host_Id]   = D.[Host_Id],
            [Distr]     = D.[Distr],
            [Comp]      = D.[Comp]
        FROM [dbo].[OnlineActivity@Parse?Login](V.[Login]) AS D
    ) AS D
    OUTER APPLY
    (
        SELECT [Week_Id] = [ID]
        FROM [Common].[Period] AS P
        WHERE   P.[TYPE] = 1
            AND DatePart(Year, P.[FINISH]) = V.[Year]
            AND dbo.ISO_WEEK(P.[START]) = V.[Week]
    ) AS W1
    OUTER APPLY
    (
        SELECT [Week_Id] = [ID]
        FROM [Common].[Period] AS P
        WHERE   P.[TYPE] = 1
            AND DatePart(Year, P.[START]) = V.[Year]
            AND dbo.ISO_WEEK(P.[START]) = V.[Week]
    ) AS W2
    OUTER APPLY
    (
        SELECT [Week_Id] = IsNull(W1.[Week_Id], W2.[Week_Id])
    ) AS W
    WHERE [Distr] IS NOT NULL
)GO
