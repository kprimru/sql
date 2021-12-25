﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[HALF_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Common].[HalfActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Common].[HALF_SELECT] TO rl_half_r;
GO
