USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[STT_ARCH_LOAD]
	@SUBHOST	UNIQUEIDENTIFIER,
	@USR		NVARCHAR(128),
	@BIN		VARBINARY(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Subhost.STTFiles(ID_SUBHOST, USR, BIN)
		VALUES(@SUBHOST, @USR, @BIN)
END
