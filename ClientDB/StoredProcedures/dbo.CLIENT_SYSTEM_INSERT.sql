USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SYSTEM_INSERT]
	@CLIENT	INT,
	@SYSTEM	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@STYPE	INT,
	@DTYPE	INT,
	@STATUS	UNIQUEIDENTIFIER,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ID		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientSystemsTable(
				ClientID, SystemID, SystemDistrNumber, CompNumber, SystemTypeID, DistrTypeID, DistrStatusID
			)
		VALUES(@CLIENT, @SYSTEM, @DISTR, @COMP, @STYPE, @DTYPE, @STATUS)

	SELECT @ID = SCOPE_IDENTITY()

	IF ((@BEGIN IS NOT NULL) OR (@END IS NOT NULL)) AND @ID IS NOT NULL
	BEGIN
		INSERT INTO dbo.ClientSystemDatesTable(IDMaster, SystemBegin, SystemEnd)
		VALUES (@ID, @BEGIN, @END)
	END
END