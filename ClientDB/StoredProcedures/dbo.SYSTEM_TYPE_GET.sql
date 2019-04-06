USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_TYPE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemTypeName
	FROM dbo.SystemTypeTable
	WHERE SystemTypeID = @ID
END