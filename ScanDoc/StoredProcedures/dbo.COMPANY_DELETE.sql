﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[COMPANY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[COMPANY_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[COMPANY_DELETE]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.Company
	WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[COMPANY_DELETE] TO rl_admin;
GO
