USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DELIVERY_SAVE]
	@ID		UNIQUEIDENTIFIER,
	@CLIENT	INT,
	@DELIVERY	UNIQUEIDENTIFIER,
	@EMAIL		NVARCHAR(128),
	@NOTE		NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
		INSERT INTO dbo.ClientDelivery(ID_CLIENT, ID_DELIVERY, EMAIL, START, NOTE)
			SELECT @CLIENT, @DELIVERY, @EMAIL, dbo.DateOf(GETDATE()), @NOTE
	ELSE
		UPDATE dbo.ClientDelivery
		SET	ID_DELIVERY = @DELIVERY,
			EMAIL		= @EMAIL,
			NOTE	=	@NOTE
		WHERE ID = @ID
END
