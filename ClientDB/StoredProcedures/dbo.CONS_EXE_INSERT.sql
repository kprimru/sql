USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONS_EXE_INSERT]	
	@NAME	VARCHAR(50),
	@ACTIVE	BIT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ConsExeVersionTable(ConsExeVersionName, 
			ConsExeVersionActive, ConsExeVersionBegin, ConsExeVersionEnd)
		VALUES(@NAME, @ACTIVE, @BEGIN, @END)

	SELECT @ID = SCOPE_IDENTITY()
END