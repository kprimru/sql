USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT]
	@CLIENT	INT,
	@ADD	BIT,
	@SPEC	BIT
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#contract') IS NOT NULL
		DROP TABLE #contract
	
	CREATE TABLE #contract(ID UNIQUEIDENTIFIER PRIMARY KEY)
	
	INSERT INTO #contract(ID)
		SELECT DISTINCT ID_CONTRACT
		FROM 
			Contract.ClientContract a
		WHERE a.ID_CLIENT = @CLIENT
		
	SELECT b.ID, c.NAME, b.NUM_S, b.DATE, b.NOTE
	FROM 
		#contract a
		INNER JOIN Contract.Contract b ON a.ID = b.ID
		INNER JOIN dbo.Vendor c ON c.ID = b.ID_VENDOR
		
	
	IF OBJECT_ID('tempdb..#contract') IS NOT NULL
		DROP TABLE #contract
END
