﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Income].[INCOME_LAST_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Income].[INCOME_LAST_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Income].[INCOME_LAST_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 PTL_KEY AS ID_ID
	FROM Security.Protocol
	WHERE PTL_REFERENCE = 'INCOME_DETAIL'
		AND PTL_USER = ORIGINAL_LOGIN()
	ORDER BY PTL_DATE DESC
END
GO
GRANT EXECUTE ON [Income].[INCOME_LAST_SELECT] TO rl_income_r;
GO
