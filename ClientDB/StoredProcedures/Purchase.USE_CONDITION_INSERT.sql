USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[USE_CONDITION_INSERT]
	@NAME	VARCHAR(MAX),
	@SHORT	VARCHAR(200),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Purchase.UseCondition(UC_NAME, UC_SHORT)
		OUTPUT inserted.UC_ID INTO @TBL
		VALUES(@NAME, @SHORT)
		
	SELECT @ID = ID
	FROM @TBL
END