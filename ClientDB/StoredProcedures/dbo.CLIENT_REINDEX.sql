USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_REINDEX]
	@ID		INT = NULL,
	@LIST	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#client_list') IS NOT NULL
		DROP TABLE #client_list
		
	CREATE TABLE #client_list
		(
			CL_ID	INT PRIMARY KEY
		)
		
	IF @ID IS NOT NULL
		INSERT INTO #client_list(CL_ID)
			VALUES(@ID)
	ELSE IF @LIST IS NOT NULL
		INSERT INTO #client_list(CL_ID)
			SELECT ID
			FROM dbo.TableIDFromXML(@LIST)
	ELSE
		INSERT INTO #client_list(CL_ID)
			SELECT ClientID
			FROM dbo.ClientTable
			
	
	UPDATE dbo.ClientIndex
	SET DATA = ClientData
	FROM 
		#client_list
		INNER JOIN dbo.ClientIndex ON CL_ID = ID_CLIENT
		INNER JOIN dbo.ClientIndexView ON ClientID = ID_CLIENT
		
	INSERT INTO dbo.ClientIndex(ID_CLIENT, DATA)
		SELECT CL_ID, ClientData
		FROM 
			#client_list
			INNER JOIN dbo.ClientIndexView ON CL_ID = ClientID
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientIndex
				WHERE ID_CLIENT = CL_ID
			)
		
	IF OBJECT_ID('tempdb..#client_list') IS NOT NULL
		DROP TABLE #client_list
END