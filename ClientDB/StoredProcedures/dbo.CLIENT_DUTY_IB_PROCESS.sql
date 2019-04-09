USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DUTY_IB_PROCESS]
	@ClientDutyID INT,
	@IB VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @table TABLE (SysID INT)

	INSERT INTO @table
		SELECT *
		FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')

	DELETE 
	FROM dbo.ClientDutyIBTable 
	WHERE ClientDutyID = @ClientDutyID
		AND NOT EXISTS
			(
				SELECT *
				FROM @table
				WHERE SysID = SystemID
			)

	INSERT INTO dbo.ClientDutyIBTable(ClientDutyID, SystemID)
		SELECT @ClientDutyID, SysID
		FROM @table	
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDutyIBTable
				WHERE SysID = SystemID
					AND ClientDutyID = @ClientDutyID
			)
END