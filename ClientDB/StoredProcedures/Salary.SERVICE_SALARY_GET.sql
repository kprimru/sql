USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Salary].[SERVICE_SALARY_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID_SERVICE, ID_MONTH, ID_POSITION, MANAGER_RATE, INSURANCE
	FROM Salary.Service
	WHERE ID = @ID
END
