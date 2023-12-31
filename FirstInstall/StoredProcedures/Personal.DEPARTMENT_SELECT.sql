USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[DEPARTMENT_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Personal].[DepartmentActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Personal].[DEPARTMENT_SELECT] TO rl_department_r;
GO
