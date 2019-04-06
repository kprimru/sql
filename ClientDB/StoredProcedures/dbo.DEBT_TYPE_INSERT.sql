USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DEBT_TYPE_INSERT]	
	@SHORT	NVARCHAR(32),
	@NAME	NVARCHAR(128),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	INSERT INTO dbo.DebtType(SHORT, NAME)
		OUTPUT inserted.ID INTO @TBL
		VALUES(@SHORT, @NAME)
		
	SELECT @ID = ID FROM @TBL
END
