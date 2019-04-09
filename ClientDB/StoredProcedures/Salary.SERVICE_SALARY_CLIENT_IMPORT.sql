USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[SERVICE_SALARY_CLIENT_IMPORT]
	@SALARY		UNIQUEIDENTIFIER,
	@PERIOD		UNIQUEIDENTIFIER,
	@SERVICE	INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Salary.ServiceClient(ID_SALARY, ID_CLIENT)
		SELECT @SALARY, ClientID
		FROM dbo.ClientTable
		WHERE ClientServiceID = @SERVICE
			AND StatusID = 2
			AND STATUS = 1
END
