USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Install].[INSTALL_ACT_OVER_ONE] 
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = IA_ID_MASTER
	FROM Install.InstallActDetail
	WHERE IA_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_ACT', @MASTERID, @OLD OUTPUT

	
	UPDATE	Install.InstallActDetail
	SET		IA_END	=	@DATE,
			IA_REF	=	3
	WHERE	IA_ID	=	@IDLIST
	
	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_ACT', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INSTALL_ACT', '��������', @MASTERID, @OLD, @NEW

END
