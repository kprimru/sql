USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[SERVICE_SALARY_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@MONTH		UNIQUEIDENTIFIER,
	@SERVICE	INT,
	@POSITION	INT,
	@RATE		INT,
	@INSURANCE	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Salary.Service
	SET ID_MONTH		=	@MONTH,
		ID_SERVICE		=	@SERVICE,
		ID_POSITION		=	@POSITION,
		MANAGER_RATE	=	@RATE,
		INSURANCE		=	@INSURANCE
	WHERE ID = @ID
	
	IF @@ROWCOUNT = 0
	BEGIN
		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)
		
		INSERT INTO Salary.Service(ID_MONTH, ID_SERVICE, ID_POSITION, MANAGER_RATE, INSURANCE)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@MONTH, @SERVICE, @POSITION, @RATE, @INSURANCE)
			
		SELECT @ID = ID
		FROM @TBL
	END
END
