USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [USR].[PROCESSOR_FAMILY_INSERT]
	@NAME	VARCHAR(150),
	@ID		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO USR.ProcessorFamily(PF_NAME)
		VALUES(@NAME)

	SELECT @ID = SCOPE_IDENTITY()
END