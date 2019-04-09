USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[COMMERCIAL_OPERATION_INSERT]
	@NAME	NVARCHAR(128),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Price.CommercialOperation(NAME)
		OUTPUT inserted.ID INTO @TBL
		VALUES(@NAME)
		
	SELECT @ID = ID
	FROM @TBL
END