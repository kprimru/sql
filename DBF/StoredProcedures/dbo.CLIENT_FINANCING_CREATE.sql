USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_FINANCING_CREATE]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientFinancing(ID_CLIENT, BILL_GROUP)
		VALUES(@ID, 0)
END
