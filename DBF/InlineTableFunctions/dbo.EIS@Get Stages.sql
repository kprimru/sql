USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Get Stages]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[EIS@Get Stages] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[EIS@Get Stages]
(
    @Act_Id			Int,
	@Invoice_Id		Int
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		S.[StartDate],
		S.[FinishDate],
		S.[StageGUId],
		S.[StageComment]
	FROM
	(
		SELECT
			[Date]		= A.[ACT_DATE],
			[Client_Id] = A.[ACT_ID_CLIENT]
		FROM [dbo].[ActTable] AS A
		WHERE A.[ACT_ID] = @Act_Id
		---
		UNION ALL
		---
		SELECT
			[Date]		= I.[INS_DATE],
			[Client_Id] = I.[INS_ID_CLIENT]
		FROM [dbo].[InvoiceSaleTable] AS I
		WHERE I.[INS_ID] = @Invoice_Id
	) AS C
	OUTER APPLY
	(
		SELECT F.[EIS_DATA]
		FROM [dbo].[ClientFinancing] AS F
		WHERE F.[ID_CLIENT] = C.[Client_Id]
	) AS F
	OUTER APPLY
    (
        SELECT
            [ExecutionPeriods]  = F.[EIS_DATA].query('/export/contract/executionPeriod'),
            [BudgetFunds]       = F.[EIS_DATA].query('/export/contract/finances/budgetFunds'),
			[ExtraBudgetFunds]  = F.[EIS_DATA].query('/export/contract/finances/extrabudgetFunds'),
			[FinancingPlan]		= F.[EIS_DATA].query('/export/contract/finances/financingPlan')
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
        SELECT [StageGUId], [StartDate], [FinishDate], [StageComment]
        FROM
        (
            SELECT
                [StartDate]     = Convert(SmallDateTime, S.value('(./startDate)[1]', 'VarChar(100)'), 120),
                [FinishDate]    = Convert(SmallDateTime, S.value('(./endDate)[1]', 'VarChar(100)'), 120),
                [StageComment]  = S.value('(./payments/comment)[1]', 'VarChar(100)'),
                [StageGUId]    = S.value('(./guid)[1]', 'VarChar(100)')
            FROM ST.Stages.nodes('*/stages') AS E(S)
        ) AS SS
        WHERE C.[Date] BETWEEN SS.[StartDate] AND SS.[FinishDate]
    ) AS S
)
GO
