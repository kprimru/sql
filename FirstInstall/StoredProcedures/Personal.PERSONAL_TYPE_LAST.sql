USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_TYPE_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(PTMS_LAST)
	FROM	Personal.PersonalType
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_TYPE_LAST] TO rl_personal_type_r;
GO
