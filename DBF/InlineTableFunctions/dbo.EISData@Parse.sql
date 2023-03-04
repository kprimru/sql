USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EISData@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[EISData@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO

CREATE FUNCTION [dbo].[EISData@Parse]
(
    @Data			Xml,
    @ActDate		SmallDateTime,
    @ActPrice		Money,
    @IsActual		Bit,
	@StageGuid		VarChar(100),
	@ProductGuid	VarChar(100)
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
		PP.[ProductSid],
        PP.[ProductOKPD2Code],
        PP.[ProductOKEICode],
        PP.[ProductOKEIFullName],
        R.[RegNum],
        R.[Number],
        S.[Stage_GUId],
        S.[StartDate],
        S.[FinishDate],
		A.[AccountGuid]
        --S.[StagePrice]

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
            [ExecutionPeriods]  = C.query('executionPeriod'),
            [BudgetFunds]       = C.query('finances/budgetFunds'),
			[ExtraBudgetFunds]  = C.query('finances/extrabudgetFunds'),
			[FinancingPlan]		= C.query('finances/financingPlan')
    ) AS EP
	OUTER APPLY
	(
		SELECT
			[Stages] = CASE
							WHEN Cast([BudgetFunds] AS VarChar(Max)) != '' AND [BudgetFunds] IS NOT NULL THEN [BudgetFunds]
							WHEN Cast([ExtraBudgetFunds] AS VarChar(Max)) != '' AND [ExtraBudgetFunds] IS NOT NULL THEN [ExtraBudgetFunds]
							WHEN Cast([FinancingPlan] AS VarChar(Max)) != '' AND [FinancingPlan] IS NOT NULL THEN [FinancingPlan]
							ELSE NULL
						END
	) AS ST
    OUTER APPLY
    (
        SELECT TOP (1) [Stage_GUId], [StartDate], [FinishDate]
        FROM
        (
            SELECT
                [IsActualRow]   = CASE WHEN @IsActual = 1 AND S.value('(./payments/comment)[1]', 'VarChar(100)') LIKE '%Актуализ%' THEN 1 ELSE 0 END,
                [StartDate]     = Convert(SmallDateTime, S.value('(./startDate)[1]', 'VarChar(100)'), 120),
                [FinishDate]    = Convert(SmallDateTime, S.value('(./endDate)[1]', 'VarChar(100)'), 120),
                [StageComment]  = S.value('(./payments/comment)[1]', 'VarChar(100)'),
                [Stage_GUId]    = S.value('(./guid)[1]', 'VarChar(100)')
            FROM ST.Stages.nodes('*/stages') AS E(S)
        ) AS SS
        WHERE
			(@StageGuid IS NOT NULL AND SS.[Stage_GUId] = @StageGuid)
			OR
			(@StageGuid IS NULL AND @ActDate BETWEEN SS.[StartDate] AND SS.[FinishDate])
        ORDER BY
			CASE WHEN [IsActualRow] = 1 THEN 0 ELSE 1 END,
			SS.[StartDate] DESC
    ) AS S
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
        WHERE (@ProductGuid IS NOT NULL AND PP.[Product_GUId] = @ProductGuid)
			OR @ProductGuid IS NULL
        ORDER BY CASE
            WHEN PP.[ProductPrice] = @ActPrice THEN 1 ELSE 2 END,
            --CASE WHEN PP.[ProductSum] = S.[StagePrice] THEN 1 ELSE 2 END,
            CASE
				WHEN @IsActual = 1 AND PP.[IsActualRow] = 1 THEN 0
				WHEN @IsActual = 0 AND PP.[IsActualRow] = 0 THEN 0
				ELSE 1
			END,
            [Row_Number]
    ) AS PP
	OUTER APPLY
	(
		SELECT
			[AccountGuid] = C.value('(./suppliersInfo/supplierInfo/supplierAccountsDetails/supplierAccountDetails/guid)[1]', 'VarChar(100)')
	) AS A
)
GO
