USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claims->Specials@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claims->Specials@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[Claims->Specials@Select]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT [Special]
	FROM [Claim].[Claims]
	WHERE [Special] IS NOT NULL
		AND [Special] <> ''
		AND [Type_Id] = 3
	ORDER BY [Special];
END
GO
GRANT EXECUTE ON [Claim].[Claims->Specials@Select] TO rl_claim_r;
GO
