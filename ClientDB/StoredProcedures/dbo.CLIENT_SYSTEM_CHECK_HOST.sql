USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SYSTEM_CHECK_HOST]
	@ID		INT,
	@SYS	INT,
	@DISTR	INT,
	@COMP	TINYINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @HST INT

	SELECT @HST = HostID
	FROM dbo.SystemTable
	WHERE SystemID = @SYS

	SELECT ID
	FROM 
		dbo.ClientSystemsTable a
		INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID		
	WHERE HostID = @HST AND SystemDistrNumber = @DISTR AND CompNumber = @COMP
		AND (a.ID <> @ID OR @ID IS NULL)
END