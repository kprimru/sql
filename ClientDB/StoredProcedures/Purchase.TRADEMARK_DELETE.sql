USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[TRADEMARK_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM Purchase.ClientConditionTrademark
	WHERE CCT_ID_TM = @ID

	DELETE
	FROM Purchase.Trademark
	WHERE TM_ID = @ID
END