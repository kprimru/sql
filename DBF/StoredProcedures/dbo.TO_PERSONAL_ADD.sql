USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:	  Добавить сотрудника клиенту
*/

ALTER PROCEDURE [dbo].[TO_PERSONAL_ADD]
	@toid INT,
	@rpid TINYINT,
	@posid SMALLINT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@phone varchar(100),
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

		INSERT INTO dbo.TOPersonalTable(
									TP_ID_TO, TP_ID_RP, TP_ID_POS, TP_SURNAME,
									TP_NAME, TP_OTCH, TP_PHONE, TP_LAST
									)
		VALUES (
				@toid, @rpid, @posid, @surname, @name, @otch, @phone, GETDATE()
				)

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
GRANT EXECUTE ON [dbo].[TO_PERSONAL_ADD] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_PERSONAL_ADD] TO rl_to_personal_w;
GO
