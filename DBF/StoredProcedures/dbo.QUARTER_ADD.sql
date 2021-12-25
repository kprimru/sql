USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Дата создания: 10.05.2012
Описание:	  Добавить квартал в справочник
*/
ALTER PROCEDURE [dbo].[QUARTER_ADD]
	@name	VARCHAR(50),
	@begin	SMALLDATETIME,
	@end	SMALLDATETIME,
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

		INSERT INTO dbo.Quarter(
				QR_NAME, QR_BEGIN, QR_END, QR_ACTIVE)
		VALUES (@NAME, @begin, @end, @active)

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
GRANT EXECUTE ON [dbo].[QUARTER_ADD] TO rl_quarter_w;
GO
