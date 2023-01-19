﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ERROR_RAISE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ERROR_RAISE]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ERROR_RAISE]
	@SEV	INT,
	@STATE	INT,
	@NUM	INT,
	@PROC	NVARCHAR(128),
	@MSG	NVARCHAR(2048)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Security.ErrorLog(NUM, PROC_NAME, MESSAGE)
		VALUES(@NUM, @PROC, @MSG)

	DECLARE @TXT NVARCHAR(3000)

	SET @TXT = 'Ошибка в процедуре "' + ISNULL(@PROC, '') + '". Текст ошибки: "' + ISNULL(@MSG, '') + '"'

	RAISERROR(@TXT, @SEV, @STATE)
END
GO
