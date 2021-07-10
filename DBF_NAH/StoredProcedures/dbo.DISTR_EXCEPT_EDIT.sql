USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_EXCEPT_EDIT]
	@distrid INT,
	@systemid INT,
	@distrnum INT,
	@compnum TINYINT,
	@comment VARCHAR(250),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.DistrExceptTable
	SET DE_ID_SYSTEM = @systemid,
		DE_DIS_NUM = @distrnum,
		DE_COMP_NUM = @compnum,
		DE_COMMENT = @comment,
		DE_ACTIVE = @active
	WHERE DE_ID = @distrid

	SET NOCOUNT OFF
END
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_EDIT]  TO rl_reg_node_report_r
GO
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_EDIT] TO rl_distr_except_w;
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_EDIT] TO rl_reg_node_report_r;
GO