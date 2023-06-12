USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_PERSONAL_COPY_FROM_TO]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_PERSONAL_COPY_FROM_TO]  AS SELECT 1')
GO


/*
Автор:
Описание:		Скопировать сотрудника ТО в таблицу
					сотрудников клиента
Дата:			10-July-2009
*/

ALTER PROCEDURE [dbo].[TO_PERSONAL_COPY_FROM_TO]
	@toperid INT,
	@toid INT,
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

		INSERT INTO	dbo.TOPersonalTable(
			TP_ID_TO, TP_SURNAME, TP_NAME, TP_OTCH, TP_ID_POS, TP_ID_RP, TP_PHONE)
			SELECT
				@toid, TP_SURNAME, TP_NAME, TP_OTCH, TP_ID_POS, TP_ID_RP, TP_PHONE
			FROM	dbo.TOPersonalTable
			WHERE	TP_ID=@toperid

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
GRANT EXECUTE ON [dbo].[TO_PERSONAL_COPY_FROM_TO] TO rl_to_personal_w;
GO
