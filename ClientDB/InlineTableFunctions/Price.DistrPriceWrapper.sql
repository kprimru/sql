USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[DistrPriceWrapper]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[DistrPriceWrapper] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Price].[DistrPriceWrapper]
(
	@System_Id			Int,
	@DistrType_Id		Int,
	@SystemType_Id		Int,
	@SystemTypeName		VarChar(128),
	@Date				SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		C.[Price],
		C.[DistrCoef],
		C.[DistrCoefRound]
	FROM
	(
		SELECT [PriceCoefVersion] = Cast([System].[Setting@Get]('PRICE_COEF_VERSION') AS SmallInt)
	) AS V
	OUTER APPLY
	(
		SELECT
			[Price] = P.[PRICE],
			[DistrCoef] = [dbo].[DistrCoef](@System_Id, @DistrType_Id, @SystemTypeName, @Date),
			[DistrCoefRound] = [dbo].[DistrCoefRound](@System_Id, @DistrType_Id, @SystemTypeName, @Date)
		FROM [Price].[SystemPrice] AS P
		INNER JOIN [Common].[Period] AS PR ON PR.[ID] = P.[ID_MONTH]
		WHERE @Date BETWEEN PR.[START] AND PR.[FINISH] AND PR.[TYPE] = 2
			AND P.[ID_SYSTEM] = @System_Id
			AND V.[PriceCoefVersion] = 1
		UNION ALL
		SELECT
			P.[Price],
			P.[Coef],
			P.[Round]
		FROM [Price].[DistrPrice](@System_Id, @DistrType_Id, @SystemType_Id, @Date) AS P
		WHERE V.[PriceCoefVersion] = 2
		UNION ALL
		SELECT
			[Price] = 0,
			[DistrCoef] = 0,
			[DistrCoefRound] = 0
		WHERE V.[PriceCoefVersion] NOT IN (1, 2)
	) AS C
)
GO
