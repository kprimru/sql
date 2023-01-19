﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[REG_NODE_REFRESH_FROM_DBF]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[REG_NODE_REFRESH_FROM_DBF]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[REG_NODE_REFRESH_FROM_DBF]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM Common.RegNode

	INSERT INTO Common.RegNode
		SELECT * FROM DBF.dbo.RegNodeTable
END
GO
