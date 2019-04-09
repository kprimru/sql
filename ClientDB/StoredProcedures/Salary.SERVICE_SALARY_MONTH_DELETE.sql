USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[SERVICE_SALARY_MONTH_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM Salary.ServiceStudy
	WHERE ID_SALARY IN
		(
			SELECT ID
			FROM Salary.Service
			WHERE ID_MONTH = @ID
		)

	DELETE 
	FROM Salary.ServiceDistr
	WHERE ID_SALARY IN
		(
			SELECT ID
			FROM Salary.Service
			WHERE ID_MONTH = @ID
		)
	
	DELETE 
	FROM Salary.ServiceClient
	WHERE ID_SALARY IN
		(
			SELECT ID
			FROM Salary.Service
			WHERE ID_MONTH = @ID
		)

	DELETE 
	FROM Salary.Service
	WHERE ID IN
		(
			SELECT ID
			FROM Salary.Service
			WHERE ID_MONTH = @ID
		)
END
