USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[OS_INSERT]
	@NAME	VARCHAR(100),
	@MIN	SMALLINT,
	@MAJ	SMALLINT,
	@BUILD	SMALLINT,
	@PLATFORM	TINYINT,
	@EDITION	VARCHAR(100),
	@CAPACITY	VARCHAR(50),
	@LANG		VARCHAR(50),
	@COMPATIBILITY	VARCHAR(100),
	@FAMILY	INT,
	@ID		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO USR.OS(OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM, OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY, OS_ID_FAMILY)
		VALUES(@NAME, @MIN, @MAJ, @BUILD, @PLATFORM, @EDITION, @CAPACITY, @LANG, @COMPATIBILITY, @FAMILY)
	
	SELECT @ID = SCOPE_IDENTITY()
END