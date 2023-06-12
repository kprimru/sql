USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FIELD_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FIELD_ADD]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Добавить новое поле в справочник полей
*/

ALTER PROCEDURE [dbo].[FIELD_ADD]
	@fieldname VARCHAR(50),
	@fieldwidth INT,
	@fieldcaption VARCHAR(50),
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

		INSERT INTO dbo.FieldTable(FL_NAME, FL_WIDTH, FL_CAPTION)
		VALUES (@fieldname, @fieldwidth, @fieldcaption)

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
