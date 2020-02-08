USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SET STATISTICS IO ON
SET STATISTICS TIME ON

EXEC [dbo].[MAILING_LOG_SELECT]
	@DateFrom = '20200207'
	
EXEC [dbo].[MAILING_LOG_SELECT]
	@Address = 'marina.zdor@mail.ru'
*/
CREATE PROCEDURE [dbo].[MAILING_LOG_SELECT]
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
	SET @Address = NullIf(@Address, '') + '%';
	SET @Subject = '%' + NullIf(@Subject, '') + '%';
	SET @Body = '%' + NullIf(@Body, '') + '%';
	SET @Error = '%' + NullIf(@Error, '') + '%';
	SET @OnlyError = IsNull(@OnlyError, 0);

	SELECT
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
END
