USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[HALF_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT	=	MAX(HLFMS_LAST)
	FROM	Common.Half
END
GO
GRANT EXECUTE ON [Common].[HALF_LAST] TO rl_half_r;
GO
