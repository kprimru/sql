﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DIRECTION_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DIRECTION_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DIRECTION_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT NAME
	FROM dbo.Direction
	WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[DIRECTION_GET] TO rl_admin;
GO