USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Mailing].[EMAIL_INSERT]
@ID		INTEGER,
@EMAIL	VARCHAR(255)
AS
BEGIN
	UPDATE	Mailing.requests
	SET		Email=@EMAIL
	WHERE	ID=@ID
END
