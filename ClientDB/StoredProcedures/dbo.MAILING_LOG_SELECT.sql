USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MAILING_LOG_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[MAILING_LOG_SELECT]  AS SELECT 1')
GO
/*
SET STATISTICS IO ON
SET STATISTICS TIME ON

EXEC [dbo].[MAILING_LOG_SELECT]
	@DateFrom = '20200207'

EXEC [dbo].[MAILING_LOG_SELECT]
	@Address = 'marina.zdor@mail.ru'
*/
ALTER PROCEDURE [dbo].[MAILING_LOG_SELECT]
	@DateFrom	DateTime		= NULL,
	@DateTo		DateTime		= NULL,
	@Type		SmallInt		= NULL,
	@Address	VarChar(256)	= NULL,
	@Subject	VarChar(256)	= NULL,
	@Body		VarChar(256)	= NULL,
	@OnlyError	Bit				= NULL,
	@Error		VarChar(256)	= NULL
AS
BEGIN
	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Address = NullIf(@Address, '') + '%';
		SET @Subject = '%' + NullIf(@Subject, '') + '%';
		SET @Body = '%' + NullIf(@Body, '') + '%';
		SET @Error = '%' + NullIf(@Error, '') + '%';
		SET @OnlyError = IsNull(@OnlyError, 0);

		SELECT TOP (500)
			Date, MailingTypeName, L.address, L.subject, L.body, L.status, L.error
		FROM Common.MailingLog			L
		INNER JOIN Common.MailingType	T ON L.TypeID = T.MailingTypeId
		WHERE	(L.Date >= @DateFrom OR @DateFrom IS NULL)
			AND (L.Date >= @DateTo OR @DateTo IS NULL)
			AND (L.TypeId = @Type OR @Type IS NULL)
			AND (L.Address LIKE @Address OR @Address IS NULL)
			AND (L.Subject LIKE @Subject OR @Subject IS NULL)
			AND (L.Body LIKE @Body OR @Body IS NULL)
			AND (L.Status = 1 AND @OnlyError = 1 OR @OnlyError = 0)
			AND (L.Error LIKE @Error OR @Error IS NULL)
		ORDER BY Date DESC
		OPTION(RECOMPILE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[MAILING_LOG_SELECT] TO rl_mailing_log_r;
GO
