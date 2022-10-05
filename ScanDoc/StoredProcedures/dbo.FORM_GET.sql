﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FORM_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FORM_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[FORM_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT NAME
	FROM dbo.Form
	WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[FORM_GET] TO rl_admin;
GO