USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_ADD]  AS SELECT 1')
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
	@subhosttype TINYINT,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO dbo.SubhostTable(SH_FULL_NAME, SH_SHORT_NAME, SH_SUBHOST, SH_LST_NAME,
				SH_REG, SH_CALC_STUDY, SH_CALC_SYSTEM, SH_ORDER, SH_CALC, SH_PENALTY, SH_PERIODICITY, SH_ACTIVE, SH_ID_TYPE)
		VALUES (@subhostfullname, @subhostshortname, @subhostric, @subhostlstname,
				@reg, @study, @system, @subhostorder, @calc, @penalty, @periodicity, @active, @subhosttype)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_ADD] TO rl_subhost_w;
GO
