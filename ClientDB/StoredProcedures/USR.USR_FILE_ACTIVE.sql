USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[USR_FILE_ACTIVE]
	@UF_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE USR.USRFile
	SET UF_ACTIVE = 
			CASE UF_ACTIVE 
				WHEN 1 THEN 0 
				WHEN 0 THEN 1 
				ELSE NULL
			END
	WHERE UF_ID = @UF_ID
END