USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[PAY_COEF_ADD] 
	@min SMALLINT,
	@max SMALLINT,
	@value DECIMAL(8, 4),
	@active BIT = 1,	
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.PayCoefTable (PC_START, PC_END, PC_VALUE, PC_ACTIVE) 
	VALUES (@min, @max, @value, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
