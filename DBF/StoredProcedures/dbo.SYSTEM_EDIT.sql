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

CREATE PROCEDURE [dbo].[SYSTEM_EDIT] 
	@id SMALLINT,
	@prefix VARCHAR(20),
	@name VARCHAR(250),
	@shortname VARCHAR(50),
	@regname VARCHAR(50),
	@hostid INT,
	@soid SMALLINT,
	@order SMALLINT,
	@report BIT,
	@code_1c VARCHAR(50),
	@code_1c2 VARCHAR(50),
	--@weight INT,
	@coef DECIMAL(4, 2),
	@ib VARCHAR(10),
	@calc DECIMAL(4, 2),
	@active BIT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.SystemTable 
	SET SYS_PREFIX = @prefix,
	    SYS_NAME = @name, 
		SYS_SHORT_NAME = @shortname, 
		SYS_REG_NAME = @regname, 
		SYS_ID_HOST = @hostid,     
		SYS_ID_SO = @soid,
		SYS_ORDER = @order,
		SYS_REPORT = @report,
		SYS_ACTIVE = @active,
		SYS_1C_CODE = @code_1c,
		SYS_1C_CODE2 = @code_1c2,
		SYS_COEF = @coef,
		SYS_IB = @ib,
		SYS_CALC = @calc
	WHERE SYS_ID = @id

	SET NOCOUNT OFF
END
