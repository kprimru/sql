USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Clients].[VENDOR_UPDATE]
	@VD_ID		UNIQUEIDENTIFIER,
	@VD_NAME	VARCHAR(50),
	@VD_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @VD_ID_MASTER UNIQUEIDENTIFIER

	SELECT @VD_ID_MASTER = VD_ID_MASTER
	FROM Clients.VendorDetail
	WHERE VD_ID = @VD_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'VENDOR', @VD_ID_MASTER, @OLD OUTPUT



	UPDATE	Clients.VendorDetail
	SET		VD_NAME	=	@VD_NAME,
			VD_DATE	=	@VD_DATE
	WHERE	VD_ID	=	@VD_ID

	UPDATE	Clients.Vendor
	SET		VDMS_LAST = GETDATE()
	WHERE	VDMS_ID	=
		(
			SELECT	VD_ID_MASTER
			FROM	Clients.VendorDetail
			WHERE	VD_ID	=	@VD_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'VENDOR', @VD_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'VENDOR', '��������������', @VD_ID_MASTER, @OLD, @NEW
END

GO
GRANT EXECUTE ON [Clients].[VENDOR_UPDATE] TO rl_vendor_u;
GO
