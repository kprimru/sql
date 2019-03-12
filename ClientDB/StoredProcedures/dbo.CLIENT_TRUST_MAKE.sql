USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_TRUST_MAKE]	
	@ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientTrust
	SET CT_MAKE = GETDATE(),
		CT_MAKE_USER = ORIGINAL_LOGIN()
	WHERE CT_ID_CALL = @ID
END