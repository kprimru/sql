USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PROTOCOL_DOCUMENT_SEARCH]
	@TP	NVARCHAR(64),
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

		SELECT CL_ID, CL_PSEDO, OPER, TXT, USR_NAME, UPD_DATE
		FROM
			dbo.FinancingProtocol
			LEFT OUTER JOIN dbo.ClientTable ON CL_ID = ID_CLIENT
		WHERE TP = @TP AND ID_DOCUMENT = @DOC
		ORDER BY UPD_DATE DESC, ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PROTOCOL_DOCUMENT_SEARCH] TO rl_financing_protocol_r;
GO
