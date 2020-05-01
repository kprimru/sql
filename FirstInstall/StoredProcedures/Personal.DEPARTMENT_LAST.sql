USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[DEPARTMENT_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(DPMS_LAST)
	FROM	Personal.Department
END
GRANT EXECUTE ON [Personal].[DEPARTMENT_LAST] TO rl_department_r;
GO