USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_FINANCING_SAVE]
	@ID INT,
	@BILL_GROUP BIT,
	@BILL_MASS_PRINT BIT = 1,
	@UNKNOWN	BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientFinancing
	SET BILL_GROUP = @BILL_GROUP,
		BILL_MASS_PRINT = @BILL_MASS_PRINT,
		UNKNOWN_FINANCING = @UNKNOWN
	WHERE ID_CLIENT = @ID
END
