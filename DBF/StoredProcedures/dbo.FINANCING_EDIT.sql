USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FINANCING_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FINANCING_EDIT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Изменить данные о типе
               финансирования с указанным кодом
*/

ALTER PROCEDURE [dbo].[FINANCING_EDIT]
	@financingid SMALLINT,
	@financingname VARCHAR(100),
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

		UPDATE dbo.FinancingTable
		SET FIN_NAME = @financingname,
			FIN_ACTIVE = @active
		WHERE FIN_ID = @financingid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FINANCING_EDIT] TO rl_financing_w;
GO
