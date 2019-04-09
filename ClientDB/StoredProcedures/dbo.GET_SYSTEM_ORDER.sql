USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SYSTEM_ORDER]
AS
BEGIN
	SET NOCOUNT ON

	SELECT SystemID, SystemShortName 
	FROM dbo.SystemTable 
	ORDER BY SystemOrder, SystemShortName
END