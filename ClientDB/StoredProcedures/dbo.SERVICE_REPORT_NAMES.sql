USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SERVICE_REPORT_NAMES]
	@SERVICE	INT,
	@MANAGER	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SELECT ServiceFullName, ManagerFullName
		FROM 
			dbo.ServiceTable a
			INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
		WHERE ServiceID = @SERVICE
	ELSE IF @MANAGER IS NOT NULL
		SELECT NULL AS ServiceFullName, ManagerFullName
		FROM dbo.ManagerTable
		WHERE ManagerID = @MANAGER
	ELSE 
		SELECT NULL AS ServiceFullName, NULL AS ManagerFullName
END