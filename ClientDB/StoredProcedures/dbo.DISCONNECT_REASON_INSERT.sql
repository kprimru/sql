USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[DISCONNECT_REASON_INSERT]
	@NAME	VARCHAR(100),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.DisconnectReason(DR_NAME)
		OUTPUT INSERTED.DR_ID INTO @TBL
		VALUES(@NAME)
	
	SELECT @ID = ID
	FROM @TBL
END