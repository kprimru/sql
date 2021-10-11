USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[DISTR_INSERT]
	@DS_NUM		INT,
	@DS_COMP	TINYINT,
	@SYS_ID		UNIQUEIDENTIFIER,
	@DT_ID		UNIQUEIDENTIFIER,
	@NT_ID		UNIQUEIDENTIFIER,
	@TT_ID		UNIQUEIDENTIFIER,
	@DH_DATE	SMALLDATETIME,
	@DH_ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'DISTR', NULL, @OLD OUTPUT



	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	DECLARE @HST_ID UNIQUEIDENTIFIER

	SELECT	@HST_ID = SYS_ID_HOST
	FROM	Distr.SystemLast
	WHERE	SYS_ID_MASTER	=	@SYS_ID

	DECLARE @DS_ID UNIQUEIDENTIFIER

	INSERT INTO Distr.DistrStore(DS_NUM, DS_COMP, DS_ID_HOST)
	OUTPUT INSERTED.DS_ID INTO @TBL
	VALUES(@DS_NUM, @DS_COMP, @HST_ID)

	SELECT	@DS_ID = ID
	FROM	@TBL

	DELETE
	FROM	@TBL

	INSERT INTO Distr.DistrHistory
			(
				DH_ID_DISTR, DH_ID_SYSTEM, DH_ID_NET,
				DH_ID_TYPE, DH_ID_TECH, DH_DATE
			)
	OUTPUT INSERTED.DH_ID INTO @TBL
	VALUES(@DS_ID, @SYS_ID, @NT_ID, @DT_ID, @TT_ID, @DH_DATE)

	SELECT	@DH_ID = ID
	FROM	@TBL


	EXEC Common.PROTOCOL_VALUE_GET 'DISTR', @DS_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'DISTR', '����� �����������', @DS_ID, @OLD, @NEW

END
GO
GRANT EXECUTE ON [Distr].[DISTR_INSERT] TO rl_distr_store_i;
GO
