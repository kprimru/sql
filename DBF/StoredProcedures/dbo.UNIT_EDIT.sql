USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[UNIT_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[UNIT_EDIT]  AS SELECT 1')
GO


/*
Автор:		  Денисов Алексей
Дата создания: 24.09.2008
Описание:	  Изменить данные о типе системы с
               указанным кодом в справочнике
*/

ALTER PROCEDURE [dbo].[UNIT_EDIT]
	@unitid SMALLINT,
	@name VARCHAR(100),
	@okei VARCHAR(50),
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

		UPDATE dbo.UnitTable
		SET UN_NAME = @name,
			UN_OKEI = @okei,
			UN_ACTIVE = @active
		WHERE UN_ID = @unitid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[UNIT_EDIT] TO rl_unit_w;
GO
