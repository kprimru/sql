USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Tender].[CLAIM_SAVE]
	@ID		UNIQUEIDENTIFIER,
	@TENDER	UNIQUEIDENTIFIER,
	@TP		TINYINT,
	@DATE	DATETIME,
	@PARAMS	NVARCHAR(MAX),
	@RETURN	NVARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON;

	SET @PARAMS = REPLACE(@PARAMS, CHAR(9), '')
	SET @PARAMS = REPLACE(@PARAMS, CHAR(13), '')

	UPDATE Tender.Claim
	SET CLAIM_DATE			=	@DATE,
		PARAMS				=	@PARAMS,
		PROVISION_RETURN	=	@RETURN
	WHERE ID = @ID
	
	IF @@ROWCOUNT = 0
		INSERT INTO Tender.Claim(ID_TENDER, TP, CLAIM_DATE, PARAMS, PROVISION_RETURN)
			VALUES(@TENDER, @TP, @DATE, @PARAMS, @RETURN)
END
