USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Salary].[PERSONAL_SALARY_DETAIL_SELECT]
	@PS_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	*
	FROM	Salary.PersonalSalaryDetailView
	WHERE	PS_ID	=	@PS_ID
END
