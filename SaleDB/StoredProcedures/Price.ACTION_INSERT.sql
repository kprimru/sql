USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[ACTION_INSERT]
	@NAME			NVARCHAR(128),
	@DELIVERY		SMALLINT,
	@SUPPORT		SMALLINT,
	@DELIVERY_FIXED	MONEY,
	@ID				UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Price.Action(NAME, DELIVERY, SUPPORT, DELIVERY_FIXED)
		OUTPUT inserted.ID INTO @TBL
		VALUES(@NAME, @DELIVERY, @SUPPORT, @DELIVERY_FIXED)
		
	SELECT @ID = ID
	FROM @TBL
END
