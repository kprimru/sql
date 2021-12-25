USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			коллектив авторов
Описание:		Скопировать сотрудника ТО в таблицу
					сотрудников клиента
*/

ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_COPY_FROM_TO]
	@toperid INT,
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

		INSERT INTO	dbo.ClientPersonalTable(
			PER_ID_CLIENT,	PER_FAM,	PER_NAME,	PER_OTCH,	PER_ID_POS,	PER_ID_REPORT_POS)
			SELECT
				TO_ID_CLIENT, TP_SURNAME,	TP_NAME,	TP_OTCH,	TP_ID_POS,	TP_ID_RP
			FROM	dbo.TOPersonalTable	A	INNER JOIN
					dbo.TOTable			B	ON	A.TP_ID_TO=B.TO_ID
			WHERE	A.TP_ID=@toperid

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
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_COPY_FROM_TO] TO rl_client_personal_w;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_COPY_FROM_TO] TO rl_client_w;
GO
