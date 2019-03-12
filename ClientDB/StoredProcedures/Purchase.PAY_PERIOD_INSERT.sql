USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[PAY_PERIOD_INSERT]
	@NAME	VARCHAR(500),
	@SHORT	VARCHAR(100),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Purchase.PayPeriod(PP_NAME, PP_SHORT)
		OUTPUT inserted.PP_ID INTO @TBL
		VALUES(@NAME, @SHORT)
		
	SELECT @ID = ID
	FROM @TBL
END