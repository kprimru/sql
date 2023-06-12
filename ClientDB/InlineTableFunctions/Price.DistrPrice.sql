USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[DistrPrice]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[DistrPrice] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Price].[DistrPrice]
(
	@System_Id			Int,
	@DistrType_Id		Int,
	@SystemType_Id		Int,
	@Date				SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[Price]					= P.[Price],
		[Coef]					= C.[Coef],
		[Round]					= C.[Round],
		[PriceWithCoef]			= Round(P.[Price] * C.[Coef], C.[Round]),
		[PriceWithCoefAndTax]	= Round(Round(P.[Price] * C.[Coef], C.[Round]) * T.[TOTAL_RATE], 2)
	FROM
	(
		SELECT TOP (1)
			P.[Price]
		FROM [Price].[Systems:Price@Get](@Date) AS P
		WHERE P.[System_Id] = @System_Id
	) AS P
	OUTER APPLY
	(
		SELECT
			SC.[Date],
			SC.[Coef],
			SC.[Round]
		FROM [Price].[Coef:Special@Get](@Date) AS SC
		WHERE [System_Id] = @System_Id
			AND [DistrType_Id] = @DistrType_Id
			AND [SystemType_Id] = @SystemType_Id
	) AS SC
	OUTER APPLY
	(
		SELECT
			[Coef]	= D.[Coef] * S.[Coef],
			[Round]	= [Common].[Min(SmallInt)](D.[Round], S.[Round])
		FROM [Price].[DistrTypes:Coef@Get](@Date) AS D
		CROSS JOIN [Price].[SystemTypes:Coef@Get](@Date) AS S
		WHERE D.[DistrType_Id] = @DistrType_Id
			AND S.[SystemType_Id] = @SystemType_Id
			AND SC.[Date] IS NULL
	) AS NC
	OUTER APPLY
	(
		SELECT
			[Coef]	= CASE WHEN SC.[Date] IS NOT NULL THEN SC.[Coef] ELSE NC.[Coef] END,
			[Round]	= CASE WHEN SC.[Date] IS NOT NULL THEN SC.[Round] ELSE NC.[Round] END
	) AS C
	OUTER APPLY [Common].[TaxDefaultSelect](@Date) AS T
	WHERE [Price].[Date@Available](@Date) = 1
)
GO
