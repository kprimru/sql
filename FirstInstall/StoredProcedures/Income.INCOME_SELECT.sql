﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Income].[INCOME_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Income].[INCOME_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Income].[INCOME_SELECT]
	@IN_ID UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		IN_ID, IN_DATE, IN_PAY, IN_ID_INCOME,
		CL_ID, CL_ID_MASTER, CL_NAME, CL_NAME AS CL_TEMP,
		VD_ID, VD_ID_MASTER, VD_NAME
	FROM Income.IncomeMasterView
	WHERE IN_ID = @IN_ID
END
GO
GRANT EXECUTE ON [Income].[INCOME_SELECT] TO rl_income_r;
GO
