USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_TECH_SELECT]
	@CL_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CLM_ID, CLM_ID_CLAIM, CLM_ID_CLIENT, CLM_DATE, CLM_AUTHOR, CLM_STATUS, CLM_TYPE, CLM_ACTION_BEFORE, CLM_PROBLEM, CLM_AFTER, CLM_EX_DATE, CLM_REAL_TYPE, CLM_EXECUTOR, CLM_COMMENT, CLM_EXECUTE_ACTION
	FROM dbo.ClaimTable
	WHERE CLM_ID_CLIENT = @CL_ID
	ORDER BY CLM_DATE DESC
END