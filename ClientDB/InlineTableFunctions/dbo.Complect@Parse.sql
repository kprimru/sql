USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Complect@Parse]
(
	@Complect	VarChar(100)
)
RETURNS TABLE
AS
RETURN 
(
	SELECT
		[SystemNumber],
		[CompNumber],
		[DistrNumber]
	FROM
	(
		SELECT [Complect] = @Complect
	) AS C
	CROSS APPLY
	(
		SELECT
			[SystemNumber] = Left([Complect], CharIndex('_', [Complect]) - 1),
			[ComplectWithoutSystem] = Right([Complect], Len([Complect]) - CharIndex('_', [Complect]))
	) AS S
	CROSS APPLY
	(
		SELECT
			[CompNumber] = CASE WHEN CharIndex('_', S.[ComplectWithoutSystem]) > 0 THEN Cast(Right([ComplectWithoutSystem], Len([ComplectWithoutSystem]) - CharIndex('_', [ComplectWithoutSystem])) AS TinyInt) ELSE 1 END,
			[ComplectWithoutSystemAndComp] = CASE WHEN CharIndex('_', S.[ComplectWithoutSystem]) > 0 THEN Left([ComplectWithoutSystem], CharIndex('_', [ComplectWithoutSystem]) - 1) ELSE [ComplectWithoutSystem] END
	) AS CP
	CROSS APPLY
	(
		SELECT
			[DistrNumber] = Cast([ComplectWithoutSystemAndComp] AS Int)
	) AS D
)
