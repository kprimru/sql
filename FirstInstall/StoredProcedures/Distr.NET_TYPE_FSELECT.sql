﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[NET_TYPE_FSELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Distr].[NET_TYPE_FSELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Distr].[NET_TYPE_FSELECT]
	@RC INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT NT_ID_MASTER, NT_ID, NT_SHORT, NT_NAME
	FROM Distr.NetTypeActive

	UNION ALL

	SELECT TT_ID_MASTER, TT_ID, TT_SHORT, TT_NAME
	FROM Distr.TechTypeActive
	WHERE TT_COEF <> 1
	ORDER BY NT_SHORT

	SET @RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[NET_TYPE_FSELECT] TO rl_net_type_r;
GO
