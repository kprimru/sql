USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GOOD_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GOOD_EDIT]  AS SELECT 1')
GO

/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[GOOD_EDIT]
	@id SMALLINT,
	@name VARCHAR(150),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.GoodTable
		SET GD_NAME = @name,
			GD_ACTIVE = @active
		WHERE GD_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[GOOD_EDIT] TO rl_good_w;
GO
