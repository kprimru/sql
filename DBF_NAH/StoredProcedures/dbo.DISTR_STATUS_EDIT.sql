USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 30.01.2008
Описание:	  Изменить данные о статусе дистрибутива
*/

ALTER PROCEDURE [dbo].[DISTR_STATUS_EDIT]
	@dsid SMALLINT,
	@dsname VARCHAR(50),
	@dsreg TINYINT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.DistrStatusTable
	SET DS_NAME = @dsname,
		DS_REG = @dsreg,
		DS_ACTIVE = @active
	WHERE DS_ID = @dsid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[DISTR_STATUS_EDIT] TO rl_distr_status_w;
GO