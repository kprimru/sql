USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.SystemTypeTable
	SET SystemTypeName = @NAME
	WHERE SystemTypeID = @ID
END