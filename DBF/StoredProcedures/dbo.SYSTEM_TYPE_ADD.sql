USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 24.09.2008
Описание:	  Добавить тип системы
               клиента в справочник
*/

ALTER PROCEDURE [dbo].[SYSTEM_TYPE_ADD]
	@systemtypename VARCHAR(20),
	@systemtypecaption VARCHAR(100),
	@systemtypelst VARCHAR(20),
	@systemtypereport BIT,
	@order SMALLINT,
	@mosid SMALLINT,
	@subid SMALLINT,
	@host SMALLINT,
	@dhost	SMALLINT,
	@coef BIT,
	@calc DECIMAL(4, 2),
	@kbu BIT,
	@active BIT = 1,
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

		INSERT INTO dbo.SystemTypeTable(SST_NAME, SST_CAPTION, SST_LST, SST_REPORT, SST_ACTIVE, SST_ORDER, SST_ID_MOS, SST_ID_SUB, SST_ID_HOST, SST_ID_DHOST, SST_COEF, SST_CALC, SST_KBU)
		VALUES (@systemtypename, @systemtypecaption, @systemtypelst, @systemtypereport, @active, @order, @mosid, @subid, @host, @dhost, @coef, @calc, @kbu)

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
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_ADD] TO rl_system_type_w;
GO