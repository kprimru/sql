USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CONS_EXE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ConsExeVersionName, ConsExeVersionActive, ConsExeVersionBegin, ConsExeVersionEnd
	FROM dbo.ConsExeVersionTable
	WHERE ConsExeVersionID = @ID	
END