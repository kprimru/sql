﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FORM_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FORM_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[FORM_DELETE]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.Form
	WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[FORM_DELETE] TO rl_admin;
GO
