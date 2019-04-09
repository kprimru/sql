USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SYSTEM_GET]
	@ID		INT,
	@CLIENT	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NOT NULL
	BEGIN
		SELECT 
			ID, 
			SystemID, SystemDistrNumber, CompNumber,		
			SystemTypeID, DistrTypeID, 
			SystemStatusID, DistrStatusID,
			(
				SELECT TOP 1 SystemBegin 
				FROM dbo.ClientSystemDatesTable
				WHERE IDMaster = a.ID
				ORDER BY SystemDate DESC
			) AS SystemBegin,
			(
				SELECT TOP 1 SystemEnd 
				FROM dbo.ClientSystemDatesTable
				WHERE IDMaster = a.ID
				ORDER BY SystemDate DESC
			) AS SystemEnd
		FROM dbo.ClientSystemsTable a
		WHERE ID = @ID
	END
	ELSE
	BEGIN
		SELECT TOP 1			
			NULL AS ID, 
			SystemID, SystemDistrNumber, CompNumber,		
			CONVERT(INT, NULL) AS SystemTypeID, CONVERT(INT, NULL) AS DistrTypeID, 
			CONVERT(INT, NULL) AS SystemStatusID, CONVERT(UNIQUEIDENTIFIER, (SELECT TOP 1 DS_ID FROM dbo.DistrStatus WHERE DS_REG = 0)) AS DistrStatusID,
			CONVERT(SMALLDATETIME, RegisterDate, 104) AS SystemBegin,
			CONVERT(SMALLDATETIME, NULL) AS SystemEnd
		FROM
			(
				SELECT 
					c.SystemID, c.DistrNumber AS SystemDistrNumber, c.CompNumber AS CompNumber,
					c.RegisterDate
				FROM
					dbo.ClientSystemView a WITH(NOEXPAND) 
					INNER JOIN dbo.RegNodeCurrentView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
									AND b.DistrNumber = a.SystemDistrNumber
									AND b.CompNumber = a.CompNumber
					INNER JOIN dbo.RegNodeCurrentView c WITH(NOEXPAND) ON c.Complect = b.Complect						
				WHERE  ClientID = @CLIENT
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.ClientSystemView z WITH(NOEXPAND) 
							WHERE /*z.ClientID = @CLIENTID
								AND */z.SystemID = c.SystemID
								AND z.SystemDistrNumber = c.DistrNumber
								AND z.CompNumber = c.CompNumber
						)
			) AS o_O
	END
END