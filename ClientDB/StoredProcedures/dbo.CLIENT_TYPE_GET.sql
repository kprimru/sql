USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_TYPE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientTypeName, ClientTypeDay, ClientTypeDailyDay, ClientTypePapper
	FROM dbo.ClientTypeTable
	WHERE ClientTypeID = @ID
END