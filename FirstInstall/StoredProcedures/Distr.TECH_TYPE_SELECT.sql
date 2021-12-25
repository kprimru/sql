﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[TECH_TYPE_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Distr].[TechTypeActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[TECH_TYPE_SELECT] TO rl_tech_type_r;
GO
