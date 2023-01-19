﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Install].[INSTALL_DETAIL_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Install].[INSTALL_DETAIL_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Install].[INSTALL_DETAIL_UPDATE]
	@IND_ID			UNIQUEIDENTIFIER,
	@SYS_ID			UNIQUEIDENTIFIER,
	@DT_ID			UNIQUEIDENTIFIER,
	@NT_ID			UNIQUEIDENTIFIER,
	@TT_ID			UNIQUEIDENTIFIER,
	@IND_LOCK		BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @IND_ID, @OLD OUTPUT


	UPDATE	Install.InstallDetail
	SET		IND_ID_SYSTEM	=	@SYS_ID,
			IND_ID_TYPE		=	@DT_ID,
			IND_ID_NET		=	@NT_ID,
			IND_ID_TECH		=	@TT_ID, 
			IND_LOCK		=	@IND_LOCK
	WHERE	IND_ID			=	@IND_ID

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @IND_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INSTALL_DETAIL', 'Редактирование', @IND_ID, @OLD, @NEW
END
GO
GRANT EXECUTE ON [Install].[INSTALL_DETAIL_UPDATE] TO rl_install_u;
GO
