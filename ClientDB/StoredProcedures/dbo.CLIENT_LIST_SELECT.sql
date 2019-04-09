USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_LIST_SELECT]
AS
BEGIN
	SET NOCOUNT ON;	

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	IF OBJECT_ID('tempdb..#rclient') IS NOT NULL
		DROP TABLE #rclient
	IF OBJECT_ID('tempdb..#wclient') IS NOT NULL
		DROP TABLE #wclient

	SELECT RCL_ID
		INTO #rclient
	FROM dbo.ClientReadList()

	SELECT WCL_ID
		INTO #wclient
	FROM dbo.ClientWriteList()

	CREATE TABLE #client
		( 
			CL_ID INT PRIMARY KEY
		)
			
	INSERT INTO #client(CL_ID)
		SELECT RCL_ID
		FROM 
			(
				SELECT RCL_ID
				FROM #rclient		
			) AS o_O				
		

	SELECT 
		ClientID, 
		CASE 
			WHEN WCL_ID IS NULL THEN CONVERT(BIT, 0)
			ELSE CONVERT(BIT, 1)
		END AS ClientEdit
	FROM 
		#client
		INNER JOIN dbo.ClientTable a ON a.ClientID = CL_ID
		LEFT OUTER JOIN #wclient ON CL_ID = WCL_ID
	ORDER BY ClientID	

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
	IF OBJECT_ID('tempdb..#rclient') IS NOT NULL
		DROP TABLE #rclient
	IF OBJECT_ID('tempdb..#wclient') IS NOT NULL
		DROP TABLE #wclient
END