USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RANGE_INSERT]	
	@VALUE	DECIMAL(8, 4),
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.RangeTable(RangeValue)
		VALUES(@VALUE)
		
	SELECT @ID = SCOPE_IDENTITY()
END