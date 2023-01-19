﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Clients].[CLIENTS_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Clients].[CLIENTS_LAST]  AS SELECT 1')
GO
ALTER PROCEDURE [Clients].[CLIENTS_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT	=	MAX(CLMS_LAST)
	FROM	Clients.Clients
END
GO
GRANT EXECUTE ON [Clients].[CLIENTS_LAST] TO rl_clients_r;
GO
