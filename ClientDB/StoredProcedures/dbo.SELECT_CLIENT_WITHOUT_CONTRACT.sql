USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SELECT_CLIENT_WITHOUT_CONTRACT]
	@managerid INT = NULL,
	@statusid INT = 2
AS
BEGIN
	SET NOCOUNT ON

if @managerid IS NOT NULL
  begin
	DECLARE @t TABLE (Item INT)

	IF (@managerid = 19) OR (@managerid = 11)
		INSERT INTO @t
			SELECT 19 AS Item
			UNION 
			SELECT 11 AS Item
	ELSE
		INSERT INTO @t
			SELECT @managerid AS Item


    SELECT ClientID, ClientFullName, ServiceName
    FROM dbo.ClientTable LEFT OUTER JOIN
               dbo.ServiceTable ON ClientTable.ClientServiceID = ServiceTable.ServiceID
    WHERE (NOT EXISTS(SELECT ContractNumber FROM dbo.ContractTable WHERE ContractTable.ClientID = ClientTable.CLientID)) AND ManagerID IN (SELECT Item FROM @t) AND StatusID = @statusid
    ORDER BY ServiceName, ClientFullName
  end
else
  begin
    
    SELECT ClientID, ClientFullName, ServiceName
    FROM dbo.ClientTable LEFT OUTER JOIN
               dbo.ServiceTable ON ClientTable.ClientServiceID = ServiceTable.ServiceID
    WHERE (NOT EXISTS(SELECT ContractNumber FROM dbo.ContractTable WHERE ContractTable.ClientID = ClientTable.CLientID)) AND StatusID = @statusid
    ORDER BY ServiceName, ClientFullName
  end
END