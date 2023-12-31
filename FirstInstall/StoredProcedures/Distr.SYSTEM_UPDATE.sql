USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[SYSTEM_UPDATE]
	@SYS_ID			UNIQUEIDENTIFIER,
	@SYS_NAME		VARCHAR(50),
	@SYS_SHORT		VARCHAR(50),
	@SYS_DATE		SMALLDATETIME,
	@SYS_REG		VARCHAR(50),
	@SYS_ORDER		INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @SYS_ID_MASTER UNIQUEIDENTIFIER

	SELECT @SYS_ID_MASTER = SYS_ID_MASTER
	FROM Distr.SystemDetail
	WHERE SYS_ID = @SYS_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'SYSTEM', @SYS_ID_MASTER, @OLD OUTPUT


	UPDATE	Distr.SystemDetail
	SET		SYS_NAME	=	@SYS_NAME,
			SYS_SHORT	=	@SYS_SHORT,
			SYS_DATE	=	@SYS_DATE,
			SYS_REG		=	@SYS_REG,
			SYS_ORDER	=	@SYS_ORDER
	WHERE	SYS_ID		=	@SYS_ID

	UPDATE	Distr.Systems
	SET		SYSMS_LAST = GETDATE()
	WHERE	SYSMS_ID =
		(
			SELECT	SYS_ID_MASTER
			FROM	Distr.SystemDetail
			WHERE	SYS_ID	=	@SYS_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'SYSTEM', @SYS_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'SYSTEM', '��������������', @SYS_ID_MASTER, @OLD, @NEW

	--EXEC [Distr].[SYSTEM_WEIGHT]
END

GO
GRANT EXECUTE ON [Distr].[SYSTEM_UPDATE] TO rl_system_u;
GO
