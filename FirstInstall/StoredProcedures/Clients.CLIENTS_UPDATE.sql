﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Clients].[CLIENTS_UPDATE]
	@CL_ID		UNIQUEIDENTIFIER,
	@CL_NAME	VARCHAR(150),
	@CL_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CL_ID_MASTER	UNIQUEIDENTIFIER

	SELECT @CL_ID_MASTER = CL_ID_MASTER
	FROM	Clients.ClientDetail
	WHERE	CL_ID = @CL_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'CLIENTS', @CL_ID_MASTER, @OLD OUTPUT


	UPDATE	Clients.ClientDetail
	SET		CL_NAME	=	@CL_NAME,
			CL_DATE	=	@CL_DATE
	WHERE	CL_ID	=	@CL_ID

	UPDATE	Clients.Clients
	SET		CLMS_LAST	=	GETDATE()
	WHERE	CLMS_ID	=
		(
			SELECT	CL_ID_MASTER
			FROM	Clients.ClientDetail
			WHERE	CL_ID = @CL_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'CLIENTS', @CL_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'CLIENTS', 'Редактирование', @CL_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Clients].[CLIENTS_UPDATE] TO rl_clients_u;
GO
