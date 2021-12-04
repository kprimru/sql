USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[EISData@Parse]
(
    @Data       Xml,
    @ActDate    SmallDateTime,
    @ActPrice   Money
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        --[Contract_Id] = C.value('(./id)[1]', 'Int'),
        --[PublishDate] = C.value('(./publishDate)[1]', 'VarChar(100)'),
        --S.*,
        PP.[ProductName],
        PP.[Product_GUId],
        PP.[ProductOKPD2Code],
        PP.[ProductOKEICode],
        PP.[ProductOKEIFullName],
        R.[RegNum],
        R.[Number]

    FROM @Data.nodes('(/export/contract)') AS E(C)
    OUTER APPLY
    (
        SELECT
            [RegNum]    = C.value('(./regNum)[1]', 'VarChar(100)'),
            [Number]    = C.value('(./number)[1]', 'VarChar(100)')

    ) AS R
    OUTER APPLY
    (
        SELECT
            [ExecutionPeriods]  = C.query('executionPeriod')
    ) AS EP
    OUTER APPLY
    (
        SELECT TOP (1) [StagePrice]
        FROM
        (
            SELECT
                [Data]          = S.query('.'),
                [StartDate]     = Convert(SmallDateTime, S.value('(./startDate)[1]', 'VarChar(100)'), 120),
                [FinishDate]    = Convert(SmallDateTime, S.value('(./endDate)[1]', 'VarChar(100)'), 120),
                [StagePrice]    = S.value('(./stagePrice)[1]', 'VarChar(100)')
            FROM EP.[ExecutionPeriods].nodes('*/stages') AS E(S)
        ) AS SS
        WHERE @ActDate BETWEEN SS.[StartDate] AND SS.[FinishDate]
    ) AS S
    OUTER APPLY
    (
        SELECT
            [Products]  = C.query('products')
    ) AS P
    OUTER APPLY
    (
        SELECT TOP (1)
            [ProductName],
            [Product_GUId],
            [ProductOKPD2Code],
            [ProductOKEICode],
            [ProductOKEIFullName]
        FROM
        (
            SELECT
                [Row_Number]        = Row_Number() Over(ORDER BY (SELECT 0)),
                [Product_GUId]      = V.value('(./guid)[1]', 'VarChar(100)'),
                [ProductOKPD2Code]  = V.value('(./OKPD2/code)[1]', 'VarChar(100)'),
                [ProductOKEICode]  = V.value('(./OKEI/code)[1]', 'VarChar(100)'),
                [ProductOKEIFullName]  = V.value('(./OKEI/fullName)[1]', 'VarChar(Max)'),
                [ProductName]       = V.value('(./name)[1]', 'VarChar(Max)'),
                [ProductSum]        = V.value('(./sum)[1]', 'VarChar(100)'),
                [ProductPrice]       = V.value('(./price)[1]', 'VarChar(100)')
            FROM P.[Products].nodes('/products/product') AS PR(V)
        ) AS PP
        --WHERE PP.[ProductPrice] = S.[StagePrice]
        ORDER BY CASE WHEN PP.[ProductPrice] = @ActPrice THEN 1 ELSE 2 END, CASE WHEN PP.[ProductSum] = S.[StagePrice] THEN 1 ELSE 2 END, [Row_Number] DESC
    ) AS PP
)
GO
