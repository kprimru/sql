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

CREATE PROCEDURE [dbo].[DISTR_EXCEPT_ADD] 
	@systemid INT,
	@distrnum INT,
	@compnum TINYINT,
	@comment VARCHAR(250),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @distrid INT	

	INSERT INTO dbo.DistrExceptTable (DE_ID_SYSTEM, DE_DIS_NUM, DE_COMP_NUM, DE_COMMENT, DE_ACTIVE)
	VALUES (@systemid, @distrnum, @compnum, @comment, @active)	

	SELECT @distrid = SCOPE_IDENTITY()	

	IF @returnvalue = 1
		SELECT @distrid AS NEW_IDEN
		
	SET NOCOUNT OFF
END
GRANT EXECUTE ON dbo.DISTR_EXCEPT_ADD TO rl_reg_node_report_r