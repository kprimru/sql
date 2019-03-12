USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[SIGN_PERIOD_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SP_NAME, SP_SHORT
	FROM Purchase.SignPeriod
	WHERE SP_ID = @ID
END