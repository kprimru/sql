USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CALL_NOTE]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		CC_DATE AS [���� ������], ClientFullName AS [������], CC_PERSONAL AS [���������], 
		CC_NOTE AS [����������], CC_USER AS [��� ������], CC_SERVICE AS [��]
	FROM 
		dbo.ClientCall a
		INNER JOIN dbo.ClientView b ON a.CC_ID_CLIENT = b.ClientID
	WHERE CC_NOTE <> ''
	ORDER BY CC_DATE DESC
END
