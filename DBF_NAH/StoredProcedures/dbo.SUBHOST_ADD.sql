USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Добавить подхост в справочник
*/

ALTER PROCEDURE [dbo].[SUBHOST_ADD]
	@subhostfullname VARCHAR(250),
	@subhostshortname VARCHAR(50),
	@subhostric BIT,
	@subhostlstname VARCHAR(20),
	@reg BIT,
	@study	BIT,
	@system	BIT,
	@subhostorder SMALLINT,
	@calc	DECIMAL(4, 2),
	@penalty	DECIMAL(8, 4),
	@periodicity SMALLINT,
	@active BIT = 1,  
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.SubhostTable(SH_FULL_NAME, SH_SHORT_NAME, SH_SUBHOST, SH_LST_NAME,
			SH_REG, SH_CALC_STUDY, SH_CALC_SYSTEM, SH_ORDER, SH_CALC, SH_PENALTY, SH_PERIODICITY, SH_ACTIVE)
	VALUES (@subhostfullname, @subhostshortname, @subhostric, @subhostlstname,
			@reg, @study, @system, @subhostorder, @calc, @penalty, @periodicity, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_ADD] TO rl_subhost_w;
GO