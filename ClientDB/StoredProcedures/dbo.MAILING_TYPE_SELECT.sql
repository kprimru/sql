USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MAILING_TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[MAILING_TYPE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[MAILING_TYPE_SELECT]
	@FILTER		VARCHAR(100) = NULL
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

		SELECT
			MailingTypeID, MailingTypeName
		FROM
			Common.MailingType
		WHERE
			@FILTER IS NULL OR MailingTypeName LIKE '%'+@FILTER+'%'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[MAILING_TYPE_SELECT] TO rl_mailing_type_r;
GO
