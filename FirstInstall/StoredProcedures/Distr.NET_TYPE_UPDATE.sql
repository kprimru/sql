﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[NET_TYPE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Distr].[NET_TYPE_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Distr].[NET_TYPE_UPDATE]
	@NT_ID		UNIQUEIDENTIFIER,
	@NT_NAME	VARCHAR(50),
	@NT_SHORT	VARCHAR(50),
	@NT_FULL	VARCHAR(50),
	@NT_COEF	DECIMAL(8, 4),
	@NT_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @NT_ID_MASTER UNIQUEIDENTIFIER

	SELECT @NT_ID_MASTER = NT_ID_MASTER
	FROM Distr.NetTypeDetail
	WHERE NT_ID = @NT_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'NET_TYPE', @NT_ID_MASTER, @OLD OUTPUT


	UPDATE	Distr.NetTypeDetail
	SET		NT_NAME		=	@NT_NAME,
			NT_SHORT	=	@NT_SHORT,
			NT_FULL		=	@NT_FULL,
			NT_COEF		=	@NT_COEF,
			NT_DATE		=	@NT_DATE
	WHERE	NT_ID		=	@NT_ID

	UPDATE	Distr.NetType
	SET		NTMS_LAST	=	GETDATE()
	WHERE	NTMS_ID =
		(
			SELECT	NT_ID_MASTER
			FROM	Distr.NetTypeDetail
			WHERE	NT_ID	=	@NT_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'NET_TYPE', @NT_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'NET_TYPE', 'Редактирование', @NT_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Distr].[NET_TYPE_UPDATE] TO rl_net_type_u;
GO
