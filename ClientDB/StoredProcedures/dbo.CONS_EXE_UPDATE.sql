USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONS_EXE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@ACTIVE	BIT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsExeVersionTable
	SET ConsExeVersionName = @NAME,
		ConsExeVersionActive = @ACTIVE,
		ConsExeVersionBegin = @BEGIN,
		ConsExeVersionEnd = @END
	WHERE ConsExeVersionID = @ID	
END