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

CREATE PROCEDURE [dbo].[SYSTEM_NET_ADD] 
	@name VARCHAR(20),
	@fullname VARCHAR(100),
	@coef DECIMAL(8, 4),
	@order SMALLINT,
	@calc DECIMAL(4, 2),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.SystemNetTable(SN_NAME, SN_FULL_NAME, SN_COEF, SN_ORDER, SN_CALC, SN_ACTIVE) 
	VALUES (@name, @fullname, @coef, @order, @calc, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END








