USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[DISTR_TYPE_UPDATE]
	@DT_ID		UNIQUEIDENTIFIER,
	@DT_NAME	VARCHAR(50),
	@DT_SHORT	VARCHAR(50),
	@DT_REG		VARCHAR(50),
	@DT_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @DT_ID_MASTER UNIQUEIDENTIFIER

	SELECT @DT_ID_MASTER = DT_ID_MASTER
	FROM Distr.DistrTypeDetail
	WHERE DT_ID = @DT_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'DISTR_TYPE', @DT_ID_MASTER, @OLD OUTPUT



	UPDATE	Distr.DistrTypeDetail
	SET		DT_NAME		=	@DT_NAME,
			DT_SHORT	=	@DT_SHORT,
			DT_REG		=	@DT_REG,
			DT_DATE		=	@DT_DATE
	WHERE	DT_ID		=	@DT_ID

	UPDATE	Distr.DistrType
	SET		DTMS_LAST	=	GETDATE()
	WHERE	DTMS_ID =
		(
			SELECT	DT_ID_MASTER
			FROM	Distr.DistrTypeDetail
			WHERE	DT_ID	=	@DT_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'DISTR_TYPE', @DT_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'DISTR_TYPE', '��������������', @DT_ID_MASTER, @OLD, @NEW

END

GRANT EXECUTE ON [Distr].[DISTR_TYPE_UPDATE] TO rl_distr_type_u;
GO