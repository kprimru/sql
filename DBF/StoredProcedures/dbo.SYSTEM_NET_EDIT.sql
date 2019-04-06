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

CREATE PROCEDURE [dbo].[SYSTEM_NET_EDIT] 
	@id INT,
	@name VARCHAR(20),
	@fullname VARCHAR(100),
	@coef DECIMAL(8, 4),
	@calc DECIMAL(4, 2),
	@order INT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.SystemNetTable 
	SET SN_NAME = @name, 
	    SN_FULL_NAME = @fullname, 
		SN_COEF = @coef,
		SN_ORDER = @order,
		SN_CALC = @calc,
		SN_ACTIVE = @active
	WHERE SN_ID = @id

	SET NOCOUNT OFF
END





