USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_PERSONAL_EDIT]
	@tpid INT,
	@rpid TINYINT,
	@posid SMALLINT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@phone VARCHAR(100)
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

		UPDATE dbo.TOPersonalTable
		SET
			TP_ID_RP = @rpid,
			TP_ID_POS = @posid,
			TP_SURNAME = @surname,
			TP_NAME = @name,
			TP_OTCH = @otch,
			TP_PHONE = @phone,
			TP_LAST = GETDATE()
		WHERE TP_ID = @tpid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_PERSONAL_EDIT] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_PERSONAL_EDIT] TO rl_to_personal_w;
GO
