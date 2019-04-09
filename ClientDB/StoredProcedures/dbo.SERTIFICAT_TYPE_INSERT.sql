USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERTIFICAT_TYPE_INSERT]
	@NAME	VARCHAR(256),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)
	
	INSERT INTO dbo.SertificatType(NAME)
		OUTPUT inserted.ID INTO @TBL
		VALUES(@NAME)

	SELECT @ID = ID
	FROM @TBL
END
