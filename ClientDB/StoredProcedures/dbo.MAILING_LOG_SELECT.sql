USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MAILING_LOG_SELECT]
	@TYPE		SMALLINT = '',
	@ADDRESS	NVARCHAR(255) = '',
	@SUBJECT	NVARCHAR(100) = '',
	@BODY		NVARCHAR(MAX) = '',
	@STATUS		SMALLINT = 0,
	@ERROR		NVARCHAR(100) = ''
AS
BEGIN
	IF @ERROR <> ''
		SET @STATUS = 1

	SELECT
		Date, MailingTypeName, ml.address, ml.subject, ml.body, ml.status, ml.error
	FROM
		Common.MailingLog ml
		INNER JOIN Common.MailingType mt ON ml.TypeID=mt.MailingTypeId
	WHERE
		(ISNULL(@TYPE, '') = '' OR @TYPE = mt.MailingTypeId)AND
		(@ADDRESS = '' OR ml.address LIKE '%'+@ADDRESS+'%')AND
		(@SUBJECT = '' OR ml.subject LIKE '%'+@SUBJECT+'%')AND
		(@BODY = '' OR ml.body LIKE '%'+@BODY+'%')AND
		(@ERROR = '' OR ml.error LIKE '%'+@ERROR+'%')AND
		(ml.status = @STATUS OR @STATUS = 0)
	ORDER BY Date DESC
END
