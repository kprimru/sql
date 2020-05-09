USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[FINANCING_PROTOCOL_ADD]
	@TP		VARCHAR(64),
	@OPER	VARCHAR(256),
	@TXT	VARCHAR(MAX),
	@CLIENT	INT,
	@DOC	INT
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

		SET @TXT = ISNULL(@TXT, '')

		INSERT INTO dbo.FinancingProtocol(OPER, TP, TXT, ID_CLIENT, ID_DOCUMENT)
			VALUES(@OPER, @TP, @TXT, @CLIENT, @DOC)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FINANCING_PROTOCOL_ADD] TO public;
GO