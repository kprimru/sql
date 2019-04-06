USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Install].[INSTALL_ACT_UPDATE]
	@IA_ID		UNIQUEIDENTIFIER,
	@IA_NAME	VARCHAR(50),
	@IA_NORM	BIT,
	@IA_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @IA_ID_MASTER UNIQUEIDENTIFIER
	
	SELECT @IA_ID_MASTER = IA_ID_MASTER
	FROM Install.InstallActDetail
	WHERE IA_ID = @IA_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_ACT', @IA_ID_MASTER, @OLD OUTPUT


	UPDATE	Install.InstallActDetail
	SET		IA_NAME		=	@IA_NAME,
			IA_NORM		=	@IA_NORM,
			IA_DATE		=	@IA_DATE
	WHERE	IA_ID		=	@IA_ID 

	UPDATE	Install.InstallAct
	SET		IAMS_LAST	=	GETDATE()
	WHERE	IAMS_ID =
		(
			SELECT	IA_ID_MASTER
			FROM	Install.InstallActDetail	
			WHERE	IA_ID	=	@IA_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_ACT', @IA_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INSTALL_ACT', '��������������', @IA_ID_MASTER, @OLD, @NEW

END
