USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_PAY_DELETE]
	@SHP_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM Subhost.SubhostPayDetail
	WHERE SPD_ID_PAY = @SHP_ID

	DELETE
	FROM Subhost.SubhostPay
	WHERE SHP_ID = @SHP_ID
END