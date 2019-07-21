USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MAILING_TYPE_INSERT]
	@NAME	NVARCHAR(50),
	@ID		SMALLINT	OUTPUT
AS
BEGIN
	INSERT INTO
		Common.MailingType(MailingTypeName)
	VALUES
		(@NAME)

	SELECT @ID = SCOPE_IDENTITY()
END