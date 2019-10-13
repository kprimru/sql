USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SURNAME_POSITION_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ManagerName AS [������������], ServiceName AS [��], ClientFullName AS [������], Pers AS [�� ��������� ���������]
	FROM
		(
			SELECT 
				a.ClientFullName, a.ServiceName, a.ManagerName,
				CASE
					WHEN b.CP_FIO = c.CP_FIO AND b.CP_POS <> c.CP_POS THEN b.CP_FIO + ': ' + b.CP_POS + '/' + c.CP_POS
					WHEN b.CP_FIO = d.CP_FIO AND b.CP_POS <> d.CP_POS THEN b.CP_FIO + ': ' + b.CP_POS + '/' + d.CP_POS
					WHEN d.CP_FIO = c.CP_FIO AND d.CP_POS <> c.CP_POS THEN d.CP_FIO + ': ' + d.CP_POS + '/' + c.CP_POS
				END AS Pers
			FROM 
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
				INNER JOIN dbo.ClientPersonalDirView b WITH(NOEXPAND) ON a.ClientID = b.CP_ID_CLIENT
				INNER JOIN dbo.ClientPersonalBuhView c WITH(NOEXPAND) ON a.ClientID = c.CP_ID_CLIENT
				INNER JOIN dbo.ClientPersonalResView d WITH(NOEXPAND) ON a.ClientID = d.CP_ID_CLIENT
		) AS o_O
	WHERE PERS IS NOT NULL
	ORDER BY ManagerName, ServiceName, ClientFullName
END
