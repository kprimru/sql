USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[POSITION_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.PositionTypeTable
	SET PositionTypeName = @NAME
	WHERE PositionTypeID = @ID
END