USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[HALF_UPDATE]
	@HLF_ID			UNIQUEIDENTIFIER,
	@HLF_NAME		VARCHAR(50),
	@HLF_BEGIN_DATE	SMALLDATETIME,
	@HLF_END_DATE	SMALLDATETIME,
	@HLF_DATE		SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @HLF_ID_MASTER UNIQUEIDENTIFIER

	SELECT @HLF_ID_MASTER = HLF_ID_MASTER
	FROM Common.HalfDetail
	WHERE HLF_ID = @HLF_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'HALF', @HLF_ID_MASTER, @OLD OUTPUT


	UPDATE	Common.HalfDetail
	SET		HLF_NAME		=	@HLF_NAME,
			HLF_BEGIN_DATE	=	@HLF_BEGIN_DATE,
			HLF_END_DATE	=	@HLF_END_DATE,
			HLF_DATE		=	@HLF_DATE
	WHERE	HLF_ID			=	@HLF_ID

	UPDATE	Common.Half
	SET		HLFMS_LAST = GETDATE()
	WHERE	HLFMS_ID =
		(
			SELECT	HLF_ID_MASTER
			FROM	Common.HalfDetail
			WHERE	HLF_ID	=	@HLF_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'HALF', @HLF_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'HALF', '��������������', @HLF_ID_MASTER, @OLD, @NEW


END

GO
GRANT EXECUTE ON [Common].[HALF_UPDATE] TO rl_half_u;
GO
