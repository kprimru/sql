USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_PREPARE]
	@CLIENT	INT,
	@TEXT	VARCHAR(100) = NULL OUTPUT,
	@COLOR	INT	= NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SET @TEXT = NULL
	
	SET @COLOR = 0

	IF NOT EXISTS
		(
			SELECT *
			FROM dbo.ContractTable 
			WHERE ClientID = @CLIENT
				AND GETDATE() BETWEEN ContractBegin AND ContractEnd
		) AND 
		(
			SELECT StatusID
			FROM dbo.ClientTable
			WHERE ClientID = @CLIENT
		) = 2
		SET @COLOR = 1
	ELSE IF EXISTS
		(
			SELECT *
			FROM dbo.ContractTable
			WHERE ClientID = @CLIENT
				AND (ContractEnd BETWEEN GetDate() AND DATEADD(MONTH, 1, GETDATE()))
		) AND 
		(
			SELECT StatusID
			FROM dbo.ClientTable
			WHERE ClientID = @CLIENT
		) = 2
		SET @COLOR = 2
END