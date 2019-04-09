USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[POSITION_TYPE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PositionTypeName
	FROM dbo.PositionTypeTable
	WHERE PositionTypeID = @ID
END