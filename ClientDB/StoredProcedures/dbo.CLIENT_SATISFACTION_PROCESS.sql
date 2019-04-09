USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SATISFACTION_PROCESS]
	@CALL	UNIQUEIDENTIFIER,
	@TYPE	UNIQUEIDENTIFIER,
	@NOTE	VARCHAR(MAX),
	@CTYPE	TINYINT,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CS_ID UNIQUEIDENTIFIER

	SELECT @CS_ID = CS_ID
	FROM dbo.ClientSatisfaction
	WHERE CS_ID_CALL = @CALL

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	IF @CS_ID IS NULL
	BEGIN
		INSERT INTO dbo.ClientSatisfaction(CS_ID_CALL, CS_ID_TYPE, CS_NOTE, CS_TYPE)
			OUTPUT INSERTED.CS_ID INTO @TBL
			VALUES(@CALL, @TYPE, @NOTE, @CTYPE)

		SELECT @ID = ID FROM @TBL
	END
	ELSE
	BEGIN
		UPDATE dbo.ClientSatisfaction
		SET CS_ID_TYPE = @TYPE,
			CS_NOTE = @NOTE,
			CS_TYPE = @CTYPE
		WHERE CS_ID_CALL = @CALL

		SELECT @ID = @CS_ID
	END
END