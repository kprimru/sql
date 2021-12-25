﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[COMPETITION_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Book].[CompetitionActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Book].[COMPETITION_SELECT] TO rl_competition_r;
GO
