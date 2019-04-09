USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_REG_NODE_ALL]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	SELECT R.*, S.SystemID, S.SystemShortName
	FROM dbo.RegNodeTable R
	LEFT JOIN dbo.SystemTable S ON S.SystemBaseName = R.SystemName
	ORDER BY S.SystemOrder
END