﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_DELETE]
	@INS_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DEST VARCHAR(MAX)

	SET @DEST = ''

	SELECT	@DEST = @DEST + CONVERT(VARCHAR(50), IND_ID) + ','
	FROM	Install.InstallDetail
	WHERE	IND_ID_INSTALL	=	@INS_ID

	IF @DEST <> ''
		SET @DEST = LEFT(@DEST, LEN(@DEST) - 1)

	EXEC Install.INSTALL_DETAIL_DELETE @DEST

	DELETE
	FROM	Install.Install
	WHERE	INS_ID	=	@INS_ID
END
GO
GRANT EXECUTE ON [Install].[INSTALL_DELETE] TO rl_install_d;
GO
