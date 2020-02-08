USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MAILING_LOG_ADD]
	@TypeCode	VarChar(100),
	@Address	VarChar(256),
	@Subject	VarCHar(256),
	@Body		VarCHar(Max),
	@Error		VarChar(Max)
AS
BEGIN
	SET @Error = NullIf(@Error, '');

	INSERT INTO Common.MailingLog([TypeID], [Address], [Subject], [Body], [Status], [Error])	
	SELECT MailingTypeId, @Address, @Subject, @Body, CASE WHEN @Error IS NULL THEN 0 ELSE 1 END, @Error
	FROM Common.MailingType
	WHERE [MailingTypeCode] = @TypeCode
END
