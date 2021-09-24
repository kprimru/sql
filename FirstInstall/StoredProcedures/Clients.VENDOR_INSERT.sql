USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Clients].[VENDOR_INSERT]
	@VD_NAME	VARCHAR(50),
	@VD_DATE	SMALLDATETIME,
	@VD_ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'VENDOR', NULL, @OLD OUTPUT


	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	DECLARE @MASTERID UNIQUEIDENTIFIER

	INSERT INTO Clients.Vendors(VDMS_ID)
	OUTPUT INSERTED.VDMS_ID INTO @TBL
	DEFAULT VALUES


	SELECT	@MASTERID = ID
	FROM	@TBL

	DELETE
	FROM	@TBL


	INSERT INTO
			Clients.VendorDetail(
				VD_NAME,
				VD_DATE,
				VD_ID_MASTER
			)
	OUTPUT INSERTED.VD_ID INTO @TBL(ID)
	VALUES	(
				@VD_NAME,
				@VD_DATE,
				@MASTERID
			)

	SELECT	@VD_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'VENDOR', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'VENDOR', '����� ������', @MASTERID, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Clients].[VENDOR_INSERT] TO rl_vendor_i;
GO
