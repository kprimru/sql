﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SCAN_DOCUMENT_RES]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SCAN_DOCUMENT_RES]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SCAN_DOCUMENT_RES]
	@ID			INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ScanDocument
	SET RES = GETDATE()
	WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[SCAN_DOCUMENT_RES] TO rl_user;
GO