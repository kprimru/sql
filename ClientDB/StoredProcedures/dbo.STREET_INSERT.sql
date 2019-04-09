USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STREET_INSERT]	
	@CITY	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(150),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.Street(ST_ID_CITY, ST_NAME, ST_PREFIX, ST_SUFFIX)
		OUTPUT INSERTED.ST_ID INTO @TBL
		VALUES(@CITY, @NAME, @PREFIX, @SUFFIX)

	SELECT @ID = ID
	FROM @TBL
END