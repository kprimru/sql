USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Date@Available]', 'FN') IS NULL EXEC('CREATE FUNCTION [Price].[Date@Available] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [Price].[Date@Available]
(
	@Date	SmallDateTime
)
RETURNS BIT
AS
BEGIN
	RETURN
		(
			SELECT TOP (1)
				[IsAvailable] = IsNull(PA.[IsAvailable], 0)
			FROM [Common].[Period] AS P
			LEFT JOIN [Price].[Periods=Available] AS PA ON P.[ID] = PA.[Period_Id]
			WHERE [Type] = 2
				AND @Date BETWEEN P.[START] AND P.[FINISH]
		)
END
GO
