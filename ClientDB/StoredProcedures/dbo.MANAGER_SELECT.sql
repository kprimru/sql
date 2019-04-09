USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MANAGER_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT 
		ManagerID, ManagerName, ManagerLogin, ManagerCount,
		CONVERT(BIT, CASE WHEN ManagerCount <> 0 AND ManagerName <> 'Исаева' THEN 1 ELSE 0 END) AS ManagerCheck,
		CASE WHEN ManagerCount = 0 THEN 1 ELSE 0 END AS ManagerEnable, ManagerLocal
	FROM
		(
			SELECT 
				ManagerID, ManagerName, ManagerLogin, ManagerLocal,
				(
					SELECT COUNT(*)
					FROM 
						dbo.ServiceTable b
						INNER JOIN dbo.ClientTable c ON c.ClientServiceID = b.ServiceID
					WHERE b.ManagerID = a.ManagerID AND StatusID = 2 AND STATUS = 1
				) AS ManagerCount
			FROM dbo.ManagerTable a
			WHERE @FILTER IS NULL
				OR ManagerName LIKE @FILTER
				OR ManagerFullName LIKE @FILTER
				OR ManagerLogin LIKE @FILTER
		) AS o_O
	ORDER BY ManagerName
END