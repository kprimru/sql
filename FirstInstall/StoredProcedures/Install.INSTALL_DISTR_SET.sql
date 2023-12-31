USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Install].[INSTALL_DISTR_SET]
	@IND_ID	UNIQUEIDENTIFIER,
	@DS_ID	VARCHAR(50),
	@ID		UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @IND_ID, @OLD OUTPUT

	UPDATE	Install.InstallDetail
	SET		IND_DISTR		=	@DS_ID,
			IND_ID_DISTR	=	@ID
	WHERE	IND_ID			=	@IND_ID

	IF @ID IS NOT NULL
		UPDATE Distr.DistrIncome
		SET PROCESS_DATE = Common.DateOf(GETDATE()),
			ID_SUBHOST = (SELECT ID FROM Distr.Subhost WHERE REG = '')
		WHERE ID = @ID

	EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @IND_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INSTALL_DETAIL', '�������� ������������', @IND_ID, @OLD, @NEW

END
GO
GRANT EXECUTE ON [Install].[INSTALL_DISTR_SET] TO rl_install_distr;
GO
