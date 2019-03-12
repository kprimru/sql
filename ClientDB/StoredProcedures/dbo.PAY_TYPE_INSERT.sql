USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[PAY_TYPE_INSERT]	
	@NAME	VARCHAR(100),
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.PayTypeTable(PayTypeName)
		VALUES(@NAME)
	
	SELECT @ID = SCOPE_IDENTITY()
END