﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_INSERT]
	@CL_ID		UNIQUEIDENTIFIER,
	@VD_ID		UNIQUEIDENTIFIER,
	@INS_DATE	SMALLDATETIME,
	@INS_ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL', NULL, @OLD OUTPUT




	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	INSERT INTO Install.Install(INS_ID_CLIENT, INS_ID_VENDOR, INS_DATE)
	OUTPUT INSERTED.INS_ID INTO @TBL
	VALUES(@CL_ID, @VD_ID, @INS_DATE)

	SELECT @INS_ID = ID
	FROM @TBL

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL', @INS_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INSTALL', 'Новая запись', @INS_ID, @OLD, @NEW

END
GO
GRANT EXECUTE ON [Install].[INSTALL_INSERT] TO rl_install_i;
GO
