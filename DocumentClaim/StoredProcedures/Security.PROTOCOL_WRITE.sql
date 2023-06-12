﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[PROTOCOL_WRITE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[PROTOCOL_WRITE]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[PROTOCOL_WRITE]
	@TYPE	NVARCHAR(64),
	@NOTE	NVARCHAR(512)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Security.Protocol(TYPE, NOTE)
		VALUES(@TYPE, @NOTE)
END
GO
