USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Изменить данные о подхосте с
                указанным кодом
*/

ALTER PROCEDURE [dbo].[SUBHOST_EDIT]
	@subhostid SMALLINT,
	@subhostfullname VARCHAR(250),
	@subhostshortname VARCHAR(50),
	@subhostric BIT,
	@subhostlstname VARCHAR(20),
	@reg BIT,
	@study BIT,
	@system BIT,
	@subhostorder SMALLINT,
	@calc DECIMAL(4, 2),
	@penalty	DECIMAL(8, 4),
	@periodicity	SMALLINT,
	@active BIT
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

		UPDATE dbo.SubhostTable
		SET SH_FULL_NAME = @subhostfullname,
			SH_SHORT_NAME = @subhostshortname,
			SH_SUBHOST = @subhostric,
			SH_LST_NAME = @subhostlstname,
			SH_REG = @reg,
			SH_CALC_STUDY = @study,
			SH_CALC_SYSTEM = @system,
			SH_ORDER = @subhostorder,
			SH_CALC	= @calc,
			SH_PENALTY = @penalty,
			SH_PERIODICITY = @periodicity,
			SH_ACTIVE = @active
		WHERE SH_ID = @subhostid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_EDIT] TO rl_subhost_w;
GO
