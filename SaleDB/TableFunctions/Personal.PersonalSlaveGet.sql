USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Personal].[PersonalSlaveGet]
(
	@ID	UNIQUEIDENTIFIER
)
RETURNS @TBL TABLE 
(
	ID	UNIQUEIDENTIFIER,
	LVL	INT
)
AS
BEGIN
	DECLARE @level INT 
	SET @level = 1

	INSERT INTO @TBL (id, LVL)
		SELECT @ID, 1

	WHILE 1 = 1
	BEGIN
		INSERT INTO @TBL (id, LVL)
			SELECT tr.ID, @level + 1
			FROM 
				Personal.OfficePersonal AS tr
				INNER JOIN @TBL AS t ON t.ID = tr.MANAGER and t.LVL = @level

		IF @@rowcount = 0 
			BREAK

		SET @level = @level + 1
	END

	RETURN
END
