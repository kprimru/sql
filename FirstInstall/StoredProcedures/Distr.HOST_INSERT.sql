USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[HOST_INSERT]
	@HST_NAME	VARCHAR(250),
	@HST_REG	VARCHAR(50),
	@HST_DATE	SMALLDATETIME,
	@HST_ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'HOST', NULL, @OLD OUTPUT


	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	DECLARE @MASTERID UNIQUEIDENTIFIER

	INSERT INTO Distr.Hosts(HSTMS_ID)
	OUTPUT INSERTED.HSTMS_ID INTO @TBL
	DEFAULT VALUES


	SELECT	@MASTERID = ID
	FROM	@TBL

	DELETE
	FROM	@TBL


	INSERT INTO
			Distr.HostDetail(
				HST_NAME,
				HST_REG,
				HST_DATE,
				HST_ID_MASTER
			)
	OUTPUT INSERTED.HST_ID INTO @TBL(ID)
	VALUES	(
				@HST_NAME,
				@HST_REG,
				@HST_DATE,
				@MASTERID
			)

	SELECT	@HST_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'HOST', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'HOST', '����� ������', @MASTERID, @OLD, @NEW


END

GO
GRANT EXECUTE ON [Distr].[HOST_INSERT] TO rl_host_i;
GO
