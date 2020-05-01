USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[WEIGHT_INSERT]
	@WG_NAME		VARCHAR(50),
	@WG_ID_SYSTEM	UNIQUEIDENTIFIER,
	@WG_VALUE		DECIMAL(8, 4),
	@WG_DATE		SMALLDATETIME,
	@WG_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'WEIGHT', NULL, @OLD OUTPUT


	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	DECLARE @MASTERID UNIQUEIDENTIFIER

	INSERT INTO Distr.Weight(WGMS_ID)
	OUTPUT INSERTED.WGMS_ID INTO @TBL
	DEFAULT VALUES

	SELECT	@MASTERID = ID
	FROM	@TBL

	DELETE
	FROM	@TBL


	INSERT INTO
			Distr.WeightDetail(
				WG_NAME,
				WG_ID_SYSTEM,
				WG_VALUE,
				WG_DATE,
				WG_ID_MASTER
			)
	OUTPUT INSERTED.WG_ID INTO @TBL(ID)
	VALUES	(
				@WG_NAME,
				@WG_ID_SYSTEM,
				@WG_VALUE,
				@WG_DATE,
				@MASTERID
			)

	SELECT	@WG_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'WEIGHT', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'WEIGHT', '����� ������', @MASTERID, @OLD, @NEW

END

GRANT EXECUTE ON [Distr].[WEIGHT_INSERT] TO rl_weight_i;
GO