USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ACTIVITY_INSERT]
	@NAME	VARCHAR(500),
	@CODE	VARCHAR(20),
	@SHORT	VARCHAR(100),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.Activity(AC_NAME, AC_CODE, AC_SHORT)
		OUTPUT INSERTED.AC_ID INTO @TBL
		VALUES(@NAME, @CODE, @SHORT)

	SELECT @ID = ID FROM @TBL
END