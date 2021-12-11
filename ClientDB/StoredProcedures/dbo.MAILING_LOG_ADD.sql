USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MAILING_LOG_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[MAILING_LOG_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[MAILING_LOG_ADD]
	@TypeCode	VarChar(100),
	@Address	VarChar(256),
	@Subject	VarCHar(256),
	@Body		VarCHar(Max),
	@Error		VarChar(Max)
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

		SET @Error = NullIf(@Error, '');

		INSERT INTO Common.MailingLog([TypeID], [Address], [Subject], [Body], [Status], [Error])
		SELECT MailingTypeId, @Address, @Subject, @Body, CASE WHEN @Error IS NULL THEN 0 ELSE 1 END, @Error
		FROM Common.MailingType
		WHERE [MailingTypeCode] = @TypeCode

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[MAILING_LOG_ADD] TO rl_mailing_log_w;
GO
