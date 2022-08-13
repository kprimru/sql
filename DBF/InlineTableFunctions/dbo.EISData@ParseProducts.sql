USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[EISData@ParseProducts]
(
    @Data			Xml,
    @Price			Money,
	@Name			VarChar(256)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        PP.[Product_GUId],
		PP.[ProductSid],
        PP.[ProductOKPD2Code],
        PP.[ProductOKEICode],
        PP.[ProductOKEIFullName]
    FROM @Data.nodes('(/export/contract)') AS E(C)
    OUTER APPLY
    (
        SELECT
            [Products]  = C.query('products')
    ) AS P
    OUTER APPLY
    (
        SELECT TOP (1)
            [Row_Number],
            [ProductName],
            [Product_GUId],
			[ProductSid],
            [ProductOKPD2Code],
            [ProductOKEICode],
            [ProductOKEIFullName]
        FROM
        (
            SELECT
                [Row_Number]        = Row_Number() Over(ORDER BY (SELECT 0)),
                [IsActualRow]       = CASE WHEN V.value('(./name)[1]', 'VarChar(Max)') LIKE '%Актуализ%' THEN 1 ELSE 0 END,
                [Product_GUId]      = V.value('(./guid)[1]', 'VarChar(100)'),
				[ProductSid]		= V.value('(./sid)[1]', 'VarChar(100)'),
                --[ProductOKPD2Code]  = V.value('(./OKPD2/code)[1]', 'VarChar(100)'),
				[ProductOKPD2Code]  = IsNull(V.value('(./OKPD2/code)[1]', 'VarChar(100)'), V.value('(./KTRU/code)[1]', 'VarChar(100)')),
                [ProductOKEICode]   = V.value('(./OKEI/code)[1]', 'VarChar(100)'),
                [ProductOKEIFullName]  = V.value('(./OKEI/fullName)[1]', 'VarChar(Max)'),
                [ProductName]       = V.value('(./name)[1]', 'VarChar(Max)'),
                [ProductSum]        = V.value('(./sum)[1]', 'VarChar(100)'),
                [ProductPrice]      = V.value('(./price)[1]', 'VarChar(100)')
            FROM P.[Products].nodes('/products/product') AS PR(V)
        ) AS PP
        WHERE (PP.[ProductName] LIKE '%' + @Name + '%' OR @Name LIKE '%'  + PP.[ProductName] + '%')
			AND PP.[ProductPrice] = @Price
    ) AS PP
)
GO
