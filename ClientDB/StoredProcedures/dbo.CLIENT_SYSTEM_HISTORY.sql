USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SYSTEM_HISTORY]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IDMaster AS ID, SystemBegin, NULL AS SystemEnd, SystemOp
	FROM
		(
			SELECT SystemBegin AS SystemOp
			FROM dbo.ClientSystemDatesTable
			WHERE IDMaster = @id
		
			UNION 

			SELECT SystemEnd
			FROM dbo.ClientSystemDatesTable
			WHERE IDMaster = @id
		) AS a INNER JOIN
		dbo.ClientSystemDatesTable b ON a.SystemOp = b.SystemBegin
	WHERE IDMaster = @id

	UNION

	SELECT IDMaster AS ID, NULL AS SystemBegin, SystemEnd, SystemOp
	FROM
		(
			SELECT SystemBegin AS SystemOp
			FROM dbo.ClientSystemDatesTable
			WHERE IDMaster = @id
		
			UNION 

			SELECT SystemEnd
			FROM dbo.ClientSystemDatesTable
			WHERE IDMaster = @id
		) AS a INNER JOIN
		dbo.ClientSystemDatesTable b ON a.SystemOp = b.SystemEnd
	WHERE IDMaster = @id
	ORDER BY SystemOp DESC
END