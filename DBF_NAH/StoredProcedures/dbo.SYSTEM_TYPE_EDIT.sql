USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_TYPE_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_TYPE_EDIT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 24.09.2008
Описание:	  Изменить данные о типе системы с
               указанным кодом в справочнике
*/

ALTER PROCEDURE [dbo].[SYSTEM_TYPE_EDIT]
	@systemtypeid SMALLINT,
	@systemtypename VARCHAR(20),
	@systemtypecaption VARCHAR(100),
	@systemtypelst VARCHAR(20),
	@systemtypereport BIT,
	@order SMALLINT,
	@mosid SMALLINT,
	@subid SMALLINT,
	@host SMALLINT,
	@dhost SMALLINT,
	@coef BIT,
	@calc DECIMAL(4, 2),
	@kbu BIT,
	@active BIT = 1
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

		UPDATE dbo.SystemTypeTable
		SET SST_NAME = @systemtypename,
			SST_CAPTION = @systemtypecaption,
			SST_LST = @systemtypelst,
			SST_REPORT = @systemtypereport,
			SST_ACTIVE = @active,
			SST_ORDER = @order,
			SST_ID_MOS = @mosid,
			SST_ID_SUB = @subid,
			SST_ID_HOST = @host,
			SST_ID_DHOST = @dhost,
			SST_COEF = @coef,
			SST_CALC = @calc,
			SST_KBU = @kbu
		WHERE SST_ID = @systemtypeid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_EDIT] TO rl_system_type_w;
GO
